import { useBackend } from '../../../backend';
import {
  Box,
  Button,
  ColorBox,
  Dropdown,
  LabeledList,
  Section,
  Slider,
  Stack,
} from '../../../components';
import { CharacterSetupData, LanguageInfo } from '../types';

export const SpeechTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    speech_verb,
    custom_tongue,
    custom_laugh,
    languages,
    available_languages,
    max_languages,
    enable_personal_chat_color,
    personal_chat_color,
    bark_id,
    bark_list,
    bark_pitch,
    bark_speed,
    bark_variance,
  } = data as any;

  const selectedLangs = (available_languages || []).filter(
    (l: LanguageInfo) => l.selected
  );
  const unselectedLangs = (available_languages || []).filter(
    (l: LanguageInfo) => !l.selected
  );
  const isAtLimit =
    max_languages !== -1 && selectedLangs.length >= max_languages;

  return (
    <Stack vertical>
      {/* Настройки речи */}
      <Stack.Item>
        <Section title="Речь">
          <LabeledList>
            <LabeledList.Item label="Глагол речи">
              <Button
                content={speech_verb || 'Default'}
                icon="comment"
                onClick={() => act('set_speech_verb')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Язык">
              <Button
                content={custom_tongue || 'обычный'}
                onClick={() => act('set_custom_tongue')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Смех">
              <Stack inline>
                <Stack.Item>
                  <Button
                    content={custom_laugh || 'По умолч.'}
                    onClick={() => act('set_custom_laugh')}
                  />
                </Stack.Item>
                {custom_laugh && custom_laugh !== 'Default' && (
                  <Stack.Item>
                    <Button
                      icon="play"
                      tooltip="Предпрослушать"
                      onClick={() => act('preview_laugh')}
                    />
                  </Stack.Item>
                )}
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item label="Цвет Runechat">
              <Button.Checkbox
                checked={enable_personal_chat_color}
                content="Свой цвет"
                onClick={() => act('toggle_personal_chat_color')}
              />
              {!!enable_personal_chat_color && (
                <Button onClick={() => act('set_personal_chat_color')}>
                  <ColorBox color={personal_chat_color || '#ffffff'} mr={1} />
                </Button>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

      {/* Голос */}
      <Stack.Item>
        <Section title="Голос">
          <LabeledList>
            <LabeledList.Item label="Звук">
              <Stack inline>
                <Stack.Item grow>
                  <Dropdown
                    selected={bark_id}
                    options={bark_list || []}
                    onSelected={(value) => act('set_bark_sound', {
                      bark: value,
                    })}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="play"
                    tooltip="Предпрослушать"
                    onClick={() => act('preview_bark')}
                  />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item label="Тон">
              <Slider
                value={bark_pitch ?? 1}
                minValue={0.5}
                maxValue={2}
                step={0.1}
                onChange={(e, value) => act('set_bark_pitch', {
                  value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Скорость">
              <Slider
                value={bark_speed ?? 4}
                minValue={1}
                maxValue={10}
                step={1}
                onChange={(e, value) => act('set_bark_speed', {
                  value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Вариация">
              <Slider
                value={bark_variance ?? 0}
                minValue={0}
                maxValue={100}
                step={5}
                onChange={(e, value) => act('set_bark_variance', {
                  value,
                })}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

      {/* Языки */}
      <Stack.Item>
        <Section
          title="Языки"
          buttons={
            <Stack inline align="center">
              <Stack.Item>
                <Box inline color="label" mr={1}>
                  {max_languages === -1
                    ? `Выбрано: ${selectedLangs.length}`
                    : `${selectedLangs.length} / ${max_languages}`}
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="undo"
                  content="Сбросить"
                  color="bad"
                  onClick={() => act('reset_languages')}
                />
              </Stack.Item>
            </Stack>
          }>
          {(available_languages || []).map((lang: LanguageInfo) => (
            <Box
              key={lang.name}
              mb={0.5}
              style={{
                padding: '4px 6px',
                borderRadius: '3px',
                background: lang.selected
                  ? 'rgba(80, 180, 80, 0.15)'
                  : 'rgba(255, 255, 255, 0.03)',
                opacity: !lang.selected && isAtLimit ? 0.5 : 1,
                cursor:
                  !lang.selected && isAtLimit ? 'not-allowed' : 'pointer',
              }}
              onClick={() => {
                if (!lang.selected && isAtLimit) return;
                act('toggle_language', { language_name: lang.name });
              }}>
              <Box>
                <Box
                  inline
                  style={{
                    width: '16px',
                    textAlign: 'center',
                    marginRight: '4px',
                  }}
                  color={lang.selected ? 'green' : 'label'}>
                  {lang.selected ? '\u2714' : '\u2610'}
                </Box>
                <Box
                  as="img"
                  inline
                  src={lang.icon_b64}
                  style={{
                    width: '20px',
                    height: '20px',
                    verticalAlign: 'middle',
                    marginRight: '6px',
                    imageRendering: 'pixelated',
                  }}
                />
                <b>{lang.name}</b>
              </Box>
              {!!lang.desc && (
                <Box
                  color="label"
                  mt={0.3}
                  italic
                  style={{ fontSize: '11px', paddingLeft: '46px' }}>
                  {lang.desc}
                </Box>
              )}
            </Box>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};
