import { useBackend } from '../backend';
import { Section, Table, NoticeBox, ProgressBar } from '../components';
import { NtosWindow } from '../layouts';

export const NtosHydroponics = (props, context) => {
  const { act, data } = useBackend(context);
  const { trays = [] } = data;

  return (
    <NtosWindow width={500} height={550}>
      <NtosWindow.Content scrollable>
        <Section title="Hydroponics Monitor">
          {trays.length === 0 && (
            <NoticeBox info>
              No hydroponics trays found.
            </NoticeBox>
          )}
          {trays.map(tray => (
            <Section
              key={tray.name + tray.area}
              title={tray.name + ' - ' + tray.area}>
              <Table>
                <Table.Row>
                  <Table.Cell bold>Plant:</Table.Cell>
                  <Table.Cell>{tray.plant}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Health:</Table.Cell>
                  <Table.Cell>
                    <ProgressBar
                      value={tray.health}
                      maxValue={tray.max_health}
                      ranges={{
                        good: [tray.max_health * 0.7, tray.max_health],
                        average: [tray.max_health * 0.3, tray.max_health * 0.7],
                        bad: [0, tray.max_health * 0.3],
                      }}>
                      {tray.health}/{tray.max_health}
                    </ProgressBar>
                  </Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Water:</Table.Cell>
                  <Table.Cell>{tray.water}u</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Nutrients:</Table.Cell>
                  <Table.Cell>{tray.nutri}u</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Weeds:</Table.Cell>
                  <Table.Cell>{tray.weed_level}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Pests:</Table.Cell>
                  <Table.Cell>{tray.pest_level}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Ready to Harvest:</Table.Cell>
                  <Table.Cell>
                    {tray.harvest ? 'Yes' : 'No'}
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          ))}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
