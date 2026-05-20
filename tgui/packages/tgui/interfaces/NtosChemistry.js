import { useBackend } from '../backend';
import { Section, Table, NoticeBox } from '../components';
import { NtosWindow } from '../layouts';

export const NtosChemistry = (props, context) => {
  const { act, data } = useBackend(context);
  const { chems = [] } = data;

  return (
    <NtosWindow width={450} height={550}>
      <NtosWindow.Content scrollable>
        <Section title="Chemical Reference">
          {chems.length === 0 && (
            <NoticeBox info>
              No chemical data available.
            </NoticeBox>
          )}
          <Table>
            <Table.Row header>
              <Table.Cell>Chemical</Table.Cell>
              <Table.Cell>Description</Table.Cell>
            </Table.Row>
            {chems.map(chem => (
              <Table.Row key={chem.name}>
                <Table.Cell bold>
                  {chem.name}
                </Table.Cell>
                <Table.Cell>
                  {chem.description}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
