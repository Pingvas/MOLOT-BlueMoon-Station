import { useBackend } from '../../backend';
import { Button, Dropdown, Section, Stack, Tabs } from '../../components';
import { Window } from '../../layouts';
import { CharacterPreview } from './components/CharacterPreview';
import { GeneralTab } from './tabs/GeneralTab';
import { AppearanceTab } from './tabs/AppearanceTab';
import { BackgroundTab } from './tabs/BackgroundTab';
import { SpeechTab } from './tabs/SpeechTab';
import { MarkingsTab } from './tabs/MarkingsTab';
import { LoadoutTab } from './tabs/LoadoutTab';
import { QuirksTab } from './tabs/QuirksTab';
import { JobsTab } from './tabs/JobsTab';
import { GamePrefsTab } from './tabs/GamePrefsTab';
import { OOCPrefsTab } from './tabs/OOCPrefsTab';
import { ContentPrefsTab } from './tabs/ContentPrefsTab';
import { KeybindingsTab } from './tabs/KeybindingsTab';
import { CharacterSetupData, CharacterSlot } from './types';

const SETTINGS_TAB = 0;
const PREFERENCES_TAB = 1;
const KEYBINDINGS_TAB = 2;

const GENERAL_CHAR_TAB = 0;
const BACKGROUND_CHAR_TAB = 1;
const APPEARANCE_CHAR_TAB = 2;
const MARKINGS_CHAR_TAB = 3;
const SPEECH_CHAR_TAB = 4;
const LOADOUT_CHAR_TAB = 5;
const QUIRKS_CHAR_TAB = 6;
const JOBS_CHAR_TAB = 7;

const GAME_PREFS_TAB = 0;
const OOC_PREFS_TAB = 1;
const CONTENT_PREFS_TAB = 2;

