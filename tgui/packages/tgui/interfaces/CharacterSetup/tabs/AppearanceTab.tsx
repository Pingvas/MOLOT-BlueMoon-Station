import { useBackend } from '../../../backend';
import {
  Box,
  Button,
  ColorBox,
  Dropdown,
  LabeledList,
  Section,
  Stack,
} from '../../../components';
import { CharacterSetupData, MutantPartInfo } from '../types';

export const AppearanceTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);

  return (
    <Stack vertical>
      {/* Раса и тело */}
      <Stack.Item>
        <Section title="Тело">
          <Stack>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Раса">
                  <Button
                    content={data.species_name || 'Человек'}
                    icon="paw"
                    onClick={() => act('set_species')}
                  />
                </LabeledList.Item>
                {!!data.custom_species && (
                  <LabeledList.Item label="Своя раса">
                    {data.custom_species}
                  </LabeledList.Item>
                )}
                <LabeledList.Item label="Модель тела">
                  <Button
                    selected={data.body_model === 'male'}
                    content="Муж."
                    onClick={() => act('set_body_model', { model: 'male' })}
                  />
                  <Button
                    selected={data.body_model === 'female'}
                    content="Жен."
                    onClick={() => act('set_body_model', { model: 'female' })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Размер тела">
                  <Button
                    content={String(data.body_size ?? 1)}
                    onClick={() => act('set_body_size')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Телосложение">
                  <Button
                    content={data.body_weight || 'Обычное'}
                    onClick={() => act('set_body_weight')}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Цвет. схема">
                  <Button
                    content={data.color_scheme || 'Простая'}
                    onClick={() => act('toggle_color_scheme')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Фон">
                  <Dropdown
                    selected={data.bgstate}
                    options={data.bg_list || []}
                    onSelected={(value) => act('set_bgstate', {
                      value: value,
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Нечёткое">
                  <Button.Checkbox
                    checked={data.fuzzy}
                    content={data.fuzzy ? 'Да' : 'Нет'}
                    onClick={() => act('toggle_fuzzy')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Несовп. маркеры">
                  <Button.Checkbox
                    checked={data.show_mismatched_markings}
                    content={data.show_mismatched_markings
                      ? 'Показать' : 'Скрыть'}
                    onClick={() => act('toggle_mismatched_markings')}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* Цвета кожи и тела */}
      <Stack.Item>
        <Section title="Цвета">
          <Stack>
            <Stack.Item grow basis={0}>
              {!!data.use_skintones && (
                <LabeledList>
                  <LabeledList.Item label="Оттенок кожи">
                    <Button
                      content={data.skin_tone || 'Светлый'}
                      onClick={() => act('set_skin_tone')}
                    />
                  </LabeledList.Item>
                </LabeledList>
              )}
              {!!data.has_mutcolors && (
                <LabeledList>
                  <LabeledList.Item label="Основной">
                    <Button onClick={() => act('set_mutant_color', {
                      which: 'primary',
                      color: data.mcolor,
                    })}>
                      <ColorBox color={data.mcolor} mr={1} />
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Вторичный">
                    <Button onClick={() => act('set_mutant_color', {
                      which: 'secondary',
                      color: data.mcolor2,
                    })}>
                      <ColorBox color={data.mcolor2} mr={1} />
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Третичный">
                    <Button onClick={() => act('set_mutant_color', {
                      which: 'tertiary',
                      color: data.mcolor3,
                    })}>
                      <ColorBox color={data.mcolor3} mr={1} />
                    </Button>
                  </LabeledList.Item>
                </LabeledList>
              )}
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <EyeSettings />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* Волосы */}
      {!!data.has_hair && (
        <Stack.Item>
          <Section title="Волосы">
            <Stack>
              <Stack.Item grow basis={0}>
                <LabeledList>
                  <LabeledList.Item label="Причёска">
                    <Dropdown
                      selected={data.hair_style}
                      options={data.hair_styles || []}
                      onSelected={(value) => act('set_hair_style', {
                        style: value,
                      })}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Цвет волос">
                    <Button onClick={() => act('set_hair_color', {
                      color: data.hair_color,
                    })}>
                      <ColorBox color={data.hair_color} mr={1} />
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Градиент">
                    <Dropdown
                      selected={data.grad_style}
                      options={data.grad_styles || []}
                      onSelected={(value) => act('set_grad_style', {
                        style: value,
                      })}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Цвет градиента">
                    <Button onClick={() => act('set_grad_color', {
                      color: data.grad_color,
                    })}>
                      <ColorBox color={data.grad_color} mr={1} />
                    </Button>
                  </LabeledList.Item>
                </LabeledList>
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <LabeledList>
                  <LabeledList.Item label="Борода / усы">
                    <Dropdown
                      selected={data.facial_hair_style}
                      options={data.facial_hair_styles || []}
                      onSelected={(value) => act('set_facial_hair_style', {
                        style: value,
                      })}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Цвет бороды">
                    <Button onClick={() => act('set_facial_hair_color', {
                      color: data.facial_hair_color,
                    })}>
                      <ColorBox color={data.facial_hair_color} mr={1} />
                    </Button>
                  </LabeledList.Item>
                </LabeledList>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      )}

      {/* Одежда и снаряжение */}
      <Stack.Item>
        <Section title="Одежда и снаряжение">
          <Stack>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Бельё">
                  <Dropdown
                    selected={data.underwear}
                    options={data.underwear_list || []}
                    onSelected={(value) => act('set_underwear', {
                      value,
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Майка">
                  <Dropdown
                    selected={data.undershirt}
                    options={data.undershirt_list || []}
                    onSelected={(value) => act('set_undershirt', {
                      value,
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Носки">
                  <Dropdown
                    selected={data.socks}
                    options={data.socks_list || []}
                    onSelected={(value) => act('set_socks', {
                      value,
                    })}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Рюкзак">
                  <Button
                    content={(data as any).backbag || 'Рюкзак'}
                    onClick={() => act('set_backbag')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Комбинезон">
                  <Button
                    content={(data as any).jumpsuit_style || 'Костюм'}
                    onClick={() => act('toggle_jumpsuit_style')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Аплинк">
                  <Button
                    content={(data as any).uplink_spawn_loc || 'PDA'}
                    onClick={() => act('set_uplink_loc')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Сохр. шрамы">
                  <Button.Checkbox
                    checked={(data as any).persistent_scars}
                    onClick={() => act('toggle_persistent_scars')}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* Мутантные части */}
      <MutantPartsSection />

      {/* Модификации конечностей */}
      <Stack.Item>
        <Section title="Модификации конечностей">
          <Button
            fluid
            icon="wrench"
            content="Настроить конечности"
            onClick={() => act('modify_limbs')}
          />
          {data.modified_limbs && data.modified_limbs.length > 0 && (
            <Box mt={1}>
              <LabeledList>
                {data.modified_limbs.map((limb) => (
                  <LabeledList.Item key={limb.limb} label={limb.limb}>
                    {limb.type}
                    {limb.detail && ` (${limb.detail})`}
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Box>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const EyeSettings = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);

  if (!data.has_eyes) {
    return null;
  }

  return (
    <LabeledList>
      {!!data.has_eyecolor && (
        <>
          <LabeledList.Item label="Лев. глаз">
            <Button onClick={() => act('set_eye_color', {
              color: data.left_eye_color,
              side: 'left',
            })}>
              <ColorBox color={data.left_eye_color} mr={1} />
            </Button>
          </LabeledList.Item>
          {!!data.split_eye_colors && (
            <LabeledList.Item label="Прав. глаз">
              <Button onClick={() => act('set_eye_color', {
                color: data.right_eye_color,
                side: 'right',
              })}>
                <ColorBox color={data.right_eye_color} mr={1} />
              </Button>
            </LabeledList.Item>
          )}
          <LabeledList.Item label="Разный цвет">
            <Button.Checkbox
              checked={data.split_eye_colors}
              content={data.split_eye_colors ? 'Да' : 'Нет'}
              onClick={() => act('toggle_split_eyes')}
            />
          </LabeledList.Item>
        </>
      )}
      <LabeledList.Item label="Тип глаз">
        <Dropdown
          selected={data.eye_type}
          options={data.eye_types || []}
          onSelected={(value) => act('set_eye_type', { type: value })}
        />
      </LabeledList.Item>
    </LabeledList>
  );
};

const MutantPartsSection = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    available_mutant_parts = [],
    mutant_values = {},
    mutant_colors = {},
    mutant_parts = [],
  } = data;

  if (!available_mutant_parts.length) {
    return null;
  }

  const visibleParts = mutant_parts.filter(
    (part: MutantPartInfo) => available_mutant_parts.indexOf(part.id) !== -1
  );

  if (!visibleParts.length) {
    return null;
  }

  return (
    <Stack.Item>
      <Section title="Мутантные части">
        <LabeledList>
          {visibleParts.map((part: MutantPartInfo) => (
            <LabeledList.Item key={part.id} label={part.label}>
              <Stack inline>
                <Stack.Item grow>
                  <Dropdown
                    selected={mutant_values[part.id] || 'Нет'}
                    options={part.styles || []}
                    onSelected={(value) => act('set_mutant_part', {
                      part: part.id,
                      style: value,
                    })}
                  />
                </Stack.Item>
                {part.color_type && (
                  <Stack.Item>
                    <Button onClick={() => act('set_mutant_part_color', {
                      color_type: part.color_type,
                      color: mutant_colors[part.color_type] || '#ffffff',
                    })}>
                      <ColorBox
                        color={mutant_colors[part.color_type] || '#ffffff'}
                        mr={1}
                      />
                    </Button>
                  </Stack.Item>
                )}
              </Stack>
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};
