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
                    content="М"
                    onClick={() => act('set_gender', { gender: 'male' })}
                  />
                  <Button
                    compact
                    selected={data.gender === 'female'}
                    content="Ж"
                    onClick={() => act('set_gender', { gender: 'female' })}
                  />
                  <Button
                    compact
                    selected={data.gender === 'plural'}
                    content="Мн."
                    onClick={() => act('set_gender', { gender: 'plural' })}
                  />
                  <Button
                    compact
                    selected={data.gender === 'neuter'}
                    content="Ср."
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
                <LabeledList.Item label="Случ. имя">
                  <Button.Checkbox
                    checked={data.be_random_name}
                    content={data.be_random_name ? 'Да' : 'Нет'}
                    onClick={() => act('toggle_random_name')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Случ. тело">
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

      {/* Row 2: Occupation + Quirks */}
      <Stack.Item>
        <Flex>
          <Flex.Item grow={1} basis="50%" pr={0.5}>
            <Section title="Работа">
              <Button
                fluid
                icon="briefcase"
                content="Настроить должности"
                onClick={() => act('set_character_tab', { tab: 7 })}
              />
              <Box mt={1}>
                <LabeledList>
                  <LabeledList.Item label="Отдел СБ">
                    <Button
                      compact
                      content={data.prefered_security_department || 'Random'}
                      onClick={() => act('set_security_dept')}
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Box>
            </Section>
          </Flex.Item>
          {!!data.roundstart_traits && (
            <Flex.Item grow={1} basis="50%" pl={0.5}>
              <Section
                title="Особенности"
                buttons={
                  <Box inline bold color="label">
                    Баланс: {data.quirk_balance ?? 0}
                  </Box>
                }>
                <Button
                  fluid
                  icon="star"
                  content="Настроить особенности"
                  onClick={() => act('set_character_tab', { tab: 6 })}
                />
              </Section>
            </Flex.Item>
          )}
        </Flex>
      </Stack.Item>

      {/* Row 3: Special Names + PDA + Silicon */}
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
                    content={data.pda_style || 'По умолч.'}
                    onClick={() => act('set_pda_style')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Скин">
                  <Button
                    compact
                    content={data.pda_skin || 'По умолч.'}
                    onClick={() => act('set_pda_skin')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Рингтон">
                  <Button
                    compact
                    content={data.pda_ringtone || 'По умолч.'}
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
                    content={data.preferred_ai_core_display || 'По умолч.'}
                    onClick={() => act('set_ai_core_display')}
                  />
                </LabeledList.Item>
                {!!data.allow_silicon_choosing_laws && (
                  <LabeledList.Item label="Законы">
                    <Button
                      compact
                      content={data.silicon_lawset || 'По умолч.'}
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
        <LabeledList.Item label={nameType.label}>
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
