import { useBackend } from '../../../backend';
import {
  Box,
  Button,
  ColorBox,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from '../../../components';
import { CharacterSetupData } from '../types';

export const GeneralTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);

  return (
    <Stack vertical>
      {/* Occupation */}
      <Stack.Item>
        <Section title="Occupation">
          <Button
            fluid
            icon="briefcase"
            content="Set Occupation Preferences"
            onClick={() => act('open_job_menu')}
          />
        </Section>
      </Stack.Item>

      {/* Quirks summary */}
      {!!data.roundstart_traits && (
        <Stack.Item>
          <Section title="Quirks">
            <LabeledList>
              <LabeledList.Item label="Balance">
                {data.quirk_balance ?? 0} points
              </LabeledList.Item>
            </LabeledList>
            <Button
              mt={1}
              fluid
              icon="list"
              content="Configure Quirks"
              onClick={() => act('open_quirk_menu')}
            />
          </Section>
        </Stack.Item>
      )}

      {/* Identity */}
      <Stack.Item>
        <Section title="Identity">
          <Stack>
            {/* Column 1: Basic identity */}
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Name">
                  <Stack inline>
                    <Stack.Item grow>
                      <Input
                        fluid
                        value={data.real_name}
                        onInput={(e, value) => act('set_name', {
                          name: value,
                        })}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="dice"
                        tooltip="Random name"
                        onClick={() => act('random_name')}
                      />
                    </Stack.Item>
                  </Stack>
                </LabeledList.Item>
                <LabeledList.Item label="Gender">
                  <Button
                    selected={data.gender === 'male'}
                    content="Male"
                    onClick={() => act('set_gender', { gender: 'male' })}
                  />
                  <Button
                    selected={data.gender === 'female'}
                    content="Female"
                    onClick={() => act('set_gender', { gender: 'female' })}
                  />
                  <Button
                    selected={data.gender === 'plural'}
                    content="Plural"
                    onClick={() => act('set_gender', { gender: 'plural' })}
                  />
                  <Button
                    selected={data.gender === 'neuter'}
                    content="Neuter"
                    onClick={() => act('set_gender', { gender: 'neuter' })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Age">
                  <NumberInput
                    value={data.age}
                    minValue={17}
                    maxValue={300}
                    step={1}
                    onChange={(e, value) => act('set_age', { age: value })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Random Name">
                  <Button.Checkbox
                    checked={data.be_random_name}
                    content={data.be_random_name ? 'Yes' : 'No'}
                    onClick={() => act('toggle_random_name')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Random Body">
                  <Button.Checkbox
                    checked={data.be_random_body}
                    content={data.be_random_body ? 'Yes' : 'No'}
                    onClick={() => act('toggle_random_body')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Hide Ckey">
                  <Button.Checkbox
                    checked={data.hide_ckey}
                    content={data.hide_ckey ? 'Enabled' : 'Disabled'}
                    onClick={() => act('toggle_hide_ckey')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Nameless">
                  <Button.Checkbox
                    checked={data.nameless}
                    content={data.nameless ? 'Yes' : 'No'}
                    onClick={() => act('toggle_nameless')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Hardsuit + Tail">
                  <Button.Checkbox
                    checked={data.hardsuit_with_tail}
                    content={data.hardsuit_with_tail ? 'Yes' : 'No'}
                    onClick={() => act('toggle_hardsuit_tail')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Custom Blood Color">
                  <Button.Checkbox
                    checked={data.custom_blood_color}
                    onClick={() => act('toggle_custom_blood_color')}
                  />
                  {!!data.custom_blood_color && (
                    <Button
                      icon="palette"
                      onClick={() => act('set_blood_color')}>
                      <ColorBox color={data.blood_color} mr={1} />
                      Change
                    </Button>
                  )}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>

            {/* Column 2: Special names + job prefs */}
            <Stack.Item grow basis={0}>
              <SpecialNames />
              <Box mt={1}>
                <LabeledList>
                  <LabeledList.Item label="Security Dept">
                    <Button
                      content={data.prefered_security_department || 'None'}
                      onClick={() => act('set_security_dept')}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="AI Core Display">
                    <Button
                      content={data.preferred_ai_core_display || 'Default'}
                      onClick={() => act('set_ai_core_display')}
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Box>
            </Stack.Item>

            {/* Column 3: PDA + Silicon */}
            <Stack.Item grow basis={0}>
              <PDAPreferences />
              <SiliconPreferences />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const SpecialNames = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const { custom_names = {}, custom_name_types = [] } = data;

  if (!custom_name_types.length) {
    return null;
  }

  return (
    <LabeledList>
      {custom_name_types.map((nameType) => (
        <LabeledList.Item label={nameType.label}>
          <Input
            fluid
            value={custom_names[nameType.id] || ''}
            onInput={(e, value) => act('set_custom_name', {
              name_id: nameType.id,
              value: value,
            })}
          />
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
};

const PDAPreferences = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);

  return (
    <Section title="PDA" level={2}>
      <LabeledList>
        <LabeledList.Item label="Color">
          <Button onClick={() => act('set_pda_color')}>
            <ColorBox color={data.pda_color} mr={1} />
            Change
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Style">
          <Button
            content={data.pda_style || 'Default'}
            onClick={() => act('set_pda_style')}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Skin">
          <Button
            content={data.pda_skin || 'Default'}
            onClick={() => act('set_pda_skin')}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Ringtone">
          <Button
            content={data.pda_ringtone || 'Default'}
            onClick={() => act('set_pda_ringtone')}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const SiliconPreferences = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);

  if (!data.allow_silicon_choosing_laws) {
    return null;
  }

  return (
    <Section title="Silicon" level={2}>
      <LabeledList>
        <LabeledList.Item label="Lawset">
          <Button
            content={data.silicon_lawset || 'Default'}
            onClick={() => act('set_silicon_lawset')}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
