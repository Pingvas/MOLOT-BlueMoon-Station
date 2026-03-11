import { useBackend } from '../../../backend';
import {
  Button,
  ColorBox,
  Dropdown,
  LabeledList,
  Section,
  Slider,
  Stack,
} from '../../../components';
import { CharacterSetupData } from '../types';

export const SpeechTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    speech_verb,
    custom_tongue,
    custom_laugh,
    languages,
    enable_personal_chat_color,
    personal_chat_color,
    bark_id,
    bark_list,
    bark_pitch,
    bark_speed,
    bark_variance,
  } = data as any;

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
            <LabeledList.Item label="Языки">
              <Button
                content={
                  languages && languages.length
                    ? languages.join(', ')
                    : 'None'
                }
                icon="language"
                onClick={() => act('set_languages')}
              />
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
    </Stack>
  );
};
