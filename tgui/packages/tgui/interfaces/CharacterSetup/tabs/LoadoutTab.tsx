import { useBackend, useLocalState } from '../../../backend';
import {
  Box,
  Button,
  Section,
  Stack,
  Table,
  Tabs,
} from '../../../components';
import { CharacterSetupData } from '../types';

// Items in current category (from category_items backend data)
export type CategoryItem = {
  name: string;
  path: string;
  cost: number;
  description: string;
  selected: boolean;
  can_name: boolean;
  can_color: boolean;
};

// Items the player has selected (from loadout_items backend data)
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

export const LoadoutTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    loadout_slot = 1,
    loadout_enabled = true,
    gear_points = 20,
    loadout_categories = [],
    category_items = [],
    gear_category,
    gear_subcategory,
  } = data as any;

  const [activeCategory, setActiveCategory] = useLocalState(
    context,
    'loadout_category',
    gear_category || (loadout_categories.length > 0
      ? loadout_categories[0].name : ''),
  );

  const currentCat = (loadout_categories as LoadoutCategory[]).find(
    (c: LoadoutCategory) => c.name === activeCategory,
  );

  const [activeSub, setActiveSub] = useLocalState(
    context,
    'loadout_subcategory',
    gear_subcategory || (currentCat?.subcategories?.length
      ? currentCat.subcategories[0] : ''),
  );

  return (
    <Stack vertical>
      {/* Top bar: slot selector + toggle */}
      <Stack.Item>
        <Stack>
          <Stack.Item>
            <Box bold inline mr={1}>Slot:</Box>
            {[1, 2, 3, 4, 5].map((i) => (
              <Button
                key={i}
                selected={loadout_slot === i}
                content={String(i)}
                onClick={() => act('select_loadout_slot', { slot: i })}
              />
            ))}
          </Stack.Item>
          <Stack.Item grow>
            <Box inline ml={2}>
              Points: {gear_points}
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Button.Checkbox
              checked={loadout_enabled}
              content="Loadout Enabled"
              onClick={() => act('toggle_loadout_enabled')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="trash"
              color="red"
              content="Clear"
              onClick={() => act('clear_loadout')}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>

      {/* Categories */}
      <Stack.Item>
        <Tabs fluid>
          {(loadout_categories as LoadoutCategory[]).map(
            (cat: LoadoutCategory) => (
              <Tabs.Tab
                key={cat.name}
                selected={activeCategory === cat.name}
                onClick={() => {
                  setActiveCategory(cat.name);
                  act('select_loadout_category', { category: cat.name });
                  if (cat.subcategories.length) {
                    setActiveSub(cat.subcategories[0]);
                  }
                }}>
                {cat.name}
              </Tabs.Tab>
            ),
          )}
        </Tabs>
      </Stack.Item>

      {/* Subcategories */}
      {currentCat && currentCat.subcategories.length > 0 && (
        <Stack.Item>
          <Tabs fluid>
            {currentCat.subcategories.map((sub: string) => (
              <Tabs.Tab
                key={sub}
                selected={activeSub === sub}
                onClick={() => {
                  setActiveSub(sub);
                  act('select_loadout_subcategory', { subcategory: sub });
                }}>
                {sub}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
      )}

      {/* Items table */}
      <Stack.Item>
        <Section fill scrollable>
          <Table>
            <Table.Row header>
              <Table.Cell />
              <Table.Cell>Name</Table.Cell>
              <Table.Cell>Cost</Table.Cell>
              <Table.Cell>Description</Table.Cell>
            </Table.Row>
            {(category_items as CategoryItem[]).map((item: CategoryItem) => (
              <Table.Row
                key={item.path}
                className={item.selected ? 'candystripe' : ''}>
                <Table.Cell collapsing>
                  <Button
                    icon={item.selected ? 'check-square-o' : 'square-o'}
                    color={item.selected ? 'green' : undefined}
                    onClick={() => act('toggle_gear', {
                      name: item.path,
                      toggle: item.selected ? 0 : 1,
                    })}
                  />
                </Table.Cell>
                <Table.Cell bold={item.selected}>
                  {item.name}
                </Table.Cell>
                <Table.Cell collapsing>
                  {item.cost}
                </Table.Cell>
                <Table.Cell>
                  <Box color="label" fontSize="11px">
                    {item.description}
                  </Box>
                  {item.selected && (
                    <LoadoutItemActions item={item} />
                  )}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const LoadoutItemActions = (props: { item: CategoryItem }, context) => {
  const { act } = useBackend<CharacterSetupData>(context);
  const { item } = props;

  return (
    <Box mt={1}>
      <Stack wrap>
        {!!item.can_color && (
          <Stack.Item>
            <Button
              icon="palette"
              content="Color"
              onClick={() => act('loadout_color', { name: item.path })}
            />
          </Stack.Item>
        )}
        {!!item.can_name && (
          <Stack.Item>
            <Button
              icon="pen"
              content="Rename"
              onClick={() => act('loadout_rename', { name: item.path })}
            />
          </Stack.Item>
        )}
        <Stack.Item>
          <Button
            icon="star"
            content="Heirloom"
            onClick={() => act('loadout_heirloom', { name: item.path })}
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};
