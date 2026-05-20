import { useBackend } from '../backend';
import { Section, Table, NoticeBox } from '../components';
import { NtosWindow } from '../layouts';

export const NtosBartender = (props, context) => {
  const { act, data } = useBackend(context);
  const { drinks = [] } = data;

  return (
    <NtosWindow width={450} height={550}>
      <NtosWindow.Content scrollable>
        <Section title="Drink Reference">
          {drinks.length === 0 && (
            <NoticeBox info>
              No drink data available.
            </NoticeBox>
          )}
          <Table>
            <Table.Row header>
              <Table.Cell>Drink</Table.Cell>
              <Table.Cell>Description</Table.Cell>
              <Table.Cell collapsing>Strength</Table.Cell>
            </Table.Row>
            {drinks.map(drink => (
              <Table.Row key={drink.name}>
                <Table.Cell bold>
                  {drink.name}
                </Table.Cell>
                <Table.Cell>
                  {drink.description}
                </Table.Cell>
                <Table.Cell collapsing>
                  {drink.strength}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
