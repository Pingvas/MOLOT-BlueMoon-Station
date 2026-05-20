import { useBackend } from '../backend';
import { Section, Table, NoticeBox } from '../components';
import { NtosWindow } from '../layouts';

export const NtosCustodialLocator = (props, context) => {
  const { act, data } = useBackend(context);
  const { items = [] } = data;

  return (
    <NtosWindow width={400} height={500}>
      <NtosWindow.Content scrollable>
        <Section title="Custodial Locator">
          {items.length === 0 && (
            <NoticeBox info>
              No janitorial equipment found.
            </NoticeBox>
          )}
          {items.length > 0 && (
            <Table>
              <Table.Row header>
                <Table.Cell>Item</Table.Cell>
                <Table.Cell>Location</Table.Cell>
                <Table.Cell collapsing>Type</Table.Cell>
              </Table.Row>
              {items.map(item => (
                <Table.Row key={item.name + item.area}>
                  <Table.Cell>{item.name}</Table.Cell>
                  <Table.Cell>{item.area}</Table.Cell>
                  <Table.Cell collapsing>
                    {item.type === 'bucket' ? 'Bucket' : 'Bot'}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
