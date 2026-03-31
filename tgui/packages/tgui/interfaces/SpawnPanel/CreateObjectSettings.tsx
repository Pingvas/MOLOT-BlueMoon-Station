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
  TAB_TYPE_COLORS,
} from './constants';
import { SpawnPanelData } from './types';

const PLACEHOLDER_ICON = 'data:image/gif;base64,R0lGODlhIAAgAIAAAAAAAP///yH5BAAAAAAALAAAAAAgACAAAAIxhI+py+0Po5y02oszNrz7D4biSJbmiabqyrbuC8fyTNf2jef6zvf+DwwKh8Si8YhKAAA7';

function dirToIdx(dir: number): number {
  const idx = DIR_SLIDER_ORDER.indexOf(dir);
  return idx >= 0 ? idx : 0;
}

function idxToDir(idx: number): number {
  return DIR_SLIDER_ORDER[idx] ?? DIR_SLIDER_ORDER[0];
}

export const CreateObjectSettings = (props: any, context: any) => {
  const { act, data } = useBackend<SpawnPanelData>(context);
  const {
    selected_object,
    selected_icon,
    atom_name,
    atom_amount = 1,
    atom_dir = 2,
    offset = [0, 0, 0],
    offset_type = OFFSET_RELATIVE,
    where_target_type = SPAWN_LOCATIONS[0],
    precise_mode = PRECISE_MODE_OFF,
  } = data;

  const ox: number = (offset as any)[0] ?? 0;
  const oy: number = (offset as any)[1] ?? 0;
  const oz: number = (offset as any)[2] ?? 0;

  const dirIdx = dirToIdx(atom_dir);
  const needsClick = LOCATIONS_NEEDING_CLICK.includes(where_target_type);
  const locationIcon = SPAWN_LOCATION_ICONS[where_target_type] ?? 'map-marker';

  // Display name: try to extract readable name from typepath if no other info
  const displayName = selected_object
    ? selected_object.split('/').filter(Boolean).pop() ?? selected_object
    : 'Nothing selected';

  function send(partial: object) {
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

  function togglePrecise(mode: string) {
    act('toggle-precise-mode', {
      newPreciseType: precise_mode === mode ? PRECISE_MODE_OFF : mode,
    });
  }

  function handleOffsetInput(_e: any, val: string) {
    const parts = val.split(',').map(s => parseInt(s.trim(), 10));
    send({
      offset: [
        isNaN(parts[0]) ? 0 : parts[0],
        isNaN(parts[1]) ? 0 : parts[1],
        isNaN(parts[2]) ? 0 : parts[2],
      ],
    });
  }

  return (
    <Section>
      {/* ─── Selected atom header ─── */}
      <Stack align="center" mb={1} spacing={1}>
        <Stack.Item>
          <Box
            as="img"
            src={selected_icon || PLACEHOLDER_ICON}
            style={{
              'width': '48px',
              'height': '48px',
              'image-rendering': 'pixelated',
              'background': 'rgba(0,0,0,0.4)',
              'border-radius': '4px',
              'border': selected_object ? '2px solid #00c864' : '2px solid rgba(255,255,255,0.1)',
              'flex-shrink': '0',
            }}
          />
        </Stack.Item>
        <Stack.Item grow={1} style={{ 'overflow': 'hidden' }}>
          <Box
            bold
            fontSize="13px"
            color={selected_object ? '#00e87a' : 'average'}
            style={{ 'white-space': 'nowrap', 'overflow': 'hidden', 'text-overflow': 'ellipsis' }}
          >
            {displayName}
          </Box>
          {selected_object && (
            <Box
              color="label"
              fontSize="10px"
              style={{ 'white-space': 'nowrap', 'overflow': 'hidden', 'text-overflow': 'ellipsis' }}
            >
              {selected_object}
            </Box>
          )}
        </Stack.Item>
        <Stack.Item>
          <Button
            compact
            icon="times"
            color="bad"
            tooltip="Clear selection"
            disabled={!selected_object}
            onClick={() => act('selected-atom-changed', { newObj: null })}
          />
        </Stack.Item>
      </Stack>

      {/* ─── Settings + SPAWN button ─── */}
      <Stack spacing={1}>
        <Stack.Item grow={1}>
          <Table>
            {/* Row 1: Amount + Direction */}
            <Table.Row className="candystripe">
              <Table.Cell collapsing bold color="label" style={{ 'padding': '2px 6px', 'white-space': 'nowrap' }}>
                Amt
              </Table.Cell>
              <Table.Cell collapsing style={{ 'padding': '2px 4px' }}>
                <NumberInput
                  value={atom_amount}
                  minValue={1}
                  maxValue={100}
                  step={1}
                  width="44px"
                  onChange={(_e: any, val: number) => send({ atom_amount: val })}
                />
              </Table.Cell>
              <Table.Cell collapsing bold color="label" style={{ 'padding': '2px 6px', 'white-space': 'nowrap' }}>
                Dir
              </Table.Cell>
              <Table.Cell style={{ 'padding': '2px 4px' }}>
                <Stack align="center" spacing={1}>
                  <Stack.Item>
                    <Button
                      compact
                      icon={DIR_ICONS[atom_dir] ?? 'arrow-down'}
                      tooltip={DIR_NAMES[atom_dir] ?? 'South'}
                      onClick={() => send({ atom_dir: idxToDir((dirIdx + 1) % 4) })}
                    />
                  </Stack.Item>
                  <Stack.Item grow={1}>
                    <Slider
                      value={dirIdx}
                      minValue={0}
                      maxValue={3}
                      step={1}
                      stepPixelSize={24}
                      format={(i: number) => DIR_NAMES[idxToDir(i)]?.[0] ?? '?'}
                      onChange={(_e: any, val: number) => send({ atom_dir: idxToDir(val) })}
                    />
                  </Stack.Item>
                </Stack>
              </Table.Cell>
            </Table.Row>

            {/* Row 2: Offset */}
            <Table.Row className="candystripe">
              <Table.Cell collapsing bold color="label" style={{ 'padding': '2px 6px' }}>Off</Table.Cell>
              <Table.Cell collapsing style={{ 'padding': '2px 4px' }}>
                <Button
                  compact
                  selected={offset_type === OFFSET_ABSOLUTE}
                  tooltip="Absolute world coordinates"
                  onClick={() => send({ offset_type: OFFSET_ABSOLUTE })}
                >A</Button>
                <Button
                  compact
                  selected={offset_type === OFFSET_RELATIVE}
                  tooltip="Relative to spawn position"
                  onClick={() => send({ offset_type: OFFSET_RELATIVE })}
                >R</Button>
              </Table.Cell>
              <Table.Cell colSpan={2} style={{ 'padding': '2px 4px' }}>
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
              <Table.Cell collapsing bold color="label" style={{ 'padding': '2px 6px' }}>Name</Table.Cell>
              <Table.Cell colSpan={3} style={{ 'padding': '2px 4px' }}>
                <Input
                  placeholder="Leave empty for default"
                  value={atom_name ?? ''}
                  fluid
                  onEnter={(_e: any, val: string) => send({ atom_name: val || null })}
                />
              </Table.Cell>
            </Table.Row>
          </Table>
        </Stack.Item>

        {/* ─── Right: action buttons + SPAWN ─── */}
        <Stack.Item>
          <Stack vertical spacing={1} style={{ 'height': '100%' }}>
            <Stack.Item>
              <Button
                compact
                width="22px"
                height="22px"
                icon="crosshairs"
                color={precise_mode === PRECISE_MODE_TARGET ? 'green' : 'default'}
                tooltip={needsClick
                  ? (precise_mode === PRECISE_MODE_TARGET ? 'Active — click a tile' : 'Set target tile')
                  : 'Only for targeted locations'}
                disabled={!needsClick}
                onClick={() => togglePrecise(PRECISE_MODE_TARGET)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                compact
                width="22px"
                height="22px"
                icon="copy"
                color={precise_mode === PRECISE_MODE_COPY ? 'green' : 'default'}
                tooltip={precise_mode === PRECISE_MODE_COPY ? 'Active — click an atom' : 'Copy atom type'}
                onClick={() => togglePrecise(PRECISE_MODE_COPY)}
              />
            </Stack.Item>
            <Stack.Item grow={1} />
            <Stack.Item>
              <Button
                color={selected_object ? 'good' : 'grey'}
                disabled={!selected_object}
                tooltip={selected_object ? `Spawn ${atom_amount}x ${displayName}` : 'Select an atom first'}
                style={{
                  'min-height': '58px',
                  'font-size': '16px',
                  'font-weight': 'bold',
                  'letter-spacing': '1px',
                  'padding': '0 12px',
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
                  <Box style={{ 'font-size': '11px', 'opacity': '0.75', 'font-weight': 'normal' }}>
                    x{atom_amount}
                  </Box>
                )}
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>

      {/* ─── Location dropdown ─── */}
      <Box mt={1}>
        <Dropdown
          fluid
          icon={locationIcon}
          options={SPAWN_LOCATIONS as unknown as string[]}
          selected={where_target_type ?? SPAWN_LOCATIONS[0]}
          onSelected={(val: string) => send({ where_target_type: val })}
        />
      </Box>

      {/* ─── Precise mode indicator ─── */}
      {precise_mode !== PRECISE_MODE_OFF && (
        <Box
          mt="2px"
          p="2px 6px"
          fontSize="11px"
          color="average"
          style={{
            'border': '1px solid rgba(255,180,0,0.4)',
            'border-radius': '3px',
            'background': 'rgba(255,180,0,0.08)',
          }}
        >
          {precise_mode === PRECISE_MODE_TARGET
            ? 'Target mode — click a tile in-game'
            : 'Copy mode — click an atom in-game'}
        </Box>
      )}
    </Section>
  );
};