import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Collapsible,
  Divider,
  Section,
  Stack,
  Tabs,
} from '../../components';
import { Window } from '../../layouts';
import { CharacterPreview } from './components/CharacterPreview';
import { CharacterSlots } from './components/CharacterSlots';
import { AppearanceTab } from './tabs/AppearanceTab';
import { BackgroundTab } from './tabs/BackgroundTab';
import { ContentPrefsTab } from './tabs/ContentPrefsTab';
import { GamePrefsTab } from './tabs/GamePrefsTab';
import { GeneralTab } from './tabs/GeneralTab';
import { JobsTab } from './tabs/JobsTab';
import { KeybindingsTab } from './tabs/KeybindingsTab';
import { LoadoutTab } from './tabs/LoadoutTab';
import { MarkingsTab } from './tabs/MarkingsTab';
import { OOCPrefsTab } from './tabs/OOCPrefsTab';
import { QuirksTab } from './tabs/QuirksTab';
import { SpeechTab } from './tabs/SpeechTab';
import { CharacterSetupData } from './types';

// MARK: Root Tabs
const SETTINGS_TAB = 0;
const PREFERENCES_TAB = 1;
const KEYBINDINGS_TAB = 2;

// MARK: Character Subtabs
const GENERAL_CHAR_TAB = 0;
const BACKGROUND_CHAR_TAB = 1;
const APPEARANCE_CHAR_TAB = 2;
const MARKINGS_CHAR_TAB = 3;
const SPEECH_CHAR_TAB = 4;
const LOADOUT_CHAR_TAB = 5;
const QUIRKS_CHAR_TAB = 6;
const JOBS_CHAR_TAB = 7;

// MARK: Preferences Subtabs
const GAME_PREFS_TAB = 0;
const OOC_PREFS_TAB = 1;
const CONTENT_PREFS_TAB = 2;

type TabEntry = {
  tab: number;
  icon: string;
  label: string;
};

const MAIN_TABS: TabEntry[] = [
  { tab: SETTINGS_TAB, icon: 'user', label: 'Персонаж' },
  { tab: PREFERENCES_TAB, icon: 'cog', label: 'Настройки' },
  { tab: KEYBINDINGS_TAB, icon: 'keyboard', label: 'Клавиши' },
];

const CHARACTER_SECONDARY_TABS: TabEntry[] = [
  { tab: BACKGROUND_CHAR_TAB, icon: 'book', label: 'Биография' },
  { tab: MARKINGS_CHAR_TAB, icon: 'paint-brush', label: 'Отметины' },
  { tab: SPEECH_CHAR_TAB, icon: 'comment', label: 'Речь' },
  { tab: LOADOUT_CHAR_TAB, icon: 'box-open', label: 'Лоадаут' },
];

const PREFERENCES_TABS: TabEntry[] = [
  { tab: GAME_PREFS_TAB, icon: 'gamepad', label: 'Игровые' },
  { tab: OOC_PREFS_TAB, icon: 'comments', label: 'OOC' },
  { tab: CONTENT_PREFS_TAB, icon: 'heart', label: 'Контент' },
];

const ROOT_CONTENT_STYLE = {
  padding: '8px',
  background:
    'radial-gradient(circle at 15% 12%, rgba(86, 131, 183, 0.18), transparent 32%), radial-gradient(circle at 86% 88%, rgba(71, 101, 142, 0.16), transparent 36%), linear-gradient(145deg, rgba(14,19,29,0.97), rgba(8,12,18,0.98))',
} as const;

const PANEL_SURFACE_STYLE = {
  background: 'rgba(16, 23, 34, 0.72)',
  border: '1px solid rgba(122, 162, 212, 0.16)',
  borderRadius: '8px',
  padding: '6px',
  backdropFilter: 'blur(2px)',
} as const;

const TABBAR_WRAPPER_STYLE = {
  background: 'rgba(17, 24, 36, 0.66)',
  borderRadius: '7px',
  border: '1px solid rgba(122, 162, 212, 0.16)',
  padding: '4px',
  width: '100%',
} as const;

const MAIN_TABBAR_WRAPPER_STYLE = {
  ...TABBAR_WRAPPER_STYLE,
  width: 'fit-content',
  minWidth: '340px',
} as const;

const MAIN_TABBAR_CONTAINER_STYLE = {
  display: 'flex',
  justifyContent: 'center',
  width: '100%',
} as const;

const RIGHT_PANEL_STYLE = {
  ...PANEL_SURFACE_STYLE,
  display: 'flex',
  flexDirection: 'column',
  minWidth: 0,
} as const;

// MARK: Shared UI
const TabBar = (props: {
  entries: TabEntry[];
  selectedTab: number;
  onSelect: (tab: number) => void;
  fluid?: boolean;
  centered?: boolean;
  wrapperStyle?: any;
}) => {
  const {
    entries,
    selectedTab,
    onSelect,
    fluid = true,
    centered = false,
    wrapperStyle,
  } = props;
  const tabsStyle = centered ? { justifyContent: 'center' } : undefined;

  return (
    <Box style={{ ...TABBAR_WRAPPER_STYLE, ...wrapperStyle }}>
      <Tabs fluid={fluid} style={tabsStyle}>
        {entries.map((entry) => (
          <Tabs.Tab
            key={entry.tab}
            icon={entry.icon}
            selected={selectedTab === entry.tab}
            onClick={() => onSelect(entry.tab)}>
            {entry.label}
          </Tabs.Tab>
        ))}
      </Tabs>
    </Box>
  );
};

