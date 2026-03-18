import { useBackend, useLocalState } from '../../../backend';
import {
  Box,
  Button,
  ColorBox,
  Icon,
  Input,
  Section,
  Stack,
  Tabs,
} from '../../../components';
import { CharacterSetupData } from '../types';

export type MarkingEntry = {
  index: number;
  limb_value: number;
  limb_name: string;
  marking_name: string;
  colors: string[];
  active_colors: number;
};

type AvailableMarking = {
  name: string;
  covered_limbs: string[];
  color_channels: number[];
  ckeys_allowed: string[] | null;
};

const ZONE_ICONS: Record<string, string> = {
  'Head': 'hat-cowboy',
  'Chest': 'shirt',
  'Left Arm': 'hand',
  'Right Arm': 'hand',
  'Left Leg': 'shoe-prints',
  'Right Leg': 'shoe-prints',
};

export const MarkingsTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    markings = [],
    tattoopref,
  } = data as any;

  const allMarkings = markings as MarkingEntry[];
  const available_markings = (data as any).available_markings as AvailableMarking[] || [];
  const body_zones = (data as any).body_zones as string[] || [
    'Head', 'Chest', 'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg',
  ];

  const [selectedZone, setSelectedZone] = useLocalState(
    context, 'markings_zone', 'Head',
  );
  const [searchText, setSearchText] = useLocalState(
    context, 'markings_search', '',
  );

  // Filter applied markings for selected zone
  const zoneMarkings = allMarkings.filter(
    (m) => m.limb_name === selectedZone,
  );

  // Count markings per zone for badges
  const zoneCounts: Record<string, number> = {};
  for (const m of allMarkings) {
    zoneCounts[m.limb_name] = (zoneCounts[m.limb_name] || 0) + 1;
  }

  // Filter available markings for the zone (+ search)
  const filteredMarkings = available_markings.filter((m) => {
    if (!m.covered_limbs.includes(selectedZone)) {
      return false;
    }
    if (searchText) {
      return m.name.toLowerCase().includes(searchText.toLowerCase());
    }
    return true;
  });

  // Get already-applied marking names for this zone to show indicator
  const appliedNames = new Set(
    zoneMarkings.map((m) => m.marking_name),
  );

  return (
    <Stack fill>
      {/* Left Column - Zone selector & Add markings */}
      <Stack.Item basis="45%" grow={0}>
        <Stack vertical fill>
          {/* Zone Tabs */}
          <Stack.Item>
            <Section
              title="Часть тела"
              fitted>
              <Tabs vertical>
                {body_zones.map((zone) => (
                  <Tabs.Tab
                    key={zone}
                    selected={selectedZone === zone}
                    onClick={() => setSelectedZone(zone)}>
                    <Stack align="center" justify="space-between" fill>
                      <Stack.Item>
                        <Icon name={ZONE_ICONS[zone] || 'circle'} mr={1} />
                        {zone}
                      </Stack.Item>
                      {(zoneCounts[zone] || 0) > 0 && (
                        <Stack.Item>
                          <Box
                            as="span"
                            px={0.7}
                            py={0.2}
                            backgroundColor="rgba(255,255,255,0.12)"
                            style={{
                              borderRadius: '10px',
                              fontSize: '0.85em',
                            }}>
                            {zoneCounts[zone]}
                          </Box>
                        </Stack.Item>
                      )}
                    </Stack>
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Stack.Item>

          {/* Available Markings */}
          <Stack.Item grow>
            <Section
              title="Добавить маркинг"
              fill
              scrollable
              buttons={
                <Button
                  icon="paint-brush"
                  tooltip="Менеджер татуировок"
                  onClick={() => act('open_tattoo_manager')}
                />
              }>
              <Input
                fluid
                placeholder="Поиск маркинга..."
                value={searchText}
                onInput={(e, val) => setSearchText(val)}
                mb={1}
              />
              {filteredMarkings.length === 0 && (
                <Box color="label" italic textAlign="center" mt={1}>
                  {searchText
                    ? 'Ничего не найдено'
                    : 'Нет маркингов для этой зоны'}
                </Box>
              )}
              <Stack vertical>
                {filteredMarkings.map((marking) => (
                  <Stack.Item key={marking.name}>
                    <Box
                      style={{
                        padding: '4px 8px',
                        borderRadius: '3px',
                        cursor: 'pointer',
                        background: appliedNames.has(marking.name)
                          ? 'rgba(80, 180, 80, 0.15)'
                          : 'rgba(255,255,255,0.03)',
                      }}
                      onClick={() => act('marking_add', {
                        limb: selectedZone,
                        marking: marking.name,
                      })}>
                      <Stack align="center">
                        <Stack.Item grow>
                          <Box
                            bold={appliedNames.has(marking.name)}
                            color={appliedNames.has(marking.name) ? 'good' : undefined}>
                            {marking.name}
                          </Box>
                          <Box
                            color="label"
                            fontSize="0.85em">
                            {marking.covered_limbs.join(', ')}
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Stack>
                            {/* Add to this zone */}
                            <Stack.Item>
                              <Button
                                compact
                                icon="plus"
                                color="green"
                                tooltip={`Добавить на ${selectedZone}`}
                                onClick={(e) => {
                                  e.stopPropagation();
                                  act('marking_add', {
                                    limb: selectedZone,
                                    marking: marking.name,
                                  });
                                }}
                              />
                            </Stack.Item>
                            {/* Add to all limbs */}
                            {marking.covered_limbs.length > 1 && (
                              <Stack.Item>
                                <Button
                                  compact
                                  icon="plus-circle"
                                  color="teal"
                                  tooltip="Добавить на все части"
                                  onClick={(e) => {
                                    e.stopPropagation();
                                    act('marking_add', {
                                      limb: 'All',
                                      marking: marking.name,
                                    });
                                  }}
                                />
                              </Stack.Item>
                            )}
                          </Stack>
                        </Stack.Item>
                      </Stack>
                    </Box>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>

      {/* Right Column - Applied markings */}
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={`Маркинги: ${selectedZone}`}
          buttons={
            <Stack>
              <Stack.Item>
                <Button
                  icon="eraser"
                  color="caution"
                  tooltip={`Очистить ${selectedZone}`}
                  disabled={zoneMarkings.length === 0}
                  onClick={() => act('markings_clear_limb', {
                    limb: selectedZone,
                  })}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="trash"
                  color="bad"
                  tooltip="Удалить все маркинги"
                  disabled={allMarkings.length === 0}
                  onClick={() => act('markings_remove_all')}
                />
              </Stack.Item>
            </Stack>
          }>
          {zoneMarkings.length === 0 ? (
            <Box color="label" italic textAlign="center" mt={3}>
              <Icon name="palette" size={3} mb={1} /><br />
              Нет маркингов на этой части тела.
              <br />
              <Box mt={1} fontSize="0.9em">
                Выберите маркинг слева, чтобы добавить.
              </Box>
            </Box>
          ) : (
            <Stack vertical>
              {zoneMarkings.map((marking, idx) => (
                <Stack.Item key={marking.index}>
                  <Box
                    style={{
                      padding: '8px',
                      marginBottom: '4px',
                      borderRadius: '4px',
                      background: 'rgba(255,255,255,0.05)',
                      border: '1px solid rgba(255,255,255,0.08)',
                    }}>
                    <Stack align="center">
                      {/* Marking Name */}
                      <Stack.Item grow>
                        <Box bold fontSize="1.05em">
                          {marking.marking_name}
                        </Box>
                      </Stack.Item>

                      {/* Color Boxes */}
                      <Stack.Item>
                        <Stack>
                          {marking.colors.slice(0, marking.active_colors || 3).map(
                            (color, ci) => (
                              <Stack.Item key={ci}>
                                <Button
                                  style={{
                                    padding: '2px',
                                    minWidth: '28px',
                                    minHeight: '28px',
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                  }}
                                  tooltip={`Цвет ${ci + 1}`}
                                  onClick={() => act('marking_color', {
                                    index: marking.index,
                                    color_num: ci + 1,
                                  })}>
                                  <ColorBox
                                    color={color}
                                    style={{
                                      width: '20px',
                                      height: '20px',
                                    }}
                                  />
                                </Button>
                              </Stack.Item>
                            ),
                          )}
                        </Stack>
                      </Stack.Item>

                      {/* Reorder */}
                      <Stack.Item ml={1}>
                        <Button
                          compact
                          icon="angle-up"
                          disabled={idx === 0}
                          tooltip="Выше"
                          onClick={() => act('marking_up', {
                            index: marking.index,
                          })}
                        />
                        <Button
                          compact
                          icon="angle-down"
                          disabled={idx === zoneMarkings.length - 1}
                          tooltip="Ниже"
                          onClick={() => act('marking_down', {
                            index: marking.index,
                          })}
                        />
                      </Stack.Item>

                      {/* Delete */}
                      <Stack.Item>
                        <Button
                          compact
                          icon="times"
                          color="bad"
                          tooltip="Удалить"
                          onClick={() => act('marking_remove', {
                            index: marking.index,
                          })}
                        />
                      </Stack.Item>
                    </Stack>
                  </Box>
                </Stack.Item>
              ))}
            </Stack>
          )}

          {/* Total count across all zones */}
          {allMarkings.length > 0 && (
            <Box
              color="label"
              fontSize="0.85em"
              textAlign="center"
              mt={2}>
              Всего маркингов: {allMarkings.length}
            </Box>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};
