import { useBackend } from '../../../backend';
import {
  Box,
  Button,
  ColorBox,
  Divider,
  Flex,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from '../../../components';
import { CharacterSetupData } from '../types';
import { textOrFallback } from '../utils';

export const GeneralTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);

  return (
    <Stack vertical fill>
      {/* Row 1: Identity + Toggles */}
      <Stack.Item>
        <Section
          title="Идентификация"
          buttons={
            <Button
              icon="dice"
              content="Случайное имя"
              onClick={() => act('random_name')}
            />
          }>
          <Flex wrap="wrap">
            {/* Left column */}
            <Flex.Item basis="50%" grow={1} pr={1}>
              <LabeledList>
                <LabeledList.Item label="Имя">
                  <Input
                    fluid
                    value={data.real_name}
                    onInput={(e, value) => act('set_name', {
                      name: value,
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Пол">
                  <Button
                    compact
                    selected={data.gender === 'male'}
                    content="Мужской"
                    onClick={() => act('set_gender', { gender: 'male' })}
                  />
                  <Button
                    compact
                    selected={data.gender === 'female'}
                    content="Женский"
                    onClick={() => act('set_gender', { gender: 'female' })}
                  />
                  <Button
                    compact
                    selected={data.gender === 'plural'}
                    content="Множественный"
                    onClick={() => act('set_gender', { gender: 'plural' })}
                  />
                  <Button
                    compact
                    selected={data.gender === 'neuter'}
                    content="Средний"
                    onClick={() => act('set_gender', { gender: 'neuter' })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Возраст">
                  <NumberInput
                    value={data.age}
                    minValue={17}
                    maxValue={300}
                    step={1}
                    onChange={(e, value) => act('set_age', { age: value })}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Flex.Item>
            {/* Right column */}
            <Flex.Item basis="50%" grow={1} pl={1}>
              <LabeledList>
                <LabeledList.Item label="Случайное имя">
                  <Button.Checkbox
                    checked={data.be_random_name}
                    content={data.be_random_name ? 'Да' : 'Нет'}
                    onClick={() => act('toggle_random_name')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Случайное тело">
                  <Button.Checkbox
                    checked={data.be_random_body}
                    content={data.be_random_body ? 'Да' : 'Нет'}
                    onClick={() => act('toggle_random_body')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Скрыть ключ">
                  <Button.Checkbox
                    checked={data.hide_ckey}
                    content={data.hide_ckey ? 'Да' : 'Нет'}
                    onClick={() => act('toggle_hide_ckey')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Безымянный">
                  <Button.Checkbox
                    checked={data.nameless}
                    content={data.nameless ? 'Да' : 'Нет'}
                    onClick={() => act('toggle_nameless')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Скафандр+Хвост">
                  <Button.Checkbox
                    checked={data.hardsuit_with_tail}
                    content={data.hardsuit_with_tail ? 'Да' : 'Нет'}
                    onClick={() => act('toggle_hardsuit_tail')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Цвет крови">
                  <Button.Checkbox
                    checked={data.custom_blood_color}
                    onClick={() => act('toggle_custom_blood_color')}
                  />
                  {!!data.custom_blood_color && (
                    <Button
                      compact
                      icon="palette"
                      onClick={() => act('set_blood_color')}>
                      <ColorBox color={data.blood_color} mr={0.5} />
                    </Button>
                  )}
                </LabeledList.Item>
              </LabeledList>
            </Flex.Item>
          </Flex>
        </Section>
      </Stack.Item>

      {/* Row 2: Special Names + PDA + Silicon */}
      <Stack.Item>
        <Flex>
          <Flex.Item grow={1} basis="50%" pr={0.5}>
            <Section title="Особые имена">
              <SpecialNames />
            </Section>
          </Flex.Item>
          <Flex.Item grow={1} basis="50%" pl={0.5}>
            <Section title="PDA">
              <LabeledList>
                <LabeledList.Item label="Цвет">
                  <Button
                    compact
                    onClick={() => act('set_pda_color')}>
                    <ColorBox color={data.pda_color} mr={0.5} />
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Стиль">
                  <Button
                    compact
                    content={textOrFallback(data.pda_style, 'По умолч.')}
                    onClick={() => act('set_pda_style')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Скин">
                  <Button
                    compact
                    content={textOrFallback(data.pda_skin, 'По умолч.')}
                    onClick={() => act('set_pda_skin')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Рингтон">
                  <Button
                    compact
                    content={textOrFallback(data.pda_ringtone, 'По умолч.')}
                    onClick={() => act('set_pda_ringtone')}
                  />
                </LabeledList.Item>
              </LabeledList>
              <Divider />
              <Box bold mb={0.5}>Силикон</Box>
              <LabeledList>
                <LabeledList.Item label="ИИ Ядро">
                  <Button
                    compact
                    content={textOrFallback(data.preferred_ai_core_display, 'По умолч.')}
                    onClick={() => act('set_ai_core_display')}
                  />
                </LabeledList.Item>
                {!!data.allow_silicon_choosing_laws && (
                  <LabeledList.Item label="Законы">
                    <Button
                      compact
                      content={textOrFallback(data.silicon_lawset, 'По умолч.')}
                      onClick={() => act('set_silicon_lawset')}
                    />
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Section>
          </Flex.Item>
        </Flex>
      </Stack.Item>
    </Stack>
  );
};

const SpecialNames = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const { custom_names = {}, custom_name_types = [] } = data;

  if (!custom_name_types.length) {
    return null;
  }

  return (
    <LabeledList>
      {custom_name_types.map((nameType, i) => (
        <LabeledList.Item key={nameType.id} label={nameType.label}>
          <Input
            fluid
            value={custom_names[nameType.id] || ''}
            onInput={(e, value) => act('set_custom_name', {
              name_id: nameType.id,
              value: value,
            })}
          />
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
};
