import { useBackend, useLocalState } from '../../../backend';
import {
  Box,
  Button,
  ColorBox,
  Dropdown,
  LabeledList,
  Section,
  Stack,
  Tabs,
} from '../../../components';
import { CharacterSetupData, MutantPartInfo } from '../types';
import { resolveOptionValue, sanitizeStringOptions, textOrFallback } from '../utils';

type AppearanceSubtab =
  | 'body'
  | 'colors'
  | 'hair'
  | 'wearables'
  | 'mutant_parts'
  | 'limbs';

export const AppearanceTab = (_props, context) => {
  const [subtab, setSubtab] = useLocalState<AppearanceSubtab>(
    context,
    'appearance_subtab_v2',
    'body',
  );

  return (
    <Stack vertical>
      <Stack.Item>
        <Tabs fluid>
          <Tabs.Tab
            selected={subtab === 'body'}
            icon="user"
            onClick={() => setSubtab('body')}>
            Тело
          </Tabs.Tab>
          <Tabs.Tab
            selected={subtab === 'colors'}
            icon="palette"
            onClick={() => setSubtab('colors')}>
            Цвета
          </Tabs.Tab>
          <Tabs.Tab
            selected={subtab === 'hair'}
            icon="cut"
            onClick={() => setSubtab('hair')}>
            Волосы
          </Tabs.Tab>
          <Tabs.Tab
            selected={subtab === 'wearables'}
            icon="tshirt"
            onClick={() => setSubtab('wearables')}>
            Одежда
          </Tabs.Tab>
          <Tabs.Tab
            selected={subtab === 'mutant_parts'}
            icon="paw"
            onClick={() => setSubtab('mutant_parts')}>
            Части тела
          </Tabs.Tab>
          <Tabs.Tab
            selected={subtab === 'limbs'}
            icon="wrench"
            onClick={() => setSubtab('limbs')}>
            Конечности
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>

      <Stack.Item>
        {subtab === 'body' && <BodyTab />}
        {subtab === 'colors' && <ColorsTab />}
        {subtab === 'hair' && <HairTab />}
        {subtab === 'wearables' && <WearablesTab />}
        {subtab === 'mutant_parts' && <MutantPartsTab />}
        {subtab === 'limbs' && <LimbsTab />}
      </Stack.Item>
    </Stack>
  );
};

const ColorActionButton = (props: {
  color?: string;
  onClick: () => void;
}) => {
  const { color = '#ffffff', onClick } = props;
  return (
    <Button onClick={onClick}>
      <ColorBox color={color} mr={1} />
      {color}
    </Button>
  );
};

const BodyTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  return (
    <Stack>
      <Stack.Item grow basis={0}>
        <Section title="Species & Build">
          <LabeledList>
            <LabeledList.Item label="Раса">
              <Button
                content={textOrFallback(data.species_name, 'Человек')}
                icon="paw"
                onClick={() => act('set_species')}
              />
            </LabeledList.Item>
            {!!data.custom_species && (
              <LabeledList.Item label="Кастомная раса">
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
                content={textOrFallback(data.body_weight, 'Обычное')}
                onClick={() => act('set_body_weight')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow basis={0}>
        <Section title="Стиль превью">
          <LabeledList>
            <LabeledList.Item label="Цветовая схема">
              <Button
                content={textOrFallback(data.color_scheme, 'Классическая')}
                onClick={() => act('toggle_color_scheme')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Фон">
              <Dropdown
                selected={resolveOptionValue(data.bgstate, data.bg_list || [])}
                options={sanitizeStringOptions(data.bg_list || [])}
                onSelected={(value) => act('set_bgstate', { value })}
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
                content={data.show_mismatched_markings ? 'Показать' : 'Скрыть'}
                onClick={() => act('toggle_mismatched_markings')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const ColorsTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  return (
    <Stack>
      <Stack.Item grow basis={0}>
        <Section title="Цвета кожи и тела">
          <LabeledList>
            {!!data.use_skintones && (
              <LabeledList.Item label="Оттенок кожи">
                <Button
                  content={textOrFallback(data.skin_tone, 'По умолчанию')}
                  onClick={() => act('set_skin_tone')}
                />
              </LabeledList.Item>
            )}
            {!!data.has_mutcolors && (
              <>
                <LabeledList.Item label="Основной">
                  <ColorActionButton
                    color={data.mcolor}
                    onClick={() => act('set_mutant_color', {
                      which: 'primary',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Вторичный">
                  <ColorActionButton
                    color={data.mcolor2}
                    onClick={() => act('set_mutant_color', {
                      which: 'secondary',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Третичный">
                  <ColorActionButton
                    color={data.mcolor3}
                    onClick={() => act('set_mutant_color', {
                      which: 'tertiary',
                    })}
                  />
                </LabeledList.Item>
              </>
            )}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow basis={0}>
        <Section title="Глаза">
          {!data.has_eyes && (
            <Box color="label">У этой расы нет настройки глаз.</Box>
          )}
          {!!data.has_eyes && (
            <LabeledList>
              {!!data.has_eyecolor && (
                <>
                  <LabeledList.Item label="Левый глаз">
                    <ColorActionButton
                      color={data.left_eye_color}
                      onClick={() => act('set_eye_color', {
                        side: 'left',
                      })}
                    />
                  </LabeledList.Item>
                  {!!data.split_eye_colors && (
                    <LabeledList.Item label="Правый глаз">
                      <ColorActionButton
                        color={data.right_eye_color}
                        onClick={() => act('set_eye_color', {
                          side: 'right',
                        })}
                      />
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
                  selected={resolveOptionValue(data.eye_type, data.eye_types || [])}
                  options={sanitizeStringOptions(data.eye_types || [])}
                  onSelected={(value) => act('set_eye_type', { type: value })}
                />
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const HairTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  if (!data.has_hair) {
    return (
      <Section title="Волосы">
        <Box color="label">У этой расы нет настройки волос.</Box>
      </Section>
    );
  }

  return (
    <Stack>
      <Stack.Item grow basis={0}>
        <Section title="Волосы">
          <LabeledList>
            <LabeledList.Item label="Стиль">
              <Dropdown
                selected={resolveOptionValue(data.hair_style, data.hair_styles || [])}
                options={sanitizeStringOptions(data.hair_styles || [])}
                onSelected={(value) => act('set_hair_style', {
                  style: value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Цвет">
              <ColorActionButton
                color={data.hair_color}
                onClick={() => act('set_hair_color')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Градиент">
              <Dropdown
                selected={resolveOptionValue(data.grad_style, data.grad_styles || [])}
                options={sanitizeStringOptions(data.grad_styles || [])}
                onSelected={(value) => act('set_grad_style', {
                  style: value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Цвет градиента">
              <ColorActionButton
                color={data.grad_color}
                onClick={() => act('set_grad_color')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow basis={0}>
        <Section title="Борода/усы">
          <LabeledList>
            <LabeledList.Item label="Стиль">
              <Dropdown
                selected={resolveOptionValue(data.facial_hair_style, data.facial_hair_styles || [])}
                options={sanitizeStringOptions(data.facial_hair_styles || [])}
                onSelected={(value) => act('set_facial_hair_style', {
                  style: value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Цвет">
              <ColorActionButton
                color={data.facial_hair_color}
                onClick={() => act('set_facial_hair_color')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

  const WearablesTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const underwearOptions = sanitizeStringOptions(data.underwear_list || []);
  const undershirtOptions = sanitizeStringOptions(data.undershirt_list || []);
  const socksOptions = sanitizeStringOptions(data.socks_list || []);

  return (
    <Stack>
      <Stack.Item grow basis={0}>
        <Section title="Нижнее бельё">
          <LabeledList>
            <LabeledList.Item label="Бельё">
              <Dropdown
                selected={resolveOptionValue(data.underwear, underwearOptions)}
                options={underwearOptions}
                onSelected={(value) => act('set_underwear', {
                  value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Майка">
              <Dropdown
                selected={resolveOptionValue(data.undershirt, undershirtOptions)}
                options={undershirtOptions}
                onSelected={(value) => act('set_undershirt', {
                  value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Носки">
              <Dropdown
                selected={resolveOptionValue(data.socks, socksOptions)}
                options={socksOptions}
                onSelected={(value) => act('set_socks', {
                  value,
                })}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow basis={0}>
        <Section title="Снаряжение">
          <LabeledList>
            <LabeledList.Item label="Рюкзак">
              <Button
                content={textOrFallback(data.backbag, 'Рюкзак')}
                onClick={() => act('set_backbag')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Комбинезон">
              <Button
                content={textOrFallback(data.jumpsuit_style, 'Костюм')}
                onClick={() => act('toggle_jumpsuit_style')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Аплинк">
              <Button
                content={textOrFallback(data.uplink_spawn_loc, 'PDA')}
                onClick={() => act('set_uplink_loc')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Сохр. шрамы">
              <Button.Checkbox
                checked={data.persistent_scars}
                content={data.persistent_scars ? 'Да' : 'Нет'}
                onClick={() => act('toggle_persistent_scars')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const MutantPartsTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    available_mutant_parts = [],
    mutant_values = {},
    mutant_colors = {},
    mutant_parts = [],
  } = data;

  const visibleParts = mutant_parts.filter(
    (part: MutantPartInfo) => available_mutant_parts.includes(part.id),
  );

  if (!visibleParts.length) {
    return (
      <Section title="Мутантные части">
        <Box color="label">Для этой расы нет настраиваемых частей.</Box>
      </Section>
    );
  }

  return (
    <Section title="Мутантные части">
      <LabeledList>
        {visibleParts.map((part: MutantPartInfo) => (
          <LabeledList.Item key={part.id} label={part.label}>
            <Stack inline>
              <Stack.Item grow>
                <Dropdown
                  selected={resolveOptionValue(mutant_values[part.id], part.styles || [], 'Нет')}
                  options={sanitizeStringOptions(part.styles || [])}
                  onSelected={(value) => act('set_mutant_part', {
                    part: part.id,
                    style: value,
                  })}
                />
              </Stack.Item>
              {part.color_type && (
                <Stack.Item>
                  <ColorActionButton
                    color={mutant_colors[part.color_type] || '#ffffff'}
                    onClick={() => act('set_mutant_part_color', {
                      color_type: part.color_type,
                    })}
                  />
                </Stack.Item>
              )}
            </Stack>
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

const LimbsTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  return (
    <Section title="Модификации конечностей">
      <Button
        fluid
        icon="wrench"
        content="Настроить конечности"
        onClick={() => act('modify_limbs')}
      />
      {!!data.modified_limbs?.length && (
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
  );
};
