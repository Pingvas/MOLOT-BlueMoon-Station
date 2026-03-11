import { useBackend } from '../../../backend';
import {
  Box,
  Button,
  ColorBox,
  LabeledList,
  NumberInput,
  Section,
  Slider,
  Stack,
} from '../../../components';
import { CharacterSetupData } from '../types';

// toggles bitflags
const SOUND_MIDI = 1 << 1;
const SOUND_LOBBY = 1 << 3;
const MIDROUND_ANTAG = 1 << 6;
const NO_ANTAG = 1 << 16;
const VERB_CONSENT = 1 << 17;
const LEWD_VERB_SOUNDS = 1 << 18;
const RANGED_VERBS_CONSENT = 1 << 21;

export const GamePrefsTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    UI_style,
    outline_enabled,
    outline_color,
    screentip_pref,
    screentip_color,
    screentip_images,
    hotkeys,
    tgui_fancy,
    tgui_lock,
    chat_on_map,
    max_chat_length,
    see_chat_non_mob,
    see_rc_emotes,
    clientfps,
    toggles = 0,
    widescreenpref,
    fullscreen,
    long_strip_menu,
    auto_ooc,
    autostand,
    auto_capitalize_enabled,
    no_tetris_storage,
    screenshake,
    damagescreenshake,
    recoil_screenshake,
    parallax,
    ambientocclusion,
    auto_fit_viewport,
    hud_toggle_flash,
    hud_toggle_color,
    view_pixelshift,
    disable_combat_cursor,
    disable_combat_mouse_lock,
    be_victim,
  } = data as any;

  return (
    <Stack vertical>
      {/* UI Settings */}
      <Stack.Item>
        <Section title="UI Settings">
          <Stack>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="UI Style">
                  <Button
                    content={UI_style || 'Default'}
                    onClick={() => act('set_ui_style')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Outline">
                  <Button.Checkbox
                    checked={outline_enabled}
                    content={outline_enabled ? 'Enabled' : 'Disabled'}
                    onClick={() => act('toggle_outline')}
                  />
                  {!!outline_enabled && (
                    <Button onClick={() => act('set_outline_color')}>
                      <ColorBox color={outline_color} mr={1} />
                    </Button>
                  )}
                </LabeledList.Item>
                <LabeledList.Item label="Screentips">
                  <Button
                    content={screentip_pref || 'Default'}
                    onClick={() => act('set_screentip_pref')}
                  />
                  <Button onClick={() => act('set_screentip_color')}>
                    <ColorBox color={screentip_color} mr={1} />
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Screentip Images">
                  <Button.Checkbox
                    checked={screentip_images}
                    content={screentip_images ? 'Allowed' : 'Disallowed'}
                    onClick={() => act('toggle_screentip_images')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="tgui Style">
                  <Button.Checkbox
                    checked={tgui_fancy}
                    content={tgui_fancy ? 'Fancy' : 'No Frills'}
                    onClick={() => act('toggle_tgui_fancy')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="tgui Monitors">
                  <Button.Checkbox
                    checked={tgui_lock}
                    content={tgui_lock ? 'Primary Only' : 'All'}
                    onClick={() => act('toggle_tgui_lock')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Widescreen">
                  <Button.Checkbox
                    checked={widescreenpref}
                    onClick={() => act('toggle_widescreenpref')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Fullscreen">
                  <Button.Checkbox
                    checked={fullscreen}
                    onClick={() => act('toggle_fullscreen')}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Hotkeys">
                  <Button.Checkbox
                    checked={hotkeys}
                    content={hotkeys ? 'Enabled' : 'Disabled'}
                    onClick={() => act('toggle_hotkeys')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Long Strip Menu">
                  <Button.Checkbox
                    checked={long_strip_menu}
                    onClick={() => act('toggle_long_strip_menu')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Auto-Stand">
                  <Button.Checkbox
                    checked={autostand}
                    onClick={() => act('toggle_autostand')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Auto OOC">
                  <Button.Checkbox
                    checked={auto_ooc}
                    onClick={() => act('toggle_auto_ooc')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Auto-Capitalize">
                  <Button.Checkbox
                    checked={auto_capitalize_enabled}
                    onClick={() => act('toggle_auto_capitalize')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Tetris Storage">
                  <Button.Checkbox
                    checked={!no_tetris_storage}
                    content={no_tetris_storage ? 'Disabled' : 'Enabled'}
                    onClick={() => act('toggle_no_tetris')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Parallax">
                  <Button
                    content={parallax || 'Default'}
                    onClick={() => act('set_parallax')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Ambient Occlusion">
                  <Button.Checkbox
                    checked={ambientocclusion}
                    onClick={() => act('toggle_ambientocclusion')}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* Runechat & Display */}
      <Stack.Item>
        <Section title="Runechat & Display">
          <Stack>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Runechat">
                  <Button.Checkbox
                    checked={chat_on_map}
                    content={chat_on_map ? 'Enabled' : 'Disabled'}
                    onClick={() => act('toggle_chat_on_map')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Runechat Limit">
                  <NumberInput
                    value={max_chat_length || 110}
                    minValue={1}
                    maxValue={256}
                    step={1}
                    onChange={(e, value) => act('set_max_chat_length', {
                      value,
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Runechat Non-mobs">
                  <Button.Checkbox
                    checked={see_chat_non_mob}
                    onClick={() => act('toggle_see_chat_non_mob')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Runechat Emotes">
                  <Button.Checkbox
                    checked={see_rc_emotes}
                    onClick={() => act('toggle_see_rc_emotes')}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="FPS">
                  <NumberInput
                    value={clientfps || 0}
                    minValue={0}
                    maxValue={240}
                    step={1}
                    onChange={(e, value) => act('set_clientfps', {
                      value,
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Auto-Fit Viewport">
                  <Button.Checkbox
                    checked={auto_fit_viewport}
                    onClick={() => act('toggle_auto_fit_viewport')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="HUD Flash">
                  <Button.Checkbox
                    checked={hud_toggle_flash}
                    onClick={() => act('toggle_hud_flash')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="HUD Color">
                  <Button onClick={() => act('set_hud_color')}>
                    <ColorBox color={hud_toggle_color || '#ffffff'} mr={1} />
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Pixelshift View">
                  <Button.Checkbox
                    checked={view_pixelshift}
                    onClick={() => act('toggle_view_pixelshift')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Combat Cursor">
                  <Button.Checkbox
                    checked={!disable_combat_cursor}
                    content={disable_combat_cursor ? 'Disabled' : 'Enabled'}
                    onClick={() => act('toggle_combat_cursor')}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* Screenshake */}
      <Stack.Item>
        <Section title="Screenshake">
          <LabeledList>
            <LabeledList.Item label="Screenshake">
              <Slider
                value={screenshake || 0}
                minValue={0}
                maxValue={100}
                step={10}
                unit="%"
                onChange={(e, value) => act('set_screenshake', { value })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Damage Screenshake">
              <Slider
                value={damagescreenshake || 0}
                minValue={0}
                maxValue={10}
                step={1}
                onChange={(e, value) => act('set_damagescreenshake', {
                  value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Recoil Screenshake">
              <Slider
                value={recoil_screenshake || 0}
                minValue={0}
                maxValue={100}
                step={10}
                unit="%"
                onChange={(e, value) => act('set_recoil_screenshake', {
                  value,
                })}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

      {/* Antag */}
      <Stack.Item>
        <Section title="Antagonist Preferences">
          <Stack>
            <Stack.Item grow>
              <Button
                fluid
                icon="user-secret"
                content="Configure Antag Preferences"
                onClick={() => act('open_antag_prefs')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button.Checkbox
                checked={!!(toggles & MIDROUND_ANTAG)}
                content="Allow Midround Antag"
                onClick={() => act('toggle_flag', {
                  flag: 'midround_antag',
                })}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                content={be_victim || 'Default'}
                icon="crosshairs"
                tooltip="Prefer to be an antagonist victim"
                onClick={() => act('set_be_victim')}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
