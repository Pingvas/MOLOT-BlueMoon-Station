import { useBackend } from '../../../backend';
import { Box, Button, Stack } from '../../../components';
import { CharacterSetupData, CharacterSlot } from '../types';
import { textOrFallback } from '../utils';

// MARK: Constants
const SLOT_LIST_STYLE = {
  display: 'block',
  minHeight: '120px',
  maxHeight: '220px',
  overflowY: 'auto',
  overflowX: 'hidden',
  paddingRight: '2px',
} as const;

const SLOT_BUTTON_STYLE = {
  justifyContent: 'flex-start',
  overflow: 'hidden',
  textOverflow: 'ellipsis',
  whiteSpace: 'nowrap',
} as const;

// MARK: Helpers
const getSlotLabel = (slot: CharacterSlot) => {
  const safeName = textOrFallback(slot.name, `Слот ${slot.index}`);
  return slot.is_empty || safeName === `Слот ${slot.index}`
    ? `Слот ${slot.index}`
    : `[${slot.index}] ${safeName}`;
};

// MARK: Component
export const CharacterSlots = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    slots = [],
    active_slot = 1,
    collapse_empty_slots = true,
  } = data;

  const visibleSlots = collapse_empty_slots
    ? slots.filter((s: CharacterSlot) => !s.is_empty || s.index === active_slot)
    : slots;

  return (
    <Stack vertical>
      {/* MARK: Header */}
      <Stack.Item>
        <Stack align="center">
          <Stack.Item grow>
            <Box bold>Слоты персонажей</Box>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon={collapse_empty_slots ? 'eye-slash' : 'eye'}
              tooltip={collapse_empty_slots ? 'Показать пустые слоты' : 'Скрыть пустые слоты'}
              onClick={() => act('toggle_empty_slots')}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>

      {/* MARK: Slot List */}
      <Stack.Item grow basis={0} style={{ minHeight: 0 }}>
        <Box style={SLOT_LIST_STYLE}>
          <Stack vertical>
            {!visibleSlots.length && (
              <Stack.Item>
                <Box color="label" italic>
                  Нет доступных слотов.
                </Box>
              </Stack.Item>
            )}

            {visibleSlots.map((slot: CharacterSlot) => (
              <Stack.Item key={slot.index}>
                <Button
                  fluid
                  selected={slot.index === active_slot}
                  color={slot.is_empty ? 'transparent' : undefined}
                  icon={slot.is_empty ? 'plus' : 'user'}
                  content={getSlotLabel(slot)}
                  tooltip={slot.is_empty ? undefined : textOrFallback(slot.name, `Слот ${slot.index}`)}
                  onClick={() => act('change_slot', { slot: slot.index })}
                  style={SLOT_BUTTON_STYLE}
                />
              </Stack.Item>
            ))}
          </Stack>
        </Box>
      </Stack.Item>
    </Stack>
  );
};
