import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Input, NoticeBox, Section, Stack, Tabs } from '../../components';

import { MAX_ATOM_DISPLAY, TAB_TYPES } from './constants';
import { AtomData, SpawnPanelData } from './types';

type CreateObjectProps = {
  atoms: Record<string, AtomData>;
};

export const CreateObject = (props: CreateObjectProps, context: any) => {
  const { act, data } = useBackend<SpawnPanelData>(context);
  const { selected_object } = data;
  const { atoms } = props;

  const [activeTab, setActiveTab] = useLocalState<string>(
    context, 'sp_tab', 'Objects'
  );
  const [searchText, setSearchText] = useLocalState<string>(
    context, 'sp_search', ''
  );
  const [searchByType, setSearchByType] = useLocalState<boolean>(
    context, 'sp_bytype', false
  );

  const hasSearch = searchText.length > 0;

  // Count total for current tab (shown in hint)
  let tabTotal = 0;
  const allEntries = Object.entries(atoms);
  for (let i = 0; i < allEntries.length; i++) {
    if (allEntries[i][1].type === activeTab) tabTotal++;
  }

  // Filter only when user types something
  const filteredAtoms: Array<[string, AtomData]> = [];
  if (hasSearch) {
    const lower = searchText.toLowerCase();
    for (let i = 0; i < allEntries.length && filteredAtoms.length < MAX_ATOM_DISPLAY; i++) {
      const [typepath, atom] = allEntries[i];
      if (atom.type !== activeTab) continue;
      if (searchByType) {
        if (typepath.toLowerCase().includes(lower)) {
          filteredAtoms.push([typepath, atom]);
        }
      } else {
        if (atom.name.toLowerCase().includes(lower)) {
          filteredAtoms.push([typepath, atom]);
        }
      }
    }
  }

  return (
    <Section
      title="Atom List"
      fill
      buttons={
        <Stack align="center" spacing={1}>
          <Stack.Item>
            <Button
              compact
              selected={searchByType}
              tooltip={searchByType ? 'Searching by typepath — click for name' : 'Searching by name — click for typepath'}
              onClick={() => setSearchByType(!searchByType)}
            >
              {searchByType ? 'Type' : 'Name'}
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Input
              placeholder="Search..."
              value={searchText}
              width="140px"
              onInput={(_e: any, val: string) => setSearchText(val)}
            />
          </Stack.Item>
        </Stack>
      }
    >
      <Tabs>
        {TAB_TYPES.map(tab => (
          <Tabs.Tab
            key={tab}
            selected={activeTab === tab}
            onClick={() => {
              setActiveTab(tab);
              setSearchText('');
            }}
          >
            {tab}
          </Tabs.Tab>
        ))}
      </Tabs>

      {/* Search hint when empty */}
      {!hasSearch && (
        <NoticeBox>
          {tabTotal} atoms in {activeTab}. Begin typing to search...
        </NoticeBox>
      )}

      {/* No results */}
      {hasSearch && filteredAtoms.length === 0 && (
        <NoticeBox danger>
          No results for &quot;{searchText}&quot;
        </NoticeBox>
      )}

      {/* Results list */}
      {hasSearch && filteredAtoms.length > 0 && (
        <Box
          style={{
            'overflow-y': 'auto',
            'max-height': '280px',
          }}
        >
          {filteredAtoms.length >= MAX_ATOM_DISPLAY && (
            <Box color="average" fontSize="11px" p="2px 4px">
              Showing first {MAX_ATOM_DISPLAY} results — refine your search.
            </Box>
          )}
          {filteredAtoms.map(([typepath, atom]) => (
            <AtomRow
              key={typepath}
              typepath={typepath}
              atom={atom}
              selected={selected_object === typepath}
              onSelect={() => act('selected-atom-changed', { newObj: typepath })}
              onSpawn={() => act('create-atom-action', { selected_atom: typepath })}
            />
          ))}
        </Box>
      )}
    </Section>
  );
};

type AtomRowProps = {
  key?: any;
  typepath: string;
  atom: AtomData;
  selected: boolean;
  onSelect: () => void;
  onSpawn: () => void;
};

const AtomRow = (props: AtomRowProps) => {
  const { typepath, atom, selected, onSelect, onSpawn } = props;
  return (
    <Button
      fluid
      color={selected ? 'green' : 'transparent'}
      style={{ 'padding': '3px 6px', 'text-align': 'left' }}
      onClick={onSelect}
      onDblClick={onSpawn}
    >
      <Box bold color={selected ? 'white' : 'default'}>
        {atom.name}
      </Box>
      <Box color="label" fontSize="10px" style={{ 'word-break': 'break-all' }}>
        {typepath}
      </Box>
    </Button>
  );
};
