import { resolveAsset } from '../../assets';
import { useLocalState } from '../../backend';
import { Box, Stack } from '../../components';
import { Window } from '../../layouts';

import { CreateObject } from './CreateObject';
import { CreateObjectSettings } from './CreateObjectSettings';
import { AtomData } from './types';

let cachedAtoms: Record<string, AtomData> | null = null;
let fetchInProgress = false;

export const SpawnPanel = (props: any, context: any) => {
  const [atoms, setAtoms] = useLocalState<Record<string, AtomData> | null>(
    context, 'sp_atoms', cachedAtoms
  );
  const [error, setError] = useLocalState<string | null>(
    context, 'sp_error', null
  );

  if (!atoms && !error && !fetchInProgress) {
    fetchInProgress = true;
    fetch(resolveAsset('spawnpanel_atom_data.json'))
      .then(r => {
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        return r.json();
      })
      .then(json => {
        cachedAtoms = json['atoms'] || {};
        setAtoms(cachedAtoms);
      })
      .catch(err => {
        fetchInProgress = false;
        setError(String(err));
      });
  }

  return (
    <Window title="Spawn Panel" width={530} height={600} theme="admin">
      <Window.Content>
        {error && (
          <Box color="bad" p={1}>Failed to load atom list: {error}</Box>
        )}
        {!atoms && !error && (
          <Box color="average" mt={3} textAlign="center">Loading atom data...</Box>
        )}
        {atoms && (
          <Stack vertical fill>
            <Stack.Item>
              <CreateObjectSettings />
            </Stack.Item>
            <Stack.Item grow={1}>
              <CreateObject atoms={atoms} />
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};
