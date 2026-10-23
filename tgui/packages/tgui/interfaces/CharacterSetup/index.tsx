import { useRef, useState } from 'react';

import { useBackend } from '../../backend';
import {
  Box,
  Button,
  ByondUi,
  Divider,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from '../../components';
import { getScreenSize } from '../../drag';
import { Window } from '../../layouts';
import { AppearanceTab } from './tabs/Appearance';
import { BackgroundTab } from './tabs/Background';
import { GeneralTab } from './tabs/General';
import { LoadoutTab } from './tabs/Loadout';
import { MarkingsTab } from './tabs/Markings';
import { QuirksTab } from './tabs/Quirks';
import { SpeechTab } from './tabs/Speech';

interface CharacterSetupTab {
  id: number;
  label: string;
  icon: string;
}

interface CharacterSetupData {
  tabs: CharacterSetupTab[];
  maxSlots: number;
  slotNames: (string | null)[];
  defaultSlot: number;
  tab: number;
  previewRef: string | null;
  previewPref: string;
  previewModes: string[];
  localStorageName: string | null;
  offerActive: boolean;
  redemptionCode?: string;
}

const PREVIEW_MODE_LABELS: Record<string, string> = {
  Job: 'По профессии',
  Loadout: 'Экипировка',
  Naked: 'Без одежды',
  'Naked - Aroused': 'Без одежды (возбужд.)',
};

const slotLabel = (
  slot: number,
  names: (string | null)[],
): string => {
  const name = names[slot - 1];
  return `[${slot}] ${name ? name : '— пустой'}`;
};

export const CharacterSetup = () => {
  const { act, data } = useBackend<CharacterSetupData>();

  const tabs = data.tabs || [];
  const activeTab = data.tab;

  const [maximized, setMaximized] = useState(false);
  const [slotsOpen, setSlotsOpen] = useState(false);
  const restoreGeometry = useRef<{ pos: string; size: string } | null>(null);

  const toggleMaximize = async () => {
    const windowId = window.__windowId__;
    const next = !maximized;
    setMaximized(next);
    if (next) {
      const [pos, size] = await Promise.all([
        Byond.winget(windowId, 'pos'),
        Byond.winget(windowId, 'size'),
      ]);
      if (pos && size) {
        restoreGeometry.current = {
          pos: `${pos.x},${pos.y}`,
          size: `${size.x}x${size.y}`,
        };
      }
      const [screenWidth, screenHeight] = getScreenSize();
      Byond.winset(windowId, {
        pos: '0,0',
        size: `${screenWidth}x${screenHeight}`,
      });
    } else {
      const geometry = restoreGeometry.current;
      if (geometry) {
        Byond.winset(windowId, {
          pos: geometry.pos,
          size: geometry.size,
        });
        restoreGeometry.current = null;
      }
    }
  };

  return (
    <Window
      width={1180}
      height={820}
      resizable
      title="Создание персонажа"
      buttons={
        <Button
          icon={maximized ? 'compress' : 'expand'}
          color="transparent"
          tooltip={maximized
            ? 'Свернуть окно обратно'
            : 'Развернуть окно на весь экран'}
          onClick={toggleMaximize}
        />
      }
    >
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <SlotBar />
          </Stack.Item>
          <Stack.Item grow={1} basis={0}>
            <Stack fill>
              <Stack.Item>
                <Box
                  style={{
                    height: '100%',
                    display: 'flex',
                    alignItems: 'center',
                  }}
                >
                  <Button
                    compact
                    icon={slotsOpen ? 'chevron-left' : 'chevron-right'}
                    tooltip={slotsOpen
                      ? 'Скрыть список персонажей'
                      : 'Показать список персонажей'}
                    onClick={() => setSlotsOpen(!slotsOpen)}
                  />
                </Box>
              </Stack.Item>
              {slotsOpen && (
                <Stack.Item width="260px">
                  <SlotPanel />
                </Stack.Item>
              )}
              <Stack.Item grow={1} basis={0}>
                <Stack fill vertical>
                  <Stack.Item>
                    <Tabs>
                      {tabs.map((tabEntry) => (
                        <Tabs.Tab
                          key={tabEntry.id}
                          selected={activeTab === tabEntry.id}
                          icon={tabEntry.icon}
                          onClick={() => act('set_tab', { tab: tabEntry.id })}
                        >
                          {tabEntry.label}
                        </Tabs.Tab>
                      ))}
                    </Tabs>
                  </Stack.Item>
                  <Stack.Item grow={1} basis={0}>
                    <Stack fill>
                      <Stack.Item grow={1} basis={0}>
                        <TabContent tab={activeTab} />
                      </Stack.Item>
                      <Stack.Item>
                        <Preview />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SlotBar = () => {
  const { act, data } = useBackend<CharacterSetupData>();

  const slotNames = data.slotNames || [];
  const defaultSlot = data.defaultSlot || 1;

  return (
    <Section>
      <Stack align="center">
        <Stack.Item grow={1}>
          <Box color="label">
            Текущий персонаж: {slotLabel(defaultSlot, slotNames)}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="save"
            content="Сохранить"
            onClick={() => act('save')}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="undo"
            content="Отменить"
            tooltip="Откатить несохранённые изменения к последнему сохранению"
            onClick={() => act('load')}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const SlotPanel = () => {
  const { act, data } = useBackend<CharacterSetupData>();

  const maxSlots = data.maxSlots || 1;
  const slotNames = data.slotNames || [];
  const defaultSlot = data.defaultSlot || 1;
  const [showEmpty, setShowEmpty] = useState(false);

  const occupied: number[] = [];
  const empty: number[] = [];
  for (let slot = 1; slot <= maxSlots; slot++) {
    if (slotNames[slot - 1]) {
      occupied.push(slot);
    } else {
      empty.push(slot);
    }
  }

  const emptyVisible =
    showEmpty || occupied.length === 0 || !slotNames[defaultSlot - 1];

  return (
    <Section
      fill
      title="Персонажи"
      buttons={<Box color="label">{occupied.length}/{maxSlots}</Box>}
    >
      <Stack fill vertical>
        <Stack.Item
          grow
          basis={0}
          style={{ overflowY: 'auto', overflowX: 'hidden', minHeight: 0 }}
        >
          {occupied.length > 0 ? (
            <Box style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2px' }}>
              {occupied.map((slot) => (
                <Button
                  key={slot}
                  fluid
                  ellipsis
                  style={{ margin: 0 }}
                  content={`${slot}. ${slotNames[slot - 1]}`}
                  selected={slot === defaultSlot}
                  tooltip={slotLabel(slot, slotNames)}
                  onClick={() => act('switch_slot', { slot })}
                />
              ))}
            </Box>
          ) : (
            <Box color="label">
              Занятых слотов нет - выберите пустой слот, чтобы создать
              персонажа.
            </Box>
          )}
          <Button
            fluid
            mt={1}
            icon={showEmpty ? 'eye-slash' : 'eye'}
            content={showEmpty
              ? 'Скрыть пустые'
              : `Пустые слоты (${empty.length})`}
            onClick={() => setShowEmpty(!showEmpty)}
          />
          {emptyVisible && empty.length > 0 && (
            <Box
              mt={1}
              style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2px' }}
            >
              {empty.map((slot) => (
                <Button
                  key={slot}
                  fluid
                  icon="plus"
                  style={{ margin: 0 }}
                  content={`Слот ${slot}`}
                  selected={slot === defaultSlot}
                  onClick={() => act('switch_slot', { slot })}
                />
              ))}
            </Box>
          )}
        </Stack.Item>
        <Stack.Item>
          <Divider />
          <Stack vertical>
            <Stack.Item>
              <Button
                fluid
                icon="dice"
                content="Случайный персонаж"
                onClick={() => act('randomize')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button.Confirm
                fluid
                icon="trash"
                color="bad"
                content="Удалить слот"
                confirmContent="Удалить слот?"
                disabled={!slotNames[defaultSlot - 1]}
                tooltip={slotNames[defaultSlot - 1]
                  ? undefined
                  : 'Текущий слот и так пуст'}
                onClick={() => act('delete_slot', { slot: defaultSlot })}
              />
            </Stack.Item>
          </Stack>
          <SlotTools />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const SlotTools = () => {
  const { act, data } = useBackend<CharacterSetupData>();
  const [open, setOpen] = useState(false);

  const localName = data.localStorageName;
  const offerActive = !!data.offerActive;

  return (
    <Box mt={1}>
      <Button
        icon={open ? 'chevron-down' : 'chevron-right'}
        content="Передача слота"
        selected={open}
        onClick={() => setOpen(!open)}
      />
      {open && (
        <Stack mt={1} align="center" wrap>
          <Stack.Item>
            <Box color="label">
              Локальная копия:{' '}
              {localName ? localName : 'пусто'}
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="download"
              content="Экспорт слота"
              onClick={() => act('slot_export')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="upload"
              content="Импорт в слот"
              disabled={!localName}
              tooltip={localName ? undefined : 'Локальной копии нет'}
              onClick={() => act('slot_import')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button.Confirm
              icon="trash"
              color="bad"
              content="Стереть локальную копию"
              confirmContent="Стереть локальную копию?"
              onClick={() => act('slot_delete_local')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button.Confirm
              icon="share-alt"
              color={offerActive ? 'bad' : undefined}
              content={offerActive ? 'Отменить передачу' : 'Предложить слот'}
              confirmContent={
                offerActive
                  ? 'Отменить предложение?'
                  : 'Вывести слот на передачу?'
              }
              onClick={() => act('slot_give')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="key"
              content="Получить по коду"
              onClick={() => act('slot_retrieve')}
            />
          </Stack.Item>
          {offerActive && !!data.redemptionCode && (
            <Stack.Item>
              <Box>
                Код передачи:{' '}
                <Box inline bold>
                  {data.redemptionCode}
                </Box>
              </Box>
            </Stack.Item>
          )}
        </Stack>
      )}
    </Box>
  );
};

const Preview = () => {
  const { act, data } = useBackend<CharacterSetupData>();

  const modes = data.previewModes || [];

  return (
    <Section title="Превью" width="280px">
      <Box textAlign="center" mb={1}>
        {data.previewRef ? (
          <ByondUi
            height="300px"
            width="240px"
            params={{ id: data.previewRef, type: 'map', zoom: 0 }}
          />
        ) : (
          <NoticeBox>Превью ещё не собрано</NoticeBox>
        )}
      </Box>
      <Stack mb={1}>
        <Stack.Item grow>
          <Button
            fluid
            icon="undo"
            content="Влево"
            onClick={() => act('preview_rotate', { step: 'left' })}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Button
            fluid
            icon="redo"
            content="Вправо"
            onClick={() => act('preview_rotate', { step: 'right' })}
          />
        </Stack.Item>
      </Stack>
      <Stack vertical>
        {modes.map((mode) => (
          <Stack.Item key={mode}>
            <Button
              fluid
              selected={data.previewPref === mode}
              content={PREVIEW_MODE_LABELS[mode] || mode}
              onClick={() => act('set_preview_mode', { mode })}
            />
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const TabContent = (props: { tab: number }) => {
  const { tab } = props;

  switch (tab) {
    case 0:
      return <GeneralTab />;
    case 1:
      return <BackgroundTab />;
    case 2:
      return <AppearanceTab />;
    case 3:
      return <MarkingsTab />;
    case 4:
      return <SpeechTab />;
    case 5:
      return <LoadoutTab />;
    case 6:
      return <QuirksTab />;
    default:
      return (
        <Section fill scrollable>
          <NoticeBox>Неизвестная вкладка - её содержимое не определено.</NoticeBox>
        </Section>
      );
  }
};
