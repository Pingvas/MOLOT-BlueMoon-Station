export const SPAWN_LOCATIONS = [
  { value: 'floor_below_mob',        label: 'Floor below me' },
  { value: 'supply_below_mob',       label: 'Supply pod below me' },
  { value: 'mob_hand',               label: 'In my hand' },
  { value: 'marked_object',          label: 'At marked object' },
  { value: 'in_marked_object',       label: 'Inside marked object' },
  { value: 'targeted_location',      label: 'Targeted location (click)' },
  { value: 'targeted_location_pod',  label: 'Targeted location (pod)' },
  { value: 'targeted_mob_hand',      label: "In targeted mob's hand (click)" },
];

export const DIR_OPTIONS = [
  { value: 1,  label: 'South' },
  { value: 2,  label: 'North' },
  { value: 4,  label: 'East' },
  { value: 8,  label: 'West' },
  { value: 5,  label: 'Southeast' },
  { value: 6,  label: 'Northeast' },
  { value: 9,  label: 'Southwest' },
  { value: 10, label: 'Northwest' },
];

export const TAB_TYPES = ['Objects', 'Turfs', 'Mobs'] as const;

export const PRECISE_MODE_OFF    = 'Off';
export const PRECISE_MODE_TARGET = 'Target';
export const PRECISE_MODE_COPY   = 'Copy';
