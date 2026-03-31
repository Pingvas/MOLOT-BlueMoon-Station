export type AtomData = {
  name: string;
  description: string;
  type: 'Objects' | 'Turfs' | 'Mobs';
};

export type SpawnPanelData = {
  selected_object: string | null;
  atom_name: string | null;
  atom_amount: number;
  atom_dir: number;
  offset: [number, number, number];
  offset_type: string;
  where_target_type: string;
  precise_mode: string;
};
