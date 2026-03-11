import { useBackend, useLocalState } from '../../../backend';
import {
  Box,
  Button,
  Section,
  Stack,
  Tabs,
} from '../../../components';
import { CharacterSetupData } from '../types';

export type QuirkInfo = {
  name: string;
  description: string;
  value: number;
  category: string;
  selected: boolean;
  conflicting: boolean;
  conflict_reason: string;
};

export const QuirksTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    all_quirks = [],
    quirk_balance = 0,
    quirks_data = [],
  } = data as any;

  const [category, setCategory] = useLocalState(
    context,
    'quirk_category',
    'Positive'
  );

  const filteredQuirks = (quirks_data as QuirkInfo[]).filter(
    (q: QuirkInfo) => q.category === category
  );

  const selectedQuirks = (quirks_data as QuirkInfo[]).filter(
    (q: QuirkInfo) => q.selected
  );

  return (
    <Stack vertical>
      {/* Summary */}
      <Stack.Item>
        <Section title="Selected Quirks">
          <Stack>
            <Stack.Item grow>
              {selectedQuirks.length > 0 ? (
                <Box>
                  {selectedQuirks.map((q: QuirkInfo) => (
                    <Button
                      key={q.name}
                      content={`${q.name} (${q.value > 0 ? '+' : ''}${q.value})`}
                      color={q.value > 0 ? 'green' : q.value < 0 ? 'red' : 'yellow'}
                      onClick={() => act('toggle_quirk', { name: q.name })}
                    />
                  ))}
                </Box>
              ) : (
                <Box color="label" italic>No quirks selected</Box>
              )}
            </Stack.Item>
            <Stack.Item>
              <Box bold>
                Balance: {quirk_balance} points
              </Box>
            </Stack.Item>
          </Stack>
          <Box mt={1}>
            <Button
              icon="undo"
              content="Reset All Quirks"
              color="red"
              onClick={() => act('reset_quirks')}
            />
          </Box>
        </Section>
      </Stack.Item>

      {/* Quirk settings */}
      <Stack.Item>
        <Section title="Quirk Settings">
          <Stack>
            <Stack.Item>
              <Button
                icon="volume-up"
                content="Shriek Type"
                onClick={() => act('change_shriek_option')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="tag"
                content="Summon Nickname"
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
            Positive
          </Tabs.Tab>
          <Tabs.Tab
            selected={category === 'Neutral'}
            onClick={() => setCategory('Neutral')}>
            Neutral
          </Tabs.Tab>
          <Tabs.Tab
            selected={category === 'Negative'}
            onClick={() => setCategory('Negative')}>
            Negative
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>

      {/* Quirk list */}
      <Stack.Item>
        <Section fill scrollable>
          <Stack vertical>
            {filteredQuirks.map((quirk: QuirkInfo) => (
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
                          Blocked: {quirk.conflict_reason}
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