// MARK: Root Window
export const CharacterSetup = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    current_tab = SETTINGS_TAB,
    active_slot = 1,
  } = data;

  return (
    <Window
      width={920}
      height={720}
      title="Character Setup"
      resizable>
      <Window.Content style={ROOT_CONTENT_STYLE}>
        <Stack vertical fill>
          <Stack.Item>
            <Box style={MAIN_TABBAR_CONTAINER_STYLE}>
              <TabBar
                entries={MAIN_TABS}
                selectedTab={current_tab}
                onSelect={(tab) => act('set_tab', { tab })}
                fluid={false}
                centered
                wrapperStyle={MAIN_TABBAR_WRAPPER_STYLE}
              />
            </Box>
          </Stack.Item>

          <Stack.Item grow>
            <Stack fill>
              {/* Left sidebar exists only on Character tab */}
              {current_tab === SETTINGS_TAB && (
                <CharacterSidebar
                  act={act}
                  data={data}
                  activeSlot={active_slot}
                />
              )}

              {/* Right content area */}
              <Stack.Item grow basis={0} style={{ minWidth: 0 }}>
                <Stack vertical fill style={RIGHT_PANEL_STYLE}>
                  <Stack.Item grow basis={0} style={{ minWidth: 0 }}>
                    {current_tab === SETTINGS_TAB && <CharacterSettingsContent />}
                    {current_tab === PREFERENCES_TAB && <PreferencesContent />}
                    {current_tab === KEYBINDINGS_TAB && <KeybindingsTab />}
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

// MARK: Sidebar
const CharacterSidebar = (props: {
  act: any;
  data: CharacterSetupData;
  activeSlot: number;
}) => {
  const { act, data, activeSlot } = props;

  return (
    <Stack.Item basis="300px" shrink={0} style={PANEL_SURFACE_STYLE}>
      <Stack vertical fill>
        <Stack.Item grow>
          <CharacterPreview />
        </Stack.Item>

        <Stack.Item>
          <Section title="Управление персонажем">
            <CharacterSlots />
            <Divider mt={1} mb={1} />

            <Stack>
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
                  icon="history"
                  content="Загрузить"
                  onClick={() => act('load')}
                />
              </Stack.Item>
            </Stack>

            <Stack mt={0.5}>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="dice"
                  color="orange"
                  content="Рандомизировать"
                  tooltip="Случайно заполнить текущего персонажа"
                  onClick={() => act('randomize_all')}
                />
              </Stack.Item>
            </Stack>

            <Collapsible title="Импорт и экспорт" mt={1}>
              <Stack>
                <Stack.Item grow>
                  <Button
                    fluid
                    icon="file-export"
                    content="Экспорт"
                    tooltip="Экспортировать текущий слот в локальное хранилище"
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
            </Collapsible>

            <Collapsible title="Передача слота" mt={0.5} open={!!data.has_offer}>
              <Box color="label" mb={0.5} fontSize="12px">
                {data.has_offer
                  ? `Активное предложение. Код: ${data.offer_code}`
                  : 'Предложите слот другому игроку или заберите по коду.'}
              </Box>
              <Stack>
                <Stack.Item grow>
                  <Button
                    fluid
                    icon={data.has_offer ? 'times' : 'gift'}
                    content={data.has_offer ? 'Отменить предложение' : 'Предложить слот'}
                    color={data.has_offer ? 'bad' : undefined}
                    onClick={() => act('give_slot')}
                  />
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    icon="hand-holding"
                    content="Забрать по коду"
                    onClick={() => act('retrieve_slot')}
                  />
                </Stack.Item>
              </Stack>
            </Collapsible>

            <Divider mt={1} mb={0.5} />
            <Button
              fluid
              icon="trash"
              content="Удалить текущий слот"
              color="bad"
              onClick={() => act('delete_slot', { slot: activeSlot })}
            />
          </Section>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

// MARK: Character Tab Content
const CharacterSettingsContent = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    character_settings_tab = GENERAL_CHAR_TAB,
    roundstart_traits,
  } = data;

  const primaryTabs: TabEntry[] = [
    { tab: GENERAL_CHAR_TAB, icon: 'id-card', label: 'Основное' },
    { tab: APPEARANCE_CHAR_TAB, icon: 'palette', label: 'Внешность' },
  ];

  const secondaryTabs: TabEntry[] = [
    ...CHARACTER_SECONDARY_TABS,
    { tab: JOBS_CHAR_TAB, icon: 'briefcase', label: 'Работа' },
  ];

  if (roundstart_traits) {
    secondaryTabs.push({ tab: QUIRKS_CHAR_TAB, icon: 'star', label: 'Особенности' });
  }

  const handleCharacterTabSelect = (tab: number) => {
    act('set_character_tab', { tab });
  };
  return (
    <Stack vertical fill>
      <Stack.Item>
        <Stack vertical>
          <Stack.Item>
            <TabBar
              entries={primaryTabs}
              selectedTab={character_settings_tab}
              onSelect={handleCharacterTabSelect}
            />
          </Stack.Item>
          <Stack.Item mt={0.5}>
            <TabBar
              entries={secondaryTabs}
              selectedTab={character_settings_tab}
              onSelect={handleCharacterTabSelect}
            />
          </Stack.Item>
        </Stack>
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

// MARK: Preferences Tab Content
const PreferencesContent = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const { preferences_tab = GAME_PREFS_TAB } = data as any;

  return (
    <Stack vertical fill>
      <Stack.Item>
        <TabBar
          entries={PREFERENCES_TABS}
          selectedTab={preferences_tab}
          onSelect={(tab) => act('set_preferences_tab', { tab })}
        />
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
