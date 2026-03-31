import { useBackend } from '../../backend';
import { Box, Button, Dropdown, Input, LabeledList, NumberInput, Section, Stack } from '../../components';

import { PRECISE_MODE_COPY, PRECISE_MODE_OFF, PRECISE_MODE_TARGET, SPAWN_LOCATIONS, DIR_OPTIONS } from './constants';
import { SpawnPanelData } from './types';

export const CreateObjectSettings = (props, context) => {
  const { act, data } = useBackend<SpawnPanelData>(context);
  const {
    selectedAtom,
    atomName = '',
    amount = 1,
    atomDir = 1,
    offsetX = 0,
    offsetY = 0,
    offsetZ = 0,
    offsetType = 'relative',
    whereTarget = 'floor_below_mob',
    preciseMode = PRECISE_MODE_OFF,
  } = data;

  const currentLocation = SPAWN_LOCATIONS.find(l => l.value === whereTarget);
  const needsClick = whereTarget === 'targeted_location'
    || whereTarget === 'targeted_location_pod'
    || whereTarget === 'targeted_mob_hand';

  return (
    <Section title="Spawn Settings">
      <LabeledList>
        <LabeledList.Item label="Selected">
          <Box color={selectedAtom ? 'good' : 'average'}>
            {selectedAtom || 'None'}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Name override">
          <Input
            value={atomName}
            placeholder="(default)"
            width="140px"
            onEnter={(e, val) => act('update-settings', { atomName: val })}
            onChange={(e, val) => act('update-settings', { atomName: val })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Amount">
          <NumberInput
            value={amount}
            minValue={1}
            maxValue={100}
            step={1}
            width="50px"
            onChange={(e, val) => act('update-settings', { amount: val })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Direction">
          <Dropdown
            width="110px"
            options={DIR_OPTIONS.map(d => d.label)}
            selected={DIR_OPTIONS.find(d => d.value === atomDir)?.label || 'South'}
            onSelected={(val) => {
              const opt = DIR_OPTIONS.find(d => d.label === val);
              if (opt) act('update-settings', { atomDir: opt.value });
            }}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Location">
          <Dropdown
            width="200px"
            options={SPAWN_LOCATIONS.map(l => l.label)}
            selected={currentLocation?.label || 'Floor below me'}
            onSelected={(val) => {
              const opt = SPAWN_LOCATIONS.find(l => l.label === val);
              if (opt) act('update-settings', { whereTarget: opt.value });
            }}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Offset type">
          <Button
            color={offsetType === 'relative' ? 'green' : 'default'}
            onClick={() => act('update-settings', { offsetType: 'relative' })}
          >
            Relative
          </Button>
          <Button
            color={offsetType === 'absolute' ? 'green' : 'default'}
            onClick={() => act('update-settings', { offsetType: 'absolute' })}
          >
            Absolute
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Offset X/Y/Z">
          <NumberInput
            value={offsetX}
            minValue={-500}
            maxValue={500}
            step={1}
            width="50px"
            onChange={(e, val) => act('update-settings', { offsetX: val })}
          />
          {' / '}
          <NumberInput
            value={offsetY}
            minValue={-500}
            maxValue={500}
            step={1}
            width="50px"
            onChange={(e, val) => act('update-settings', { offsetY: val })}
          />
          {' / '}
          <NumberInput
            value={offsetZ}
            minValue={-50}
            maxValue={50}
            step={1}
            width="50px"
            onChange={(e, val) => act('update-settings', { offsetZ: val })}
          />
        </LabeledList.Item>
      </LabeledList>

      {needsClick && (
        <Box mt={1}>
          <Stack>
            <Stack.Item>
              <Button
                icon="crosshairs"
                color={preciseMode === PRECISE_MODE_TARGET ? 'green' : 'default'}
                tooltip="Click a tile to set target location"
                onClick={() => act('toggle-precise-mode', { mode: PRECISE_MODE_TARGET })}
              >
                Set target
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="copy"
                color={preciseMode === PRECISE_MODE_COPY ? 'green' : 'default'}
                tooltip="Click an atom to copy its type"
                onClick={() => act('toggle-precise-mode', { mode: PRECISE_MODE_COPY })}
              >
                Copy type
              </Button>
            </Stack.Item>
            {preciseMode !== PRECISE_MODE_OFF && (
              <Stack.Item>
                <Box color="average">Intercept active — click in-game</Box>
              </Stack.Item>
            )}
          </Stack>
        </Box>
      )}

      <Box mt={1}>
        <Button
          fluid
          icon="plus"
          color={selectedAtom ? 'green' : 'grey'}
          disabled={!selectedAtom}
          tooltip={selectedAtom ? `Spawn ${amount}x ${selectedAtom}` : 'Select an atom first'}
          onClick={() => act('create-atom-action')}
        >
          Spawn{amount > 1 ? ` (×${amount})` : ''}
        </Button>
      </Box>
    </Section>
  );
};
