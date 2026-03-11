import { useBackend, useLocalState } from '../../../backend';
import {
  Box,
  Button,
  Section,
  Stack,
  Tabs,
} from '../../../components';
import { CharacterSetupData } from '../types';

// Static quirk info from ui_static_data
type QuirkStaticInfo = {
  name: string;
  description: string;
  value: number;
  category: string;
  conflicts: string[];
};

// Computed quirk info with dynamic state
type QuirkDisplay = QuirkStaticInfo & {
  selected: boolean;
  conflicting: boolean;
  conflict_reason: string;
};

export const QuirksTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    all_quirks = [],
    quirk_balance = 0,
    quirks_info = [],
  } = data as any;

  const selectedSet = new Set(all_quirks as string[]);

  // Compute selected/conflicting state on frontend (avoids rebuilding full quirk list in ui_data)
  const quirks: QuirkDisplay[] = (quirks_info as QuirkStaticInfo[]).map(
    (q) => {
      const selected = selectedSet.has(q.name);
      const activeConflicts = (q.conflicts || []).filter((c) =>
        selectedSet.has(c)
      );
      return {
        ...q,
        selected,
        conflicting: activeConflicts.length > 0,
        conflict_reason: activeConflicts.join(', '),
      };
    }
  );

  const [category, setCategory] = useLocalState(
    context,
    'quirk_category',
    'Positive'
  );

  const filteredQuirks = quirks.filter((q) => q.category === category);

  const selectedQuirks = quirks.filter((q) => q.selected);

  return (
    <Stack vertical>
      {/* Summary */}
      <Stack.Item>
        <Section title="Выбранные особенности">
          <Stack>
            <Stack.Item grow>
              {selectedQuirks.length > 0 ? (
                <Box>
                  {selectedQuirks.map((q) => (
                    <Button
                      key={q.name}
                      content={`${q.name} (${q.value > 0 ? '+' : ''}${q.value})`}
                      color={q.value > 0 ? 'green' : q.value < 0 ? 'red' : 'yellow'}
                      onClick={() => act('toggle_quirk', { name: q.name })}
                    />
                  ))}
                </Box>
              ) : (
                <Box color="label" italic>Особенности не выбраны</Box>
              )}
            </Stack.Item>
            <Stack.Item>
              <Box bold>
                Баланс: {quirk_balance} очк.
              </Box>
            </Stack.Item>
          </Stack>
          <Box mt={1}>
            <Button
              icon="undo"
              content="Сбросить все"
              color="red"
              onClick={() => act('reset_quirks')}
            />
          </Box>
        </Section>
      </Stack.Item>

      {/* Quirk settings */}
      <Stack.Item>
        <Section title="Настройки">
          <Stack>
            <Stack.Item>
              <Button
                icon="volume-up"
                content="Тип крика"
                onClick={() => act('change_shriek_option')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="tag"
                content="Прозвище призыва"
                onClick={() => act('set_summon_nickname')}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* Category tabs */}
      <Stack.Item>
        <Tabs fluid>
          <Tabs.Tab
            selected={category === 'Positive'}
            onClick={() => setCategory('Positive')}>
            Положительные
          </Tabs.Tab>
          <Tabs.Tab
            selected={category === 'Neutral'}
            onClick={() => setCategory('Neutral')}>
            Нейтральные
          </Tabs.Tab>
          <Tabs.Tab
            selected={category === 'Negative'}
            onClick={() => setCategory('Negative')}>
            Отрицательные
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>

      {/* Quirk list */}
      <Stack.Item>
        <Section fill scrollable>
          <Stack vertical>
            {filteredQuirks.map((quirk) => (
              <Stack.Item key={quirk.name}>
                <Button
                  fluid
                  selected={quirk.selected}
                  disabled={quirk.conflicting && !quirk.selected}
                  onClick={() => act('toggle_quirk', { name: quirk.name })}>
                  <Stack>
                    <Stack.Item grow>
                      <Box bold inline>
                        {quirk.name}
                      </Box>
                      <Box color="label" fontSize="11px">
                        {quirk.description}
                      </Box>
                      {quirk.conflicting && !quirk.selected && (
                        <Box color="bad" fontSize="11px">
                          Заблокировано: {quirk.conflict_reason}
                        </Box>
                      )}
                    </Stack.Item>
                    <Stack.Item>
                      <Box bold color={quirk.value > 0 ? 'green' : quirk.value < 0 ? 'red' : 'yellow'}>
                        {quirk.value > 0 ? '+' : ''}{quirk.value}
                      </Box>
                    </Stack.Item>
                  </Stack>
                </Button>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
