export type AtomData = {
  name: string;
  icon: string; // data:image/png;base64,... or empty
  description: string;
  type: 'Objects' | 'Turfs' | 'Mobs';
};

export type SpawnPanelData = {
  selectedAtom: string | null;
  atomName: string;
  amount: number;
  atomDir: number;
  offsetX: number;
  offsetY: number;
  offsetZ: number;
  offsetType: string;
  whereTarget: string;
  preciseMode: string;
};
