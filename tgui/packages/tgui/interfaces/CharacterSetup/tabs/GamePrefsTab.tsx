import { useBackend } from '../../../backend';
import {
  Box,
  Button,
  ColorBox,
  Flex,
  LabeledList,
  NumberInput,
  Section,
  Slider,
  Stack,
  Tooltip,
} from '../../../components';
import { AntagRoleInfo, CharacterSetupData } from '../types';

// toggles bitflags
const SOUND_MIDI = 1 << 1;
const SOUND_LOBBY = 1 << 3;
const MIDROUND_ANTAG = 1 << 6;
const NO_ANTAG = 1 << 16;
const VERB_CONSENT = 1 << 17;
const LEWD_VERB_SOUNDS = 1 << 18;
const RANGED_VERBS_CONSENT = 1 << 21;

const ANTAG_ROLE_NAMES: Record<string, string> = {
  'traitor': 'Предатель',
  'blood brother': 'Кровный брат',
  'operative': 'Оперативник',
  'Slaver': 'Работорговец',
  'changeling': 'Генокрад',
  'Changeling (Meteor)': 'Генокрад (Метеор)',
  'wizard': 'Волшебник',
  'malf AI': 'Сбойный ИИ',
  'revolutionary': 'Революционер',
  'xenomorph': 'Ксеноморф',
  'pAI': 'пИИ',
  'cultist': 'Культист',
  'blob': 'Блоб',
  'space ninja': 'Космический ниндзя',
  'monkey': 'Обезьяна',
  'revenant': 'Ревенант',
  'abductor': 'Похититель',
  'devil': 'Дьявол',
  'servant of Ratvar': 'Слуга Ратвара',
  'syndicate mutineer': 'Мятежник Синдиката',
  'internal affairs agent': 'Агент ВД',
  'sentience potion spawn': 'Разумное существо',
  'Heretic': 'Еретик',
  'bloodsucker': 'Кровосос',
  'family boss': 'Глава семьи',
  'Space Dragon': 'Космический дракон',
  'Terror Spider': 'Паук ужаса',
  'Syndicate': 'Синдикат',
};

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
    antag_banned,
    antag_roles = [],
  } = data as any;

  return (
    <Stack vertical>
      {/* UI Settings */}
      <Stack.Item>
        <Section title="Настройки UI">
          <Stack>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Стиль UI">
                  <Button
                    content={UI_style || 'Default'}
                    onClick={() => act('set_ui_style')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Контур">
                  <Button.Checkbox
                    checked={outline_enabled}
                    content={outline_enabled ? 'Вкл.' : 'Выкл.'}
                    onClick={() => act('toggle_outline')}
                  />
                  {!!outline_enabled && (
                    <Button onClick={() => act('set_outline_color')}>
                      <ColorBox color={outline_color} mr={1} />
                    </Button>
                  )}
                </LabeledList.Item>
                <LabeledList.Item label="Подсказки">
                  <Button
                    content={screentip_pref || 'Default'}
                    onClick={() => act('set_screentip_pref')}
                  />
                  <Button onClick={() => act('set_screentip_color')}>
                    <ColorBox color={screentip_color} mr={1} />
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Изобр. подсказок">
                  <Button.Checkbox
                    checked={screentip_images}
                    content={screentip_images ? 'Вкл.' : 'Выкл.'}
                    onClick={() => act('toggle_screentip_images')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Стиль tgui">
                  <Button.Checkbox
                    checked={tgui_fancy}
                    content={tgui_fancy ? 'Красивый' : 'Простой'}
                    onClick={() => act('toggle_tgui_fancy')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Мониторы tgui">
                  <Button.Checkbox
                    checked={tgui_lock}
                    content={tgui_lock ? 'Основной' : 'Все'}
                    onClick={() => act('toggle_tgui_lock')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Широкий экран">
                  <Button.Checkbox
                    checked={widescreenpref}
                    onClick={() => act('toggle_widescreenpref')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Полный экран">
                  <Button.Checkbox
                    checked={fullscreen}
                    onClick={() => act('toggle_fullscreen')}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Горячие клавиши">
                  <Button.Checkbox
                    checked={hotkeys}
                    content={hotkeys ? 'Вкл.' : 'Выкл.'}
                    onClick={() => act('toggle_hotkeys')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Длинное меню">
                  <Button.Checkbox
                    checked={long_strip_menu}
                    onClick={() => act('toggle_long_strip_menu')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Авто-вставание">
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
                <LabeledList.Item label="Авто-заглавные">
                  <Button.Checkbox
                    checked={auto_capitalize_enabled}
                    onClick={() => act('toggle_auto_capitalize')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Тетрис-хранилище">
                  <Button.Checkbox
                    checked={!no_tetris_storage}
                    content={no_tetris_storage ? 'Выкл.' : 'Вкл.'}
                    onClick={() => act('toggle_no_tetris')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Параллакс">
                  <Button
                    content={parallax || 'Default'}
                    onClick={() => act('set_parallax')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Окклюзия">
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
        <Section title="Runechat и отображение">
          <Stack>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Runechat">
                  <Button.Checkbox
                    checked={chat_on_map}
                    content={chat_on_map ? 'Вкл.' : 'Выкл.'}
                    onClick={() => act('toggle_chat_on_map')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Лимит Runechat">
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
                <LabeledList.Item label="Runechat не-мобы">
                  <Button.Checkbox
                    checked={see_chat_non_mob}
                    onClick={() => act('toggle_see_chat_non_mob')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Runechat эмоции">
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
                <LabeledList.Item label="Авто-вьюпорт">
                  <Button.Checkbox
                    checked={auto_fit_viewport}
                    onClick={() => act('toggle_auto_fit_viewport')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Вспышка HUD">
                  <Button.Checkbox
                    checked={hud_toggle_flash}
                    onClick={() => act('toggle_hud_flash')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Цвет HUD">
                  <Button onClick={() => act('set_hud_color')}>
                    <ColorBox color={hud_toggle_color || '#ffffff'} mr={1} />
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Пиксельный сдвиг">
                  <Button.Checkbox
                    checked={view_pixelshift}
                    onClick={() => act('toggle_view_pixelshift')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Боевой курсор">
                  <Button.Checkbox
                    checked={!disable_combat_cursor}
                    content={disable_combat_cursor ? 'Выкл.' : 'Вкл.'}
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
        <Section title="Тряска экрана">
          <LabeledList>
            <LabeledList.Item label="Тряска">
              <Slider
                value={screenshake || 0}
                minValue={0}
                maxValue={100}
                step={10}
                unit="%"
                onChange={(e, value) => act('set_screenshake', { value })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Тряска от урона">
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
            <LabeledList.Item label="Отдача">
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
        <Section title="Антагонист">
          <Stack vertical>
            <Stack.Item>
              <Stack>
                <Stack.Item>
                  <Button.Checkbox
                    checked={!(toggles & NO_ANTAG)}
                    color={toggles & NO_ANTAG ? 'red' : 'green'}
                    content={
                      toggles & NO_ANTAG
                        ? 'Антагонизм выключен'
                        : 'Антагонизм включен'
                    }
                    onClick={() =>
                      act('toggle_flag', {
                        flag: 'disable_antag',
                      })
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button.Checkbox
                    checked={!!(toggles & MIDROUND_ANTAG)}
                    content="Антаг в середине"
                    onClick={() =>
                      act('toggle_flag', {
                        flag: 'midround_antag',
                      })
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    content={be_victim || 'По умолч.'}
                    icon="crosshairs"
                    tooltip="Предпочитать быть жертвой антагониста"
                    onClick={() => act('set_be_victim')}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            {antag_banned ? (
              <Stack.Item>
                <Box color="bad" bold mt={1}>
                  Вы забанены от ролей антагонистов.
                </Box>
              </Stack.Item>
            ) : (
              <Stack.Item>
                <Flex wrap="wrap" mt={1}>
                  {(antag_roles as AntagRoleInfo[]).map((role) => {
                    const label =
                      ANTAG_ROLE_NAMES[role.name] || role.name;
                    const isEnabled = role.status === 'enabled';
                    const isLow = role.status === 'low';
                    const isBanned = role.status === 'banned';
                    const isLocked = role.status === 'locked';
                    const isActive = isEnabled || isLow;
                    const borderColor = isBanned || isLocked
                      ? 'rgba(128, 128, 128, 0.5)'
                      : isActive
                        ? 'rgba(80, 200, 80, 0.9)'
                        : 'rgba(200, 60, 60, 0.6)';
                    return (
                      <Flex.Item
                        key={role.name}
                        style={{
                          width: '110px',
                          textAlign: 'center',
                          margin: '4px',
                        }}
                      >
                        <Tooltip
                          content={
                            isBanned
                              ? 'Забанен'
                              : isLocked
                                ? `Через ${role.days} дней`
                                : isEnabled
                                  ? 'Включено (высокий приоритет) — нажмите для выключения'
                                  : isLow
                                    ? 'Низкий приоритет — нажмите для повышения'
                                    : 'Выключено — нажмите для включения'
                          }
                          position="bottom"
                        >
                          <Box
                            style={{
                              cursor:
                                isBanned || isLocked
                                  ? 'not-allowed'
                                  : 'pointer',
                              opacity:
                                isBanned || isLocked
                                  ? 0.4
                                  : isActive
                                    ? 1
                                    : 0.55,
                              transition: 'all 0.15s ease',
                            }}
                            onClick={() => {
                              if (isBanned || isLocked) return;
                              act('toggle_antag_role', {
                                role: role.name,
                              });
                            }}
                          >
                            <Box
                              style={{
                                width: '80px',
                                height: '80px',
                                margin: '0 auto 4px',
                                borderRadius: '50%',
                                border: `3px solid ${borderColor}`,
                                overflow: 'hidden',
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                backgroundColor:
                                  'rgba(0, 0, 0, 0.3)',
                                position: 'relative',
                              }}
                            >
                              {role.icon_b64 ? (
                                <Box
                                  as="img"
                                  src={role.icon_b64}
                                  style={{
                                    width: '74px',
                                    height: '74px',
                                    imageRendering: 'pixelated',
                                  }}
                                />
                              ) : (
                                <Box
                                  style={{
                                    fontSize: '24px',
                                    color: 'rgba(255,255,255,0.3)',
                                  }}
                                >
                                  ?
                                </Box>
                              )}
                              {isBanned && (
                                <Box
                                  style={{
                                    position: 'absolute',
                                    width: '100%',
                                    height: '3px',
                                    backgroundColor:
                                      'rgba(180, 60, 60, 0.8)',
                                    top: '50%',
                                    left: '0',
                                    transform:
                                      'translateY(-50%) rotate(35deg)',
                                  }}
                                />
                              )}
                              {isLocked && (
                                <Box
                                  style={{
                                    position: 'absolute',
                                    bottom: '2px',
                                    fontSize: '10px',
                                    fontWeight: 'bold',
                                    textShadow:
                                      '1px 1px 2px rgba(0,0,0,0.8)',
                                    color: '#ccc',
                                  }}
                                >
                                  {role.days}д
                                </Box>
                              )}
                            </Box>
                            <Box
                              style={{
                                fontWeight: 'bold',
                                fontSize: '11px',
                                maxWidth: '110px',
                                overflow: 'hidden',
                                textOverflow: 'ellipsis',
                                whiteSpace: 'nowrap',
                                color: isBanned || isLocked
                                  ? '#777'
                                  : isEnabled
                                    ? '#6f6'
                                    : isLow
                                      ? '#ff6'
                                      : '#ccc',
                              }}
                            >
                              {label}
                            </Box>
                          </Box>
                        </Tooltip>
                      </Flex.Item>
                    );
                  })}
                </Flex>
              </Stack.Item>
            )}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
