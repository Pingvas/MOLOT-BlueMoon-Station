import { useBackend } from '../../../backend';
import {
  Box,
  Button,
  Section,
  Stack,
  Table,
  Tabs,
} from '../../../components';
import { CharacterSetupData } from '../types';

interface KeybindingInfo {
  name: string;
  full_name: string;
  description: string;
  category: string;
  default_keys: string[];
}

interface KeybindingsData {
  keybinding_categories: Record<string, KeybindingInfo[]>;
  user_bindings: Record<string, string[]>;
  user_modless_bindings: Record<string, string>;
  hotkeys: boolean;
}

export const KeybindingsTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    keybinding_categories = {},
    user_bindings = {},
    user_modless_bindings = {},
    hotkeys = true,
  } = data as any as KeybindingsData;

  const categories = Object.keys(keybinding_categories);
  const selectedCategory = (data as any).kb_category || categories[0] || '';

  const currentBindings = keybinding_categories[selectedCategory] || [];

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Stack>
          <Stack.Item>
            <Button
              icon="undo"
              content="Сбросить все"
              color="bad"
              onClick={() => act('reset_keybinds')}
            />
          </Stack.Item>
          <Stack.Item grow />
          <Stack.Item>
            <Button.Checkbox
              checked={hotkeys}
              content={hotkeys ? 'Горячие клавиши' : 'Классический'}
              onClick={() => act('toggle_hotkeys')}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Tabs>
          {categories.map((cat) => (
            <Tabs.Tab
              key={cat}
              selected={cat === selectedCategory}
              onClick={() => act('select_kb_category', { category: cat })}
            >
              {cat}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          <Table>
            <Table.Row header>
              <Table.Cell>Действие</Table.Cell>
              <Table.Cell>Назначено</Table.Cell>
              <Table.Cell>Независимая</Table.Cell>
              <Table.Cell>По умолч.</Table.Cell>
            </Table.Row>
            {currentBindings.map((kb) => {
              const bindings = user_bindings[kb.name] || [];
              const independentKey = user_modless_bindings[kb.name] || '';
              return (
                <Table.Row key={kb.name}>
                  <Table.Cell>
                    <Box bold>{kb.full_name}</Box>
                    {!!kb.description && (
                      <Box fontSize="10px" color="label">
                        {kb.description}
                      </Box>
                    )}
                  </Table.Cell>
                  <Table.Cell>
                    {bindings.length > 0 ? (
                      bindings.map((key, idx) => (
                        <Button
                          key={idx}
                          content={key}
                          onClick={() =>
                            act('capture_keybinding', {
                              keybinding: kb.name,
                              old_key: key,
                            })}
                        />
                      ))
                    ) : (
                      <Button
                        color="bad"
                        content="Не назн."
                        onClick={() =>
                          act('capture_keybinding', {
                            keybinding: kb.name,
                            old_key: 'Unbound',
                          })}
                      />
                    )}
                    <Button
                      icon="plus"
                      onClick={() =>
                        act('capture_keybinding', {
                          keybinding: kb.name,
                          old_key: 'Unbound',
                        })}
                    />
                  </Table.Cell>
                  <Table.Cell>
                    <Button
                      content={independentKey || 'Не назн.'}
                      color={independentKey ? 'default' : 'bad'}
                      onClick={() =>
                        act('capture_keybinding', {
                          keybinding: kb.name,
                          old_key: independentKey || 'Unbound',
                          independent: 1,
                        })}
                    />
                  </Table.Cell>
                  <Table.Cell color="label">
                    {(kb.default_keys || []).join(', ') || 'None'}
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
