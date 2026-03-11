import { useBackend } from '../../../backend';
import { Button, Section, Stack } from '../../../components';
import { CharacterSetupData, CharacterSlot } from '../types';

export const CharacterSlots = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    slots = [],
    active_slot = 1,
    collapse_empty_slots = false,
  } = data;

  const visibleSlots = collapse_empty_slots
    ? slots.filter((s: CharacterSlot) => !s.is_empty || s.index === active_slot)
    : slots;

  return (
    <Section
      title="Slots"
      buttons={
        <Button
          icon={collapse_empty_slots ? 'eye-slash' : 'eye'}
          tooltip={collapse_empty_slots ? 'Show empty slots' : 'Hide empty slots'}
          onClick={() => act('toggle_empty_slots')}
        />
      }>
      <Stack vertical>
        {visibleSlots.map((slot: CharacterSlot) => (
          <Stack.Item key={slot.index}>
            <Button
              fluid
              selected={slot.index === active_slot}
              color={slot.is_empty ? 'transparent' : undefined}
              icon={slot.is_empty ? 'plus' : 'user'}
              content={slot.is_empty ? `Slot ${slot.index}` : slot.name}
              onClick={() => act('change_slot', { slot: slot.index })}
            />
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};
