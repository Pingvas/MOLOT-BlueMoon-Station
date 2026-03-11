import { useBackend } from '../../../backend';
import { Box, Button, LabeledList, Section, Stack } from '../../../components';
import { CharacterSetupData } from '../types';

export const BackgroundTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);

  return (
    <Stack vertical>
      {/* Flavor Text */}
      <Stack.Item>
        <Section title="Flavor Text">
          <Stack vertical>
            <Stack.Item>
              <Button
                fluid
                icon="pen"
                content="Edit Flavor Text"
                onClick={() => act('set_flavor_text')}
              />
              {!!data.flavor_text && (
                <Box mt={1} style={{ 'white-space': 'pre-line' }} color="label">
                  {data.flavor_text.length > 200
                    ? data.flavor_text.substring(0, 200) + '...'
                    : data.flavor_text}
                </Box>
              )}
            </Stack.Item>
            <Stack.Item>
              <Button
                fluid
                icon="pen"
                content="Edit Naked Flavor Text"
                onClick={() => act('set_naked_flavor_text')}
              />
              {!!data.naked_flavor_text && (
                <Box mt={1} style={{ 'white-space': 'pre-line' }} color="label">
                  {data.naked_flavor_text.length > 200
                    ? data.naked_flavor_text.substring(0, 200) + '...'
                    : data.naked_flavor_text}
                </Box>
              )}
            </Stack.Item>
            <Stack.Item>
              <Button
                fluid
                icon="pen"
                content="Edit Silicon Flavor Text"
                onClick={() => act('set_silicon_flavor_text')}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* Custom Species Lore */}
      <Stack.Item>
        <Section title="Custom Species Lore">
          <Button
            fluid
            icon="pen"
            content="Edit Custom Species Lore"
            onClick={() => act('set_custom_species_lore')}
          />
          {!!data.custom_species_lore && (
            <Box mt={1} style={{ 'white-space': 'pre-line' }} color="label">
              {data.custom_species_lore.length > 200
                ? data.custom_species_lore.substring(0, 200) + '...'
                : data.custom_species_lore}
            </Box>
          )}
        </Section>
      </Stack.Item>

      {/* Records */}
      <Stack.Item>
        <Section title="Records">
          <Stack>
            <Stack.Item grow basis={0}>
              <Button
                fluid
                icon="shield-alt"
                content="Security Records"
                onClick={() => act('set_security_records')}
              />
              {!!data.security_records && (
                <Box mt={1} style={{ 'white-space': 'pre-line' }} color="label">
                  {data.security_records.length > 150
                    ? data.security_records.substring(0, 150) + '...'
                    : data.security_records}
                </Box>
              )}
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <Button
                fluid
                icon="medkit"
                content="Medical Records"
                onClick={() => act('set_medical_records')}
              />
              {!!data.medical_records && (
                <Box mt={1} style={{ 'white-space': 'pre-line' }} color="label">
                  {data.medical_records.length > 150
                    ? data.medical_records.substring(0, 150) + '...'
                    : data.medical_records}
                </Box>
              )}
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* OOC Notes */}
      <Stack.Item>
        <Section title="OOC Notes">
          <Button
            fluid
            icon="comment"
            content="Edit OOC Notes"
            onClick={() => act('set_ooc_notes')}
          />
          {!!data.ooc_notes && (
            <Box mt={1} style={{ 'white-space': 'pre-line' }} color="label">
              {data.ooc_notes.length > 200
                ? data.ooc_notes.substring(0, 200) + '...'
                : data.ooc_notes}
            </Box>
          )}
        </Section>
      </Stack.Item>

      {/* Death Customization */}
      <Stack.Item>
        <Section title="Death">
          <LabeledList>
            <LabeledList.Item label="Custom Deathgasp">
              <Button
                content={data.custom_deathgasp || 'Default'}
                icon="pen"
                onClick={() => act('set_custom_deathgasp')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Custom Death Sound">
              <Button
                content={data.custom_deathsound || 'Default'}
                icon="music"
                onClick={() => act('set_custom_deathsound')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

      {/* Headshots */}
      <Stack.Item>
        <Section title="Headshots">
          <Stack>
            <Stack.Item grow basis={0}>
              <Section title="Clothed" level={2}>
                <LabeledList>
                  <LabeledList.Item label="Main">
                    <HeadshotButton
                      link={data.headshot_link}
                      onClick={() => act('set_headshot', { slot: '' })}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Alt 1">
                    <HeadshotButton
                      link={data.headshot_link1}
                      onClick={() => act('set_headshot', { slot: '1' })}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Alt 2">
                    <HeadshotButton
                      link={data.headshot_link2}
                      onClick={() => act('set_headshot', { slot: '2' })}
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <Section title="Naked" level={2}>
                <LabeledList>
                  <LabeledList.Item label="Main">
                    <HeadshotButton
                      link={data.headshot_naked_link}
                      onClick={() => act('set_naked_headshot', { slot: '' })}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Alt 1">
                    <HeadshotButton
                      link={data.headshot_naked_link1}
                      onClick={() => act('set_naked_headshot', { slot: '1' })}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Alt 2">
                    <HeadshotButton
                      link={data.headshot_naked_link2}
                      onClick={() => act('set_naked_headshot', { slot: '2' })}
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const HeadshotButton = (props: { link?: string; onClick: () => void }) => {
  return (
    <Button
      icon={props.link ? 'image' : 'plus'}
      content={props.link ? 'Change' : 'Set'}
      color={props.link ? undefined : 'transparent'}
      onClick={props.onClick}
    />
  );
};
