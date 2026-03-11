import { useBackend } from '../../../backend';
import { Box, Button, Section, Stack } from '../../../components';
import { CharacterSetupData } from '../types';

const PREVIEW_PREF_JOB = 'Job';
const PREVIEW_PREF_LOADOUT = 'Loadout';
const PREVIEW_PREF_NAKED = 'Naked';
const PREVIEW_PREF_NAKED_AROUSED = 'Naked - Aroused';

export const CharacterPreview = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const { preview_icon, preview_pref = PREVIEW_PREF_JOB } = data;

  return (
    <Section
      title="Preview"
      fill
      buttons={
        <Button
          icon="sync"
          tooltip="Refresh preview"
          onClick={() => act('refresh_preview')}
        />
      }>
      <Stack vertical fill>
        <Stack.Item grow textAlign="center">
          {preview_icon ? (
            <Box
              as="img"
              src={`data:image/png;base64,${preview_icon}`}
              style={{
                'image-rendering': 'pixelated',
                'max-width': '100%',
                'max-height': '180px',
              }}
            />
          ) : (
            <Box color="label" italic>
              Loading...
            </Box>
          )}
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Button
                fluid
                selected={preview_pref === PREVIEW_PREF_JOB}
                icon="briefcase"
                tooltip="Job"
                onClick={() => act('set_preview_pref', {
                  pref: PREVIEW_PREF_JOB,
                })}
              />
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                selected={preview_pref === PREVIEW_PREF_LOADOUT}
                icon="box-open"
                tooltip="Loadout"
                onClick={() => act('set_preview_pref', {
                  pref: PREVIEW_PREF_LOADOUT,
                })}
              />
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                selected={preview_pref === PREVIEW_PREF_NAKED}
                icon="tshirt"
                tooltip="Naked"
                onClick={() => act('set_preview_pref', {
                  pref: PREVIEW_PREF_NAKED,
                })}
              />
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                selected={preview_pref === PREVIEW_PREF_NAKED_AROUSED}
                icon="heart"
                tooltip="Aroused"
                onClick={() => act('set_preview_pref', {
                  pref: PREVIEW_PREF_NAKED_AROUSED,
                })}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
