import { classes } from 'common/react';
import { useBackend } from '../../../backend';
import {
  Box,
  Button,
  Icon,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from '../../../components';
import { CharacterSetupData } from '../types';

export type CategoryItem = {
  name: string;
  path: string;
  sprite_id: string;
  cost: number;
  description: string;
  selected: boolean;
  can_name: boolean;
  can_color: boolean;
};

export type SelectedItem = {
  path: string;
  name: string;
  color: string;
  is_heirloom: boolean;
};

export type LoadoutCategory = {
  name: string;
  subcategories: string[];
};

const CATEGORY_ICONS: Record<string, string> = {
  'In backpack': 'suitcase',
  'Neck': 'user-tie',
  'Mask': 'mask',
  'Hands': 'hand-paper',
  'Uniform': 'tshirt',
  'Accessory': 'gem',
  'Suit': 'vest-patches',
  'Head': 'hat-cowboy',
  'Shoes': 'shoe-prints',
  'Gloves': 'mitten',
  'Glasses': 'glasses',
  'Donator': 'star',
  'Unlockable': 'lock',
  'General Underwear': 'underwear',
  'Wrists': 'clock',
  'Error': 'exclamation-triangle',
};

export const LoadoutTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    loadout_slot = 1,
    loadout_enabled = true,
    gear_points = 20,
    loadout_categories = [],
    category_items = [],
    loadout_items = [],
    gear_category = '',
    gear_subcategory = '',
  } = data as any;

  const currentCat = (loadout_categories as LoadoutCategory[]).find(
    (c: LoadoutCategory) => c.name === gear_category,
  );

  return (
    <Stack fill>
      {/* Left sidebar: categories */}
      <Stack.Item basis="140px">
        <Section fill scrollable title="Категории" fitted>
          {(loadout_categories as LoadoutCategory[]).map(
            (cat: LoadoutCategory) => (
              <Button
                key={cat.name}
                fluid
                selected={gear_category === cat.name}
                icon={CATEGORY_ICONS[cat.name] || 'box'}
                content={cat.name}
                onClick={() =>
                  act('select_loadout_category', { category: cat.name })
                }
                style={{
                  textAlign: 'left',
                }}
              />
            ),
          )}
        </Section>
      </Stack.Item>

      {/* Right side: controls + items */}
      <Stack.Item grow>
        <Stack vertical fill>
          {/* Top bar */}
          <Stack.Item>
            <Stack align="center" wrap>
              <Stack.Item>
                <Box inline bold mr={1}>
                  Слот:
                </Box>
                {[1, 2, 3, 4, 5].map((i) => (
                  <Button
                    key={i}
                    compact
                    selected={loadout_slot === i}
                    color={loadout_slot === i ? 'green' : undefined}
                    content={String(i)}
                    onClick={() => act('select_loadout_slot', { slot: i })}
                  />
                ))}
              </Stack.Item>
              <Stack.Item grow>
                <Box inline ml={2} bold fontSize="14px">
                  <Icon name="coins" mr={1} />
                  Очки:{' '}
                  <Box
                    inline
                    color={
                      gear_points <= 0
                        ? 'bad'
                        : gear_points <= 3
                          ? 'average'
                          : 'good'
                    }>
                    {gear_points}
                  </Box>
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Button.Checkbox
                  checked={loadout_enabled}
                  content="Экипировка"
                  tooltip="Включить/выключить экипировку лодаута при спавне"
                  onClick={() => act('toggle_loadout_enabled')}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="trash"
                  color="bad"
                  content="Очистить"
                  onClick={() => act('clear_loadout')}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>

          {/* Subcategories - only if more than 1 */}
          {currentCat && currentCat.subcategories.length > 1 && (
            <Stack.Item>
              <Tabs fluid>
                {currentCat.subcategories.map((sub: string) => (
                  <Tabs.Tab
                    key={sub}
                    selected={gear_subcategory === sub}
                    onClick={() =>
                      act('select_loadout_subcategory', { subcategory: sub })
                    }>
                    {sub}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Stack.Item>
          )}

          {/* Selected items bar */}
          {(loadout_items as SelectedItem[]).length > 0 && (
            <Stack.Item>
              <Box
                px={1}
                py={0.5}
                style={{
                  background: 'rgba(0, 100, 0, 0.15)',
                  borderBottom: '1px solid rgba(0, 255, 0, 0.1)',
                }}>
                <Box color="good" bold mb={0.5} fontSize="11px">
                  <Icon name="check-circle" mr={1} />
                  Выбрано ({(loadout_items as SelectedItem[]).length}):
                </Box>
                <Stack wrap>
                  {(loadout_items as SelectedItem[]).map(
                    (item: SelectedItem) => (
                      <Stack.Item key={item.path}>
                        <Button
                          compact
                          icon={item.is_heirloom ? 'star' : 'times'}
                          color={item.is_heirloom ? 'orange' : undefined}
                          content={item.name}
                          onClick={() =>
                            act('toggle_gear', {
                              name: item.path,
                              toggle: 0,
                            })
                          }
                        />
                      </Stack.Item>
                    ),
                  )}
                </Stack>
              </Box>
            </Stack.Item>
          )}

          {/* Items list */}
          <Stack.Item grow>
            <Section fill scrollable>
              {(category_items as CategoryItem[]).length === 0 ? (
                <Box color="label" italic textAlign="center" mt={4}>
                  <Icon name="box-open" size={3} mb={2} />
                  <br />
                  Нет предметов в этой категории
                </Box>
              ) : (
                <Box>
                  {(category_items as CategoryItem[]).map(
                    (item: CategoryItem, index: number) => (
                      <LoadoutItemRow
                        key={item.path}
                        item={item}
                        even={index % 2 === 0}
                        pointsLeft={gear_points}
                      />
                    ),
                  )}
                </Box>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const LoadoutItemRow = (
  props: { key?: string; item: CategoryItem; even: boolean; pointsLeft: number },
  context,
) => {
  const { act } = useBackend<CharacterSetupData>(context);
  const { item, even, pointsLeft } = props;
  const cantAfford = !item.selected && item.cost > pointsLeft;
  const disabled = cantAfford;

  return (
    <Box
      px={1}
      py={0.5}
      style={{
        background: item.selected
          ? 'rgba(0, 150, 0, 0.15)'
          : even
            ? 'rgba(255,255,255,0.03)'
            : 'transparent',
        borderBottom: '1px solid rgba(255,255,255,0.05)',
      }}>
      <Stack align="center">
        {/* Icon preview */}
        <Stack.Item shrink={0}>
          <Box
            as="span"
            className={classes(['loadout32x32', item.sprite_id])}
          />
        </Stack.Item>

        {/* Toggle button */}
        <Stack.Item shrink={0}>
          <Button
            icon={item.selected ? 'check-square' : 'square'}
            color={item.selected ? 'green' : disabled ? 'grey' : undefined}
            disabled={disabled}
            onClick={() =>
              act('toggle_gear', {
                name: item.path,
                toggle: item.selected ? 0 : 1,
              })
            }
          />
        </Stack.Item>

        {/* Name + description */}
        <Stack.Item grow>
          <Box
            bold={item.selected}
            color={
              item.selected
                ? 'good'
                : disabled
                  ? 'label'
                  : undefined
            }>
            {item.name}
            {cantAfford && (
              <Box inline color="bad" ml={1} fontSize="11px">
                (не хватает очков)
              </Box>
            )}
          </Box>
          {item.description && (
            <Box color="label" fontSize="11px" mt={0.3}>
              {item.description}
            </Box>
          )}
        </Stack.Item>

        {/* Cost */}
        <Stack.Item shrink={0} basis="40px" textAlign="center">
          <Tooltip content="Стоимость">
            <Box
              bold
              color={cantAfford ? 'bad' : 'label'}
              fontSize="12px">
              <Icon name="coins" mr={0.5} />
              {item.cost}
            </Box>
          </Tooltip>
        </Stack.Item>

        {/* Actions for selected items */}
        {item.selected && (
          <Stack.Item shrink={0}>
            <Stack>
              {!!item.can_color && (
                <Stack.Item>
                  <Button
                    compact
                    icon="palette"
                    tooltip="Изменить цвет"
                    onClick={() =>
                      act('loadout_color', { name: item.path })
                    }
                  />
                </Stack.Item>
              )}
              {!!item.can_name && (
                <Stack.Item>
                  <Button
                    compact
                    icon="pen"
                    tooltip="Переименовать"
                    onClick={() =>
                      act('loadout_rename', { name: item.path })
                    }
                  />
                </Stack.Item>
              )}
              <Stack.Item>
                <Button
                  compact
                  icon="star"
                  tooltip="Реликвия"
                  onClick={() =>
                    act('loadout_heirloom', { name: item.path })
                  }
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        )}
      </Stack>
    </Box>
  );
};
