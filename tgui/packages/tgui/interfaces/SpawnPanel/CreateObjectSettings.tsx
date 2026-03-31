import { useBackend } from '../../backend';
import { Box, Button, Dropdown, Input, NumberInput, Section, Slider, Stack, Table } from '../../components';

import {
  DIR_ICONS,
  DIR_NAMES,
  DIR_SLIDER_ORDER,
  LOCATIONS_NEEDING_CLICK,
  OFFSET_ABSOLUTE,
  OFFSET_RELATIVE,
  PRECISE_MODE_COPY,
  PRECISE_MODE_OFF,
  PRECISE_MODE_TARGET,
  SPAWN_LOCATION_ICONS,
  SPAWN_LOCATIONS,
} from './constants';
import { SpawnPanelData } from './types';

function dirToSliderIndex(dir: number): number {
  const idx = DIR_SLIDER_ORDER.indexOf(dir);
  return idx >= 0 ? idx : 0;
}

function sliderIndexToDir(index: number): number {
  return DIR_SLIDER_ORDER[index] ?? DIR_SLIDER_ORDER[0];
}

function formatDir(sliderIndex: number): string {
  const dir = sliderIndexToDir(sliderIndex);
  return DIR_NAMES[dir] ?? 'S';
}

export const CreateObjectSettings = (props: any, context: any) => {
  const { act, data } = useBackend<SpawnPanelData>(context);
  const {
    selected_object,
    atom_name,
    atom_amount = 1,
    atom_dir = 1,
    offset = [0, 0, 0],
    offset_type = OFFSET_RELATIVE,
    where_target_type = SPAWN_LOCATIONS[0],
    precise_mode = PRECISE_MODE_OFF,
  } = data;

  const ox: number = (offset as any)[0] ?? 0;
  const oy: number = (offset as any)[1] ?? 0;
  const oz: number = (offset as any)[2] ?? 0;

  const dirSliderIdx = dirToSliderIndex(atom_dir);
  const needsClick = LOCATIONS_NEEDING_CLICK.includes(where_target_type);
  const locationIcon = SPAWN_LOCATION_ICONS[where_target_type] ?? 'map-marker';

  // Sends a settings update, merging with current values
  function sendSettings(partial: Partial<{
    where_target_type: string;
    atom_amount: number;
    atom_name: string | null;
    atom_dir: number;
    offset: [number, number, number];
    offset_type: string;
  }>) {
    act('update-settings', {
      where_target_type,
      atom_amount,
      atom_name,
      atom_dir,
      offset: [ox, oy, oz],
      offset_type,
      ...partial,
    });
  }

  function togglePreciseMode(mode: string) {
    act('toggle-precise-mode', {
      newPreciseType: precise_mode === mode ? PRECISE_MODE_OFF : mode,
    });
  }

  function handleOffsetInput(_e: any, val: string) {
    const parts = val.split(',').map(s => parseInt(s.trim(), 10));
    sendSettings({
      offset: [
        isNaN(parts[0]) ? 0 : parts[0],
        isNaN(parts[1]) ? 0 : parts[1],
        isNaN(parts[2]) ? 0 : parts[2],
      ],
    });
  }

  return (
    <Section>
      <Stack fill>
        {/* ─── Settings rows ─── */}
        <Stack.Item grow={1}>
          <Table>
            {/* Row 1: Amount + Direction */}
            <Table.Row className="candystripe">
              <Table.Cell collapsing bold color="label">Amt</Table.Cell>
              <Table.Cell collapsing>
                <NumberInput
                  value={atom_amount}
                  minValue={1}
                  maxValue={100}
                  step={1}
                  width="40px"
                  onChange={(_e: any, val: number) => sendSettings({ atom_amount: val })}
                />
              </Table.Cell>
              <Table.Cell collapsing bold color="label">Dir</Table.Cell>
              <Table.Cell>
                <Stack align="center" spacing={1}>
                  <Stack.Item>
                    <Button
                      compact
                      icon={DIR_ICONS[atom_dir] ?? 'arrow-down'}
                      tooltip={DIR_NAMES[atom_dir] ?? 'South'}
                      onClick={() => {
                        const next = DIR_SLIDER_ORDER[(dirSliderIdx + 1) % 4];
                        sendSettings({ atom_dir: next });
                      }}
                    />
                  </Stack.Item>
                  <Stack.Item grow={1}>
                    <Slider
                      value={dirSliderIdx}
                      minValue={0}
                      maxValue={3}
                      step={1}
                      stepPixelSize={22}
                      format={formatDir}
                      onChange={(_e: any, val: number) => sendSettings({ atom_dir: sliderIndexToDir(val) })}
                    />
                  </Stack.Item>
                </Stack>
              </Table.Cell>
            </Table.Row>

            {/* Row 2: Offset */}
            <Table.Row className="candystripe">
              <Table.Cell collapsing bold color="label">Off</Table.Cell>
              <Table.Cell collapsing>
                <Button
                  compact
                  selected={offset_type === OFFSET_ABSOLUTE}
                  tooltip="Absolute world coordinates"
                  onClick={() => sendSettings({ offset_type: OFFSET_ABSOLUTE })}
                >A</Button>
                <Button
                  compact
                  selected={offset_type === OFFSET_RELATIVE}
                  tooltip="Relative to spawn position"
                  onClick={() => sendSettings({ offset_type: OFFSET_RELATIVE })}
                >R</Button>
              </Table.Cell>
              <Table.Cell colSpan={2}>
                <Input
                  placeholder="x, y, z"
                  value={`${ox}, ${oy}, ${oz}`}
                  fluid
                  onEnter={handleOffsetInput}
                />
              </Table.Cell>
            </Table.Row>

            {/* Row 3: Name override */}
            <Table.Row className="candystripe">
              <Table.Cell collapsing bold color="label">Name</Table.Cell>
              <Table.Cell colSpan={3}>
                <Input
                  placeholder="Leave empty for default"
                  value={atom_name ?? ''}
                  fluid
                  onEnter={(_e: any, val: string) => sendSettings({ atom_name: val || null })}
                />
              </Table.Cell>
            </Table.Row>
          </Table>
        </Stack.Item>

        {/* ─── Right column: small action buttons ─── */}
        <Stack.Item>
          <Stack vertical>
            <Stack.Item>
              <Button
                compact
                width="22px"
                height="22px"
                icon="crosshairs"
                color={precise_mode === PRECISE_MODE_TARGET ? 'green' : 'default'}
                tooltip={needsClick
                  ? (precise_mode === PRECISE_MODE_TARGET ? 'Click a tile in-game (active)' : 'Click a tile to set target')
                  : 'Only available for targeted locations'}
                disabled={!needsClick}
                onClick={() => togglePreciseMode(PRECISE_MODE_TARGET)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                compact
                width="22px"
                height="22px"
                icon="copy"
                color={precise_mode === PRECISE_MODE_COPY ? 'green' : 'default'}
                tooltip={precise_mode === PRECISE_MODE_COPY ? 'Click an atom in-game (active)' : 'Click an atom to copy its type'}
                onClick={() => togglePreciseMode(PRECISE_MODE_COPY)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                compact
                width="22px"
                height="22px"
                icon="trash"
                color="bad"
                tooltip="Clear selected atom"
                disabled={!selected_object}
                onClick={() => act('selected-atom-changed', { newObj: null })}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>

        {/* ─── SPAWN button ─── */}
        <Stack.Item>
          <Button
            color={selected_object ? 'good' : 'grey'}
            disabled={!selected_object}
            tooltip={selected_object
              ? `Spawn ${atom_amount}x ${selected_object}`
              : 'Select an atom first'}
            style={{
              'height': '100%',
              'font-size': '18px',
              'padding': '0 14px',
              'display': 'flex',
              'flex-direction': 'column',
              'align-items': 'center',
              'justify-content': 'center',
            }}
            onClick={() => act('create-atom-action', {
              selected_atom: selected_object,
              where_target_type,
              atom_amount,
              atom_name,
              atom_dir,
              offset: [ox, oy, oz],
              offset_type,
            })}
          >
            <Box>SPAWN</Box>
            {atom_amount > 1 && (
              <Box style={{ 'font-size': '11px', 'opacity': '0.8' }}>×{atom_amount}</Box>
            )}
          </Button>
        </Stack.Item>
      </Stack>

      {/* ─── Spawn location dropdown ─── */}
      <Box mt={1}>
        <Dropdown
          fluid
          icon={locationIcon}
          options={SPAWN_LOCATIONS as unknown as string[]}
          selected={where_target_type ?? SPAWN_LOCATIONS[0]}
          onSelected={(val: string) => sendSettings({ where_target_type: val })}
        />
      </Box>

      {/* ─── Status indicators ─── */}
      {selected_object && (
        <Box mt="2px" color="label" fontSize="10px" style={{ 'word-break': 'break-all' }}>
          {selected_object}
        </Box>
      )}
      {precise_mode !== PRECISE_MODE_OFF && (
        <Box mt="2px" color="average" fontSize="11px">
          {precise_mode === PRECISE_MODE_TARGET
            ? 'Target mode — click a tile in-game'
            : 'Copy mode — click an atom in-game'}
        </Box>
      )}
    </Section>
  );
};
