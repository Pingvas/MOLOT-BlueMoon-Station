import { classes } from 'common/react';
import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Input, NoticeBox, Section, Stack, Tabs } from '../../components';

import { MAX_ATOM_DISPLAY, TAB_TYPE_COLORS, TAB_TYPE_LETTERS, TAB_TYPES } from './constants';
import { AtomData, SpawnPanelData } from './types';

type CreateObjectProps = {
  atoms: Record<string, AtomData>;
};

export const CreateObject = (props: CreateObjectProps, context: any) => {
  const { act, data } = useBackend<SpawnPanelData>(context);
  const { selected_object } = data;
  const { atoms } = props;

  const [activeTab, setActiveTab] = useLocalState<string>(context, 'sp_tab', 'Objects');
  const [searchText, setSearchText] = useLocalState<string>(context, 'sp_search', '');
  const [searchByType, setSearchByType] = useLocalState<boolean>(context, 'sp_bytype', false);

  const hasSearch = searchText.length > 0;
  const lower = searchText.toLowerCase();

  let tabTotal = 0;
  const allEntries = Object.entries(atoms);
  for (let i = 0; i < allEntries.length; i++) {
    if (allEntries[i][1].type === activeTab) tabTotal++;
  }

  const filteredAtoms: Array<[string, AtomData]> = [];
  if (hasSearch) {
    for (let i = 0; i < allEntries.length && filteredAtoms.length < MAX_ATOM_DISPLAY; i++) {
      const [typepath, atom] = allEntries[i];
      if (atom.type !== activeTab) continue;
      const match = searchByType
        ? typepath.toLowerCase().includes(lower)
        : atom.name.toLowerCase().includes(lower);
      if (match) filteredAtoms.push([typepath, atom]);
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
              tooltip={searchByType ? 'Searching by typepath (click for name)' : 'Searching by name (click for typepath)'}
              onClick={() => setSearchByType(!searchByType)}
            >
              {searchByType ? 'Path' : 'Name'}
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Input
              placeholder="Search..."
              value={searchText}
              width="150px"
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
            onClick={() => { setActiveTab(tab); setSearchText(''); }}
          >
            <Box
              as="span"
              style={{
                'background': TAB_TYPE_COLORS[tab],
                'color': '#fff',
                'border-radius': '3px',
                'padding': '0 5px',
                'margin-right': '4px',
                'font-size': '10px',
                'font-weight': 'bold',
              }}
            >
              {TAB_TYPE_LETTERS[tab]}
            </Box>
            {tab}
          </Tabs.Tab>
        ))}
      </Tabs>

      {!hasSearch && (
        <NoticeBox>
          {tabTotal.toLocaleString()} {activeTab.toLowerCase()} available — begin typing to search
        </NoticeBox>
      )}
      {hasSearch && filteredAtoms.length === 0 && (
        <NoticeBox danger>No results for &quot;{searchText}&quot;</NoticeBox>
      )}

      {hasSearch && filteredAtoms.length > 0 && (
        <Box style={{ 'overflow-y': 'auto', 'max-height': '310px' }}>
          {filteredAtoms.length >= MAX_ATOM_DISPLAY && (
            <Box color="average" fontSize="11px" p="2px 6px">
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
  const color = TAB_TYPE_COLORS[atom.type] ?? '#666';
  const letter = TAB_TYPE_LETTERS[atom.type] ?? '?';

  return (
    <Box
      className={selected ? '' : 'candystripe'}
      style={{
        'display': 'flex',
        'align-items': 'center',
        'padding': '3px 6px',
        'cursor': 'pointer',
        'background-color': selected ? 'rgba(0, 200, 100, 0.2)' : undefined,
        'border-left': selected ? '3px solid #00c864' : '3px solid transparent',
        'transition': 'background 0.1s',
      }}
      onClick={onSelect}
      onDblClick={onSpawn}
    >
      {/* Type icon: Game sprite if available, letter badge as fallback */}
      {atom.iconid ? (
        <Box
          style={{
            'width': '20px',
            'height': '20px',
            'flex-shrink': '0',
            'margin-right': '8px',
            'overflow': 'hidden',
            'position': 'relative',
          }}
        >
          <span
            className={classes(['spawnpanel32x32', atom.iconid])}
            style={{
              'display': 'block',
              'transform': 'scale(0.625)',
              'transform-origin': 'top left',
              'image-rendering': 'pixelated',
            }}
          />
        </Box>
      ) : (
        <Box
          style={{
            'width': '20px',
            'height': '20px',
            'background': color,
            'border-radius': '3px',
            'display': 'flex',
            'align-items': 'center',
            'justify-content': 'center',
            'color': '#fff',
            'font-size': '11px',
            'font-weight': 'bold',
            'flex-shrink': '0',
            'margin-right': '8px',
            'opacity': selected ? 1 : 0.8,
          }}
        >
          {letter}
        </Box>
      )}
      {/* Text */}
      <Box style={{ 'overflow': 'hidden', 'flex': '1' }}>
        <Box
          bold
          color={selected ? '#00e87a' : 'default'}
          style={{ 'white-space': 'nowrap', 'overflow': 'hidden', 'text-overflow': 'ellipsis' }}
        >
          {atom.name}
        </Box>
        <Box
          color="label"
          fontSize="10px"
          style={{ 'white-space': 'nowrap', 'overflow': 'hidden', 'text-overflow': 'ellipsis' }}
        >
          {typepath}
        </Box>
      </Box>
      {/* Double-click hint when selected */}
      {selected && (
        <Box color="label" fontSize="10px" style={{ 'flex-shrink': '0', 'margin-left': '4px' }}>
          dbl-click=spawn
        </Box>
      )}
    </Box>
  );
};
