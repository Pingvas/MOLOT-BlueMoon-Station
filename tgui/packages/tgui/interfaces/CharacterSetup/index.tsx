import { useBackend } from '../../backend';
import { Button, Section, Stack, Tabs } from '../../components';
import { Window } from '../../layouts';
import { CharacterPreview } from './components/CharacterPreview';
import { CharacterSlots } from './components/CharacterSlots';
import { GeneralTab } from './tabs/GeneralTab';
import { AppearanceTab } from './tabs/AppearanceTab';
import { BackgroundTab } from './tabs/BackgroundTab';
import { SpeechTab } from './tabs/SpeechTab';
import { MarkingsTab } from './tabs/MarkingsTab';
import { LoadoutTab } from './tabs/LoadoutTab';
import { QuirksTab } from './tabs/QuirksTab';
import { GamePrefsTab } from './tabs/GamePrefsTab';
import { OOCPrefsTab } from './tabs/OOCPrefsTab';
import { ContentPrefsTab } from './tabs/ContentPrefsTab';
import { KeybindingsTab } from './tabs/KeybindingsTab';
import { CharacterSetupData } from './types';

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

const GAME_PREFS_TAB = 0;
const OOC_PREFS_TAB = 1;
const CONTENT_PREFS_TAB = 2;

export const CharacterSetup = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    current_tab = SETTINGS_TAB,
    character_settings_tab = GENERAL_CHAR_TAB,
  } = data;

  return (
    <Window
      width={780}
      height={700}
      title="Character Setup"
      resizable>
      <Window.Content>
        <Stack vertical fill>
          {/* Main tabs */}
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                selected={current_tab === SETTINGS_TAB}
                onClick={() => act('set_tab', { tab: SETTINGS_TAB })}>
                Character Settings
              </Tabs.Tab>
              <Tabs.Tab
                selected={current_tab === PREFERENCES_TAB}
                onClick={() => act('set_tab', { tab: PREFERENCES_TAB })}>
                Preferences
              </Tabs.Tab>
              <Tabs.Tab
                selected={current_tab === KEYBINDINGS_TAB}
                onClick={() => act('set_tab', { tab: KEYBINDINGS_TAB })}>
                Keybindings
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

          {/* Bottom bar: Save/Load */}
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="save"
                  content="Save"
                  color="green"
                  onClick={() => act('save')}
                />
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="undo"
                  content="Load"
                  onClick={() => act('load')}
                />
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="dice"
                  content="Randomize"
                  color="orange"
                  onClick={() => act('randomize_all')}
                />
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
    <Stack fill>
      {/* Left panel: Preview + Slots */}
      <Stack.Item basis="220px">
        <Stack vertical fill>
          <Stack.Item grow>
            <CharacterPreview />
          </Stack.Item>
          <Stack.Item>
            <CharacterSlots />
          </Stack.Item>
        </Stack>
      </Stack.Item>

      {/* Right panel: Sub-tabs + Content */}
      <Stack.Item grow>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                selected={character_settings_tab === GENERAL_CHAR_TAB}
                onClick={() => act('set_character_tab', { tab: GENERAL_CHAR_TAB })}>
                General
              </Tabs.Tab>
              <Tabs.Tab
                selected={character_settings_tab === BACKGROUND_CHAR_TAB}
                onClick={() => act('set_character_tab', { tab: BACKGROUND_CHAR_TAB })}>
                Background
              </Tabs.Tab>
              <Tabs.Tab
                selected={character_settings_tab === APPEARANCE_CHAR_TAB}
                onClick={() => act('set_character_tab', { tab: APPEARANCE_CHAR_TAB })}>
                Appearance
              </Tabs.Tab>
              <Tabs.Tab
                selected={character_settings_tab === MARKINGS_CHAR_TAB}
                onClick={() => act('set_character_tab', { tab: MARKINGS_CHAR_TAB })}>
                Markings
              </Tabs.Tab>
              <Tabs.Tab
                selected={character_settings_tab === SPEECH_CHAR_TAB}
                onClick={() => act('set_character_tab', { tab: SPEECH_CHAR_TAB })}>
                Speech
              </Tabs.Tab>
              <Tabs.Tab
                selected={character_settings_tab === LOADOUT_CHAR_TAB}
                onClick={() => act('set_character_tab', { tab: LOADOUT_CHAR_TAB })}>
                Loadout
              </Tabs.Tab>
              {!!roundstart_traits && (
                <Tabs.Tab
                  selected={character_settings_tab === QUIRKS_CHAR_TAB}
                  onClick={() => act('set_character_tab', { tab: QUIRKS_CHAR_TAB })}>
                  Quirks
                </Tabs.Tab>
              )}
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
            </Section>
          </Stack.Item>
        </Stack>
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
            selected={preferences_tab === GAME_PREFS_TAB}
            onClick={() => act('set_prefs_tab', { tab: GAME_PREFS_TAB })}
          >
            Game
          </Tabs.Tab>
          <Tabs.Tab
            selected={preferences_tab === OOC_PREFS_TAB}
            onClick={() => act('set_prefs_tab', { tab: OOC_PREFS_TAB })}
          >
            OOC
          </Tabs.Tab>
          <Tabs.Tab
            selected={preferences_tab === CONTENT_PREFS_TAB}
            onClick={() => act('set_prefs_tab', { tab: CONTENT_PREFS_TAB })}
          >
            Content
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
