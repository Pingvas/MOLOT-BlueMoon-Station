import { useBackend } from '../../../backend';
import {
  Button,
  ColorBox,
  LabeledList,
  Section,
  Stack,
} from '../../../components';
import { CharacterSetupData } from '../types';

// toggles bitflags
const SOUND_MIDI = 1 << 1;
const SOUND_LOBBY = 1 << 3;
const MEMBER_PUBLIC = 1 << 4;
const SOUND_INSTRUMENTS = 1 << 7;
const SOUND_ANNOUNCEMENTS = 1 << 11;
const SOUND_JUKEBOXES = 1 << 20;

// chat_toggles bitflags
const CHAT_OOC = 1 << 0;
const CHAT_DEAD = 1 << 1;
const CHAT_GHOSTEARS = 1 << 2;
const CHAT_GHOSTSIGHT = 1 << 3;
const CHAT_PRAYER = 1 << 4;
const CHAT_RADIO = 1 << 5;
const CHAT_PULLR = 1 << 6;
const CHAT_GHOSTWHISPER = 1 << 7;
const CHAT_GHOSTPDA = 1 << 8;
const CHAT_GHOSTRADIO = 1 << 9;
const CHAT_LOOC = 1 << 10;

// custom_colors bitflags
const CUSTOM_OOC = 1 << 0;
const CUSTOM_AOOC = 1 << 1;

export const OOCPrefsTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    ooccolor,
    aooccolor,
    ghost_form,
    ghost_orbit,
    ghost_accs,
    ghost_others,
    chat_toggles = 0,
    toggles = 0,
    custom_colors = 0,
    windowflashing,
    windownoise,
  } = data as any;

  const customOoc = !!(custom_colors & CUSTOM_OOC);
  const customAooc = !!(custom_colors & CUSTOM_AOOC);

  return (
    <Stack vertical>
      {/* OOC Colors */}
      <Stack.Item>
        <Section title="Настройки OOC">
          <LabeledList>
            <LabeledList.Item label="Цвет OOC">
              <Button.Checkbox
                checked={customOoc}
                content="Свой"
                onClick={() => act('toggle_flag', {
                  flag: 'custom_color_ooc',
                })}
              />
              {customOoc && (
                <Button onClick={() => act('set_ooccolor')}>
                  <ColorBox color={ooccolor} mr={1} />
                </Button>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Цвет AOOC">
              <Button.Checkbox
                checked={customAooc}
                content="Свой"
                onClick={() => act('toggle_flag', {
                  flag: 'custom_color_aooc',
                })}
              />
              {customAooc && (
                <Button onClick={() => act('set_aooccolor')}>
                  <ColorBox color={aooccolor} mr={1} />
                </Button>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

      {/* Sounds & Notifications */}
      <Stack.Item>
        <Section title="Звуки и уведомления">
          <Stack>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Мигание окна">
                  <Button.Checkbox
                    checked={windowflashing}
                    onClick={() => act('toggle_flag', { flag: 'winflash' })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Звук окна">
                  <Button.Checkbox
                    checked={windownoise}
                    onClick={() => act('toggle_flag', { flag: 'winnoise' })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Музыка лобби">
                  <Button.Checkbox
                    checked={!!(toggles & SOUND_LOBBY)}
                    onClick={() => act('toggle_flag', {
                      flag: 'lobby_music',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Админ MIDI">
                  <Button.Checkbox
                    checked={!!(toggles & SOUND_MIDI)}
                    onClick={() => act('toggle_flag', {
                      flag: 'hear_midis',
                    })}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Инструменты">
                  <Button.Checkbox
                    checked={!!(toggles & SOUND_INSTRUMENTS)}
                    onClick={() => act('toggle_flag', {
                      flag: 'hear_instruments',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Объявления">
                  <Button.Checkbox
                    checked={!!(toggles & SOUND_ANNOUNCEMENTS)}
                    onClick={() => act('toggle_flag', {
                      flag: 'hear_announcements',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Джукбоксы">
                  <Button.Checkbox
                    checked={!!(toggles & SOUND_JUKEBOXES)}
                    onClick={() => act('toggle_flag', {
                      flag: 'hear_jukeboxes',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Pull Requests">
                  <Button.Checkbox
                    checked={!!(chat_toggles & CHAT_PULLR)}
                    onClick={() => act('toggle_chat_flag', {
                      flag: 'pull_requests',
                    })}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* Ghost Settings */}
      <Stack.Item>
        <Section title="Призрак">
          <Stack>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Форма">
                  <Button
                    content={ghost_form || 'ghost'}
                    onClick={() => act('set_ghost_form')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Орбита">
                  <Button
                    content={ghost_orbit || 'circle'}
                    onClick={() => act('set_ghost_orbit')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Аксессуары">
                  <Button
                    content={ghost_accs || 'Full'}
                    onClick={() => act('toggle_flag', {
                      flag: 'ghost_accs',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Другие призраки">
                  <Button
                    content={ghost_others || 'Their Setting'}
                    onClick={() => act('toggle_flag', {
                      flag: 'ghost_others',
                    })}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Слух призрака">
                  <Button.Checkbox
                    checked={!!(chat_toggles & CHAT_GHOSTEARS)}
                    onClick={() => act('toggle_chat_flag', {
                      flag: 'ghost_ears',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Зрение призрака">
                  <Button.Checkbox
                    checked={!!(chat_toggles & CHAT_GHOSTSIGHT)}
                    onClick={() => act('toggle_chat_flag', {
                      flag: 'ghost_sight',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Шёпот призрака">
                  <Button.Checkbox
                    checked={!!(chat_toggles & CHAT_GHOSTWHISPER)}
                    onClick={() => act('toggle_chat_flag', {
                      flag: 'ghost_whispers',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="PDA призрака">
                  <Button.Checkbox
                    checked={!!(chat_toggles & CHAT_GHOSTPDA)}
                    onClick={() => act('toggle_chat_flag', {
                      flag: 'ghost_pda',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Радио призрака">
                  <Button.Checkbox
                    checked={!!(chat_toggles & CHAT_GHOSTRADIO)}
                    onClick={() => act('toggle_chat_flag', {
                      flag: 'ghost_radio',
                    })}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