export const CharacterSetup = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    current_tab = SETTINGS_TAB,
    character_settings_tab = GENERAL_CHAR_TAB,
    slots = [],
    active_slot = 1,
  } = data;

  const currentSlot = slots.find(
    (s: CharacterSlot) => s.index === active_slot
  );
  const slotOptions = slots.map((s: CharacterSlot) =>
    s.is_empty ? `Слот ${s.index} (пусто)` : s.name
  );
  const selectedSlotLabel = currentSlot
    ? (currentSlot.is_empty
      ? `Слот ${currentSlot.index} (пусто)`
      : currentSlot.name)
    : `Слот ${active_slot}`;

  return (
    <Window
      width={920}
      height={720}
      title="Character Setup"
      resizable>
      <Window.Content>
        <Stack fill>
          {/* === Left sidebar: Preview + Slot + Actions === */}
          <Stack.Item basis="260px" shrink={0}>
            <Stack vertical fill>
              {/* Character preview */}
              <Stack.Item grow>
                <CharacterPreview />
              </Stack.Item>

              {/* Slot selector */}
              <Stack.Item>
                <Section>
                  <Dropdown
                    fluid
                    selected={selectedSlotLabel}
                    options={slotOptions}
                    onSelected={(value) => {
                      const idx = slotOptions.indexOf(value) + 1;
                      if (idx > 0) {
                        act('change_slot', { slot: idx });
                      }
                    }}
                  />
                  <Stack mt={1}>
                    <Stack.Item grow>
                      <Button
                        fluid
                        icon="save"
                        content="Сохранить"
                        color="green"
                        onClick={() => act('save')}
                      />
                    </Stack.Item>
                    <Stack.Item grow>
                      <Button
                        fluid
                        icon="undo"
                        content="Загрузить"
                        onClick={() => act('load')}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="dice"
                        color="orange"
                        tooltip="Рандомизировать"
                        onClick={() => act('randomize_all')}
                      />
                    </Stack.Item>
                  </Stack>
                  <Stack mt={1}>
                    <Stack.Item grow>
                      <Button
                        fluid
                        icon="file-export"
                        content="Экспорт"
                        tooltip="Экспортировать слот в локальное хранилище"
                        onClick={() => act('export_slot')}
                      />
                    </Stack.Item>
                    <Stack.Item grow>
                      <Button
                        fluid
                        icon="file-import"
                        content="Импорт"
                        tooltip="Импортировать слот из локального хранилища"
                        onClick={() => act('import_slot')}
                      />
                    </Stack.Item>
                  </Stack>
                  <Stack mt={1}>
                    <Stack.Item grow>
                      <Button
                        fluid
                        icon={data.has_offer ? 'times' : 'gift'}
                        content={data.has_offer ? 'Отменить' : 'Предложить'}
                        color={data.has_offer ? 'bad' : undefined}
                        tooltip={
                          data.has_offer
                            ? `Код: ${data.offer_code}. Нажмите для отмены`
                            : 'Предложить слот другому игроку'
                        }
                        onClick={() => act('give_slot')}
                      />
                    </Stack.Item>
                    <Stack.Item grow>
                      <Button
                        fluid
                        icon="hand-holding"
                        content="Забрать"
                        tooltip="Забрать предложенного персонажа по коду"
                        onClick={() => act('retrieve_slot')}
                      />
                    </Stack.Item>
                  </Stack>
                  <Stack mt={1}>
                    <Stack.Item grow>
                      <Button
                        fluid
                        icon="trash"
                        content="Удалить слот"
                        color="bad"
                        onClick={() =>
                          act('delete_slot', { slot: active_slot })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          {/* === Right content area === */}
          <Stack.Item grow>
            <Stack vertical fill>
              {/* Main category tabs */}
              <Stack.Item>
                <Tabs fluid>
                  <Tabs.Tab
                    icon="user"
                    selected={current_tab === SETTINGS_TAB}
                    onClick={() => act('set_tab', { tab: SETTINGS_TAB })}>
                    Персонаж
                  </Tabs.Tab>
                  <Tabs.Tab
                    icon="cog"
                    selected={current_tab === PREFERENCES_TAB}
                    onClick={() => act('set_tab', { tab: PREFERENCES_TAB })}>
                    Настройки
                  </Tabs.Tab>
                  <Tabs.Tab
                    icon="keyboard"
                    selected={current_tab === KEYBINDINGS_TAB}
                    onClick={() => act('set_tab', { tab: KEYBINDINGS_TAB })}>
                    Клавиши
                  </Tabs.Tab>
                </Tabs>
              </Stack.Item>

              {/* Content */}
              <Stack.Item grow>
                {current_tab === SETTINGS_TAB && (
                  <CharacterSettingsContent />
                )}
                {current_tab === PREFERENCES_TAB && (
                  <PreferencesContent />
                )}
                {current_tab === KEYBINDINGS_TAB && (
                  <KeybindingsTab />
                )}
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CharacterSettingsContent = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    character_settings_tab = GENERAL_CHAR_TAB,
    roundstart_traits,
  } = data;

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Tabs fluid>
          <Tabs.Tab
            icon="id-card"
            selected={character_settings_tab === GENERAL_CHAR_TAB}
            onClick={() => act('set_character_tab', {
              tab: GENERAL_CHAR_TAB,
            })}>
            Основное
          </Tabs.Tab>
          <Tabs.Tab
            icon="book"
            selected={character_settings_tab === BACKGROUND_CHAR_TAB}
            onClick={() => act('set_character_tab', {
              tab: BACKGROUND_CHAR_TAB,
            })}>
            Биография
          </Tabs.Tab>
          <Tabs.Tab
            icon="palette"
            selected={character_settings_tab === APPEARANCE_CHAR_TAB}
            onClick={() => act('set_character_tab', {
              tab: APPEARANCE_CHAR_TAB,
            })}>
            Внешность
          </Tabs.Tab>
          <Tabs.Tab
            icon="paint-brush"
            selected={character_settings_tab === MARKINGS_CHAR_TAB}
            onClick={() => act('set_character_tab', {
              tab: MARKINGS_CHAR_TAB,
            })}>
            Отметины
          </Tabs.Tab>
          <Tabs.Tab
            icon="comment"
            selected={character_settings_tab === SPEECH_CHAR_TAB}
            onClick={() => act('set_character_tab', {
              tab: SPEECH_CHAR_TAB,
            })}>
            Речь
          </Tabs.Tab>
          <Tabs.Tab
            icon="box-open"
            selected={character_settings_tab === LOADOUT_CHAR_TAB}
            onClick={() => act('set_character_tab', {
              tab: LOADOUT_CHAR_TAB,
            })}>
            Лоадаут
          </Tabs.Tab>
          {!!roundstart_traits && (
            <Tabs.Tab
              icon="star"
              selected={character_settings_tab === QUIRKS_CHAR_TAB}
              onClick={() => act('set_character_tab', {
                tab: QUIRKS_CHAR_TAB,
              })}>
              Особенности
            </Tabs.Tab>
          )}
          <Tabs.Tab
            icon="briefcase"
            selected={character_settings_tab === JOBS_CHAR_TAB}
            onClick={() => act('set_character_tab', {
              tab: JOBS_CHAR_TAB,
            })}>
            Работа
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>

      <Stack.Item grow>
        <Section fill scrollable>
          {character_settings_tab === GENERAL_CHAR_TAB && <GeneralTab />}
          {character_settings_tab === BACKGROUND_CHAR_TAB && <BackgroundTab />}
          {character_settings_tab === APPEARANCE_CHAR_TAB && <AppearanceTab />}
          {character_settings_tab === MARKINGS_CHAR_TAB && <MarkingsTab />}
          {character_settings_tab === SPEECH_CHAR_TAB && <SpeechTab />}
          {character_settings_tab === LOADOUT_CHAR_TAB && <LoadoutTab />}
          {character_settings_tab === QUIRKS_CHAR_TAB && <QuirksTab />}
          {character_settings_tab === JOBS_CHAR_TAB && <JobsTab />}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const PreferencesContent = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const { preferences_tab = GAME_PREFS_TAB } = data as any;

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Tabs fluid>
          <Tabs.Tab
            icon="gamepad"
            selected={preferences_tab === GAME_PREFS_TAB}
            onClick={() => act('set_prefs_tab', { tab: GAME_PREFS_TAB })}>
            Игровые
          </Tabs.Tab>
          <Tabs.Tab
            icon="comments"
            selected={preferences_tab === OOC_PREFS_TAB}
            onClick={() => act('set_prefs_tab', { tab: OOC_PREFS_TAB })}>
            OOC
          </Tabs.Tab>
          <Tabs.Tab
            icon="heart"
            selected={preferences_tab === CONTENT_PREFS_TAB}
            onClick={() => act('set_prefs_tab', { tab: CONTENT_PREFS_TAB })}>
            Контент
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {preferences_tab === GAME_PREFS_TAB && <GamePrefsTab />}
          {preferences_tab === OOC_PREFS_TAB && <OOCPrefsTab />}
          {preferences_tab === CONTENT_PREFS_TAB && <ContentPrefsTab />}
        </Section>
      </Stack.Item>
    </Stack>
  );
};
