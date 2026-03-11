import { useBackend } from '../../../backend';
import {
  Box,
  Button,
  ColorBox,
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
    <Stack vertical>
      {/* Identity — the most important section */}
      <Stack.Item>
        <Section title="Индентификация">
          <Stack>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Имя">
                  <Stack inline>
                    <Stack.Item grow>
                      <Input
                        fluid
                        value={data.real_name}
                        onInput={(e, value) => act('set_name', {
                          name: value,
                        })}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="dice"
                        tooltip="Случайное имя"
                        onClick={() => act('random_name')}
                      />
                    </Stack.Item>
                  </Stack>
                </LabeledList.Item>
                <LabeledList.Item label="Пол">
                  <Button
                    selected={data.gender === 'male'}
                    content="М"
                    onClick={() => act('set_gender', { gender: 'male' })}
                  />
                  <Button
                    selected={data.gender === 'female'}
                    content="Ж"
                    onClick={() => act('set_gender', { gender: 'female' })}
                  />
                  <Button
                    selected={data.gender === 'plural'}
                    content="Мн."
                    onClick={() => act('set_gender', { gender: 'plural' })}
                  />
                  <Button
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
                <LabeledList.Item label="Отдел СБ">
                  <Button
                    content={data.prefered_security_department || 'Не выбран'}
                    onClick={() => act('set_security_dept')}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item grow basis={0}>
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
                      icon="palette"
                      onClick={() => act('set_blood_color')}>
                      <ColorBox color={data.blood_color} mr={1} />
                    </Button>
                  )}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* Occupation + Quirks row */}
      <Stack.Item>
        <Stack>
          <Stack.Item grow basis={0}>
            <Section title="Работа">
              <Button
                fluid
                icon="briefcase"
                content="Настроить должности"
                onClick={() => act('open_job_menu')}
              />
            </Section>
          </Stack.Item>
          {!!data.roundstart_traits && (
            <Stack.Item grow basis={0}>
              <Section title="Особенности"
                buttons={
                  <Box inline color="label">
                    Баланс: {data.quirk_balance ?? 0}
                  </Box>
                }>
                <Button
                  fluid
                  icon="star"
                  content="Настроить особенности"
                  onClick={() => act('open_quirk_menu')}
                />
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>

      {/* Custom names + Game specifics */}
      <Stack.Item>
        <Stack>
          <Stack.Item grow basis={0}>
            <Section title="Особые имена">
              <SpecialNames />
            </Section>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Stack vertical>
              <Stack.Item>
                <Section title="PDA">
                  <LabeledList>
                    <LabeledList.Item label="Цвет">
                      <Button onClick={() => act('set_pda_color')}>
                        <ColorBox color={data.pda_color} mr={1} />
                      </Button>
                    </LabeledList.Item>
                    <LabeledList.Item label="Стиль">
                      <Button
                        content={data.pda_style || 'По умолч.'}
                        onClick={() => act('set_pda_style')}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Скин">
                      <Button
                        content={data.pda_skin || 'По умолч.'}
                        onClick={() => act('set_pda_skin')}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Рингтон">
                      <Button
                        content={data.pda_ringtone || 'По умолч.'}
                        onClick={() => act('set_pda_ringtone')}
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section title="Силикон">
                  <LabeledList>
                    <LabeledList.Item label="ИИ Ядро">
                      <Button
                        content={data.preferred_ai_core_display || 'По умолч.'}
                        onClick={() => act('set_ai_core_display')}
                      />
                    </LabeledList.Item>
                    {!!data.allow_silicon_choosing_laws && (
                      <LabeledList.Item label="Законы">
                        <Button
                          content={data.silicon_lawset || 'По умолч.'}
                          onClick={() => act('set_silicon_lawset')}
                        />
                      </LabeledList.Item>
                    )}
                  </LabeledList>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
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
      {custom_name_types.map((nameType) => (
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
