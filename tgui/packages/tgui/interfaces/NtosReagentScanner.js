import { useBackend } from '../backend';
import { Section, Table, NoticeBox } from '../components';
import { NtosWindow } from '../layouts';

export const NtosReagentScanner = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    scanned_item,
    reagents = [],
    total_volume,
    max_volume,
  } = data;

  return (
    <NtosWindow width={400} height={500}>
      <NtosWindow.Content scrollable>
        <Section title="Reagent Scanner">
          {!scanned_item && (
            <NoticeBox info>
              Hold a container in your active hand to scan its contents.
            </NoticeBox>
          )}
          {scanned_item && (
            <NoticeBox success>
              Scanning: <b>{scanned_item}</b>
              {' '}({total_volume}/{max_volume}u)
            </NoticeBox>
          )}
        </Section>
        {reagents.length > 0 && (
          <Section title="Detected Reagents">
            <Table>
              <Table.Row header>
                <Table.Cell>Reagent</Table.Cell>
                <Table.Cell collapsing>Volume</Table.Cell>
              </Table.Row>
              {reagents.map(reagent => (
                <Table.Row key={reagent.name}>
                  <Table.Cell>
                    {reagent.name}
                  </Table.Cell>
                  <Table.Cell collapsing>
                    {reagent.volume}u
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
