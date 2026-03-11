import { useBackend } from '../../../backend';
import {
  Box,
  Button,
  ColorBox,
  Section,
  Stack,
  Table,
} from '../../../components';
import { CharacterSetupData } from '../types';

export type MarkingEntry = {
  index: number;
  limb_value: number;
  limb_name: string;
  marking_name: string;
  colors: string[];
};

export const MarkingsTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    markings = [],
  } = data as any;

  // Get unique limb names from actual data
  const limbNames: string[] = [];
  for (const m of markings as MarkingEntry[]) {
    if (m.limb_name && !limbNames.includes(m.limb_name)) {
      limbNames.push(m.limb_name);
    }
  }

  return (
    <Stack vertical>
      {/* Действия */}
      <Stack.Item>
        <Stack>
          <Stack.Item grow>
            <Button
              fluid
              icon="plus"
              content="Добавить метку"
              color="green"
              onClick={() => act('marking_add')}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              icon="trash"
              content="Удалить все"
              color="red"
              onClick={() => act('markings_remove_all')}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              icon="paint-brush"
              content="Татуировки"
              onClick={() => act('open_tattoo_manager')}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>

      {/* Markings by limb */}
      {limbNames.map((limb) => {
        const limbMarkings = (markings as MarkingEntry[]).filter(
          (m: MarkingEntry) => m.limb_name === limb,
        );
        return (
          <Stack.Item key={limb}>
            <Section
              title={limb}
              buttons={
                limbMarkings.length > 0 && (
                  <Button
                    icon="trash"
                    color="red"
                    tooltip={`Очистить ${limb}`}
                    onClick={() => act('markings_clear_limb', {
                      limb: limb,
                    })}
                  />
                )
              }>
              <Table>
                <Table.Row header>
                  <Table.Cell>Метка</Table.Cell>
                  <Table.Cell>Цвета</Table.Cell>
                  <Table.Cell>Порядок</Table.Cell>
                  <Table.Cell>Действия</Table.Cell>
                </Table.Row>
                {limbMarkings.map((marking: MarkingEntry) => (
                  <Table.Row key={marking.index}>
                    <Table.Cell>{marking.marking_name}</Table.Cell>
                    <Table.Cell>
                      {marking.colors.map((color, ci) => (
                        <Button
                          key={ci}
                          onClick={() => act('marking_color', {
                            index: marking.index,
                            color_num: ci + 1,
                          })}>
                          <ColorBox color={color} />
                        </Button>
                      ))}
                    </Table.Cell>
                    <Table.Cell>
                      <Button
                        icon="angle-up"
                        onClick={() => act('marking_up', {
                          index: marking.index,
                        })}
                      />
                      <Button
                        icon="angle-down"
                        onClick={() => act('marking_down', {
                          index: marking.index,
                        })}
                      />
                    </Table.Cell>
                    <Table.Cell>
                      <Button
                        icon="times"
                        color="red"
                        onClick={() => act('marking_remove', {
                          index: marking.index,
                        })}
                      />
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Stack.Item>
        );
      })}

      {/* Show empty state if no markings */}
      {limbNames.length === 0 && (
        <Stack.Item>
          <Section>
            <Box color="label" italic textAlign="center">
              Меток нет. Нажмите &quot;Добавить метку&quot; для начала.
            </Box>
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};
