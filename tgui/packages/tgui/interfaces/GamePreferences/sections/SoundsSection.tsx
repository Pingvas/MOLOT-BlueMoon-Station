import { useBackend } from '../../../backend';
import { Stack } from '../../../components';
import { PrefRow } from '../components/PrefRow';

type SoundsData = {
  sound_lobby: boolean;
  sound_midi: boolean;
  sound_instruments: boolean;
  sound_jukeboxes: boolean;
  sound_personal_jukeboxes: boolean;
  sound_ambience: boolean;
  sound_ship_ambience: boolean;
  sound_announcements: boolean;
  sound_bark: boolean;
  sound_prayers: boolean;
  sound_adminhelp: boolean;
};

const SOUND_TOGGLES: { key: string; label: string }[] = [
  { key: 'sound_lobby', label: 'Музыка лобби' },
  { key: 'sound_midi', label: 'Админские MIDI' },
  { key: 'sound_instruments', label: 'Музыкальные инструменты' },
  { key: 'sound_jukeboxes', label: 'Джукбоксы' },
  { key: 'sound_personal_jukeboxes', label: 'Персональные музыкальные шкатулки' },
  { key: 'sound_ambience', label: 'Эмбиент (окружающие звуки)' },
  { key: 'sound_ship_ambience', label: 'Фоновый гул станции' },
  { key: 'sound_announcements', label: 'Звуки объявлений' },
  { key: 'sound_bark', label: 'Голосовые байки (вокал)' },
  { key: 'sound_prayers', label: 'Звуки молитв' },
  { key: 'sound_adminhelp', label: 'Звуки AdminHelp' },
];

export const SoundsSection = (props, context) => {
  const { act, data } = useBackend<SoundsData>(context);

  return (
    <Stack vertical>
      {SOUND_TOGGLES.map(({ key, label }) => (
        <PrefRow
          key={key}
          label={label}
          checked={data[key]}
          onClick={() => act('toggle_sound', { flag: key })}
        />
      ))}
    </Stack>
  );
};
