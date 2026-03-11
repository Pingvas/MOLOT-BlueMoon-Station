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
      {/* Speech Settings */}
      <Stack.Item>
        <Section title="Speech">
          <LabeledList>
            <LabeledList.Item label="Speech Verb">
              <Button
                content={speech_verb || 'Default'}
                icon="comment"
                onClick={() => act('set_speech_verb')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Custom Tongue">
              <Button
                content={custom_tongue || 'default'}
                onClick={() => act('set_custom_tongue')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Laugh">
              <Stack inline>
                <Stack.Item>
                  <Button
                    content={custom_laugh || 'Default'}
                    onClick={() => act('set_custom_laugh')}
                  />
                </Stack.Item>
                {custom_laugh && custom_laugh !== 'Default' && (
                  <Stack.Item>
                    <Button
                      icon="play"
                      tooltip="Preview Laugh"
                      onClick={() => act('preview_laugh')}
                    />
                  </Stack.Item>
                )}
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item label="Languages">
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
            <LabeledList.Item label="Runechat Color">
              <Button.Checkbox
                checked={enable_personal_chat_color}
                content="Custom"
                onClick={() => act('toggle_personal_chat_color')}
              />
              {!!enable_personal_chat_color && (
                <Button onClick={() => act('set_personal_chat_color')}>
                  <ColorBox color={personal_chat_color || '#ffffff'} mr={1} />
                  Change
                </Button>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

      {/* Bark */}
      <Stack.Item>
        <Section title="Bark Sound">
          <LabeledList>
            <LabeledList.Item label="Sound">
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
                    tooltip="Preview"
                    onClick={() => act('preview_bark')}
                  />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item label="Pitch">
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
            <LabeledList.Item label="Speed">
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
            <LabeledList.Item label="Variance">
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
