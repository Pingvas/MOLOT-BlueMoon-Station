import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Input, Section, Stack, Tabs } from '../../components';

import { TAB_TYPES } from './constants';
import { AtomData, SpawnPanelData } from './types';

type CreateObjectProps = {
  atoms: Record<string, AtomData>;
};

export const CreateObject = (props: CreateObjectProps, context) => {
  const { act } = useBackend<SpawnPanelData>(context);
  const { atoms } = props;

  const [activeTab, setActiveTab] = useLocalState<string>(context, 'spawnpanel_tab', 'Objects');
  const [searchText, setSearchText] = useLocalState<string>(context, 'spawnpanel_search', '');

  const filteredAtoms = Object.entries(atoms).filter(([typepath, atom]) => {
    if (atom.type !== activeTab) return false;
    if (!searchText) return true;
    const lower = searchText.toLowerCase();
    return atom.name.toLowerCase().includes(lower)
      || typepath.toLowerCase().includes(lower);
  });

  return (
    <Section
      title="Atoms"
      buttons={
        <Input
          placeholder="Search..."
          value={searchText}
          width="150px"
          onInput={(e, val) => setSearchText(val)}
        />
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
      <Box
        style={{
          'height': '340px',
          'overflow-y': 'auto',
        }}
      >
        {filteredAtoms.length === 0 && (
          <Box color="average" mt={1} ml={1}>
            No results.
          </Box>
        )}
        {filteredAtoms.map(([typepath, atom]) => (
          <AtomRow
            key={typepath}
            typepath={typepath}
            atom={atom}
            onSelect={() => act('selected-atom-changed', { type: typepath, name: atom.name })}
          />
        ))}
      </Box>
    </Section>
  );
};

type AtomRowProps = {
  key?: any;
  typepath: string;
  atom: AtomData;
  onSelect: () => void;
};

const AtomRow = (props: AtomRowProps) => {
  const { typepath, atom, onSelect } = props;
  return (
    <Stack align="center" className="candystripe" style={{ 'padding': '2px 4px' }}>
      <Stack.Item>
        {atom.icon ? (
          <Box
            as="img"
            src={atom.icon}
            style={{
              'width': '32px',
              'height': '32px',
              'image-rendering': 'pixelated',
              'vertical-align': 'middle',
            }}
          />
        ) : (
          <Box
            style={{
              'width': '32px',
              'height': '32px',
              'display': 'inline-block',
            }}
          />
        )}
      </Stack.Item>
      <Stack.Item grow={1} overflow="hidden">
        <Box bold>{atom.name}</Box>
        <Box color="label" fontSize="10px" style={{ 'word-break': 'break-all' }}>
          {typepath}
        </Box>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="plus"
          tooltip="Select this atom"
          onClick={onSelect}
        />
      </Stack.Item>
    </Stack>
  );
};
