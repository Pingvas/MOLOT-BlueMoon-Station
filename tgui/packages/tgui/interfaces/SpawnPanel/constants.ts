export const SPAWN_LOCATIONS = [
  'Current location',
  'Current location (droppod)',
  "In own mob's hand",
  'At a marked object',
  'In the marked object',
  'Targeted location',
  'Targeted location (droppod)',
  "In targeted mob's hand",
] as const;

export const SPAWN_LOCATION_ICONS: Record<string, string> = {
  'Current location': 'map-marker',
  'Current location (droppod)': 'box',
  "In own mob's hand": 'hand-paper',
  'At a marked object': 'bookmark',
  'In the marked object': 'box-open',
  'Targeted location': 'crosshairs',
  'Targeted location (droppod)': 'satellite',
  "In targeted mob's hand": 'user',
};

export const TAB_TYPES = ['Objects', 'Turfs', 'Mobs'] as const;

// BYOND direction constants (bitmask)
export const DIR_SOUTH = 1;
export const DIR_NORTH = 2;
export const DIR_EAST  = 4;
export const DIR_WEST  = 8;

// Order for slider: index 0=South, 1=North, 2=East, 3=West
export const DIR_SLIDER_ORDER = [DIR_SOUTH, DIR_NORTH, DIR_EAST, DIR_WEST];

export const DIR_NAMES: Record<number, string> = {
  [DIR_SOUTH]: 'South',
  [DIR_NORTH]: 'North',
  [DIR_EAST]:  'East',
  [DIR_WEST]:  'West',
};

export const DIR_ICONS: Record<number, string> = {
  [DIR_SOUTH]: 'arrow-down',
  [DIR_NORTH]: 'arrow-up',
  [DIR_EAST]:  'arrow-right',
  [DIR_WEST]:  'arrow-left',
};

export const PRECISE_MODE_OFF    = 'Off';
export const PRECISE_MODE_TARGET = 'Target';
export const PRECISE_MODE_COPY   = 'Copy';

export const OFFSET_ABSOLUTE = 'Absolute offset';
export const OFFSET_RELATIVE = 'Relative offset';

export const LOCATIONS_NEEDING_CLICK = [
  'Targeted location',
  'Targeted location (droppod)',
  "In targeted mob's hand",
];

export const MAX_ATOM_DISPLAY = 200;
