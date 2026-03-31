import { resolveAsset } from '../../assets';
import { useLocalState } from '../../backend';
import { Box, Stack } from '../../components';
import { Window } from '../../layouts';

import { CreateObject } from './CreateObject';
import { CreateObjectSettings } from './CreateObjectSettings';
import { AtomData } from './types';

// Module-level flag so we only start one fetch per session
let spawnPanelFetchStarted = false;

export const SpawnPanel = (props: any, context: any) => {
  const [atoms, setAtoms] = useLocalState<Record<string, AtomData> | null>(
    context, 'sp_atoms', null
  );
  const [error, setError] = useLocalState<string | null>(
    context, 'sp_error', null
  );

  if (!atoms && !error && !spawnPanelFetchStarted) {
    spawnPanelFetchStarted = true;
    fetch(resolveAsset('spawnpanel_atom_data.json'))
      .then(r => {
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        return r.json();
      })
      .then(json => setAtoms(json['atoms'] || {}))
      .catch(err => {
        spawnPanelFetchStarted = false; // allow retry on next open
        setError(String(err));
      });
  }

  return (
    <Window title="Spawn Panel" width={820} height={580} theme="admin">
      <Window.Content>
        {error && (
          <Box color="bad">Failed to load atom list: {error}</Box>
        )}
        {!atoms && !error && (
          <Box color="average">Loading atom data...</Box>
        )}
        {atoms && (
          <Stack fill>
            <Stack.Item width="350px">
              <CreateObject atoms={atoms} />
            </Stack.Item>
            <Stack.Item grow={1}>
              <CreateObjectSettings />
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
}
