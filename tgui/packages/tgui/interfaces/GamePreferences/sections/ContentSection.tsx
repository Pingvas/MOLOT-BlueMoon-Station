import { useBackend } from '../../../backend';
import { Dropdown, Stack } from '../../../components';
import { CONSENT_OPTIONS, PrefRow } from '../components/PrefRow';

const PREF_TOGGLES: { key: string; label: string; flag: string }[] = [
  { key: 'verb_consent', label: 'Lewd вербы', flag: 'verb_consent' },
  { key: 'ranged_verb_pref', label: 'Lewd вербы с расстояния', flag: 'ranged_verb_pref' },
  { key: 'lewd_verb_sounds', label: 'Звуки lewd вербов', flag: 'lewd_verb_sounds' },
  { key: 'arousable', label: 'Возбуждение', flag: 'arousable' },
  { key: 'sexknotting', label: 'Завязывание узлов (Knotting)', flag: 'sexknotting' },
  { key: 'genital_examine', label: 'Текст осмотра гениталий', flag: 'genital_examine' },
  { key: 'vore_examine', label: 'Текст осмотра вор', flag: 'vore_examine' },
  { key: 'medihound_sleeper', label: 'Вороятные Medihound sleeper', flag: 'medihound_sleeper' },
  { key: 'eating_noises', label: 'Звуки поедания (вор)', flag: 'eating_noises' },
  { key: 'digestion_noises', label: 'Звуки переваривания', flag: 'digestion_noises' },
  { key: 'trash_forcefeed', label: 'Кормление мусором', flag: 'trash_forcefeed' },
  { key: 'forced_fem', label: 'Принудительная феминизация', flag: 'forced_fem' },
  { key: 'forced_masc', label: 'Принудительная маскулинизация', flag: 'forced_masc' },
  { key: 'hypno', label: 'Lewd гипноз', flag: 'hypno' },
  { key: 'bimbofication', label: 'Бимбофикация', flag: 'bimbofication' },
  { key: 'breast_enlargement', label: 'Увеличение груди', flag: 'breast_enlargement' },
  { key: 'penis_enlargement', label: 'Увеличение пениса', flag: 'penis_enlargement' },
  { key: 'butt_enlargement', label: 'Увеличение попы', flag: 'butt_enlargement' },
  { key: 'belly_inflation', label: 'Вздутие живота', flag: 'belly_inflation' },
  { key: 'never_hypno', label: 'Гипноз (защита)', flag: 'never_hypno' },
  { key: 'no_aphro', label: 'Афродизиаки', flag: 'no_aphro' },
  { key: 'no_ass_slap', label: 'Шлепки по попе', flag: 'no_ass_slap' },
  { key: 'no_auto_wag', label: 'Автоматическое виляние хвостом', flag: 'no_auto_wag' },
  { key: 'chastity_pref', label: 'Взаимодействие с поясом верности', flag: 'chastity_pref' },
  { key: 'stimulation_pref', label: 'Модификаторы стимуляции гениталий', flag: 'stimulation_pref' },
  { key: 'edging_pref', label: 'Эджинг', flag: 'edging_pref' },
  { key: 'cum_onto_pref', label: 'Покрытие спермой', flag: 'cum_onto_pref' },
  { key: 'sex_jitter', label: 'Дрожь при сексе', flag: 'sex_jitter' },
  { key: 'dance_disco', label: 'Танцевать возле диско-шара', flag: 'dance_disco' },
];

const CONSENT_PREFS: { key: string; label: string; flag: string }[] = [
  { key: 'tattoopref', label: 'Татуировки от других', flag: 'tattoopref' },
  { key: 'extremeharm', label: 'Экстремальный ERP (вред)', flag: 'extremeharm' },
  { key: 'unholypref', label: 'Нечестивые ERP вербы', flag: 'unholypref' },
];

export const ContentSection = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Stack vertical>
      {PREF_TOGGLES.map(({ key, label, flag }) => (
        <PrefRow
          key={key}
          label={label}
          checked={data[key]}
          onClick={() => act('pref', { pref: flag })}
        />
      ))}
      {CONSENT_PREFS.map(({ key, label, flag }) => (
        <Stack.Item key={key}>
          <Stack align="center" fill className="GamePreferences__row">
            <Stack.Item grow basis={0}>
              <div className="GamePreferences__label">{label}</div>
            </Stack.Item>
            <Stack.Item>
              <Dropdown
                width="160px"
                options={CONSENT_OPTIONS.map(o => o.label)}
                selected={CONSENT_OPTIONS.find(o => o.value === data[key])?.label || 'Нет'}
                onSelected={value => {
                  const opt = CONSENT_OPTIONS.find(o => o.label === value);
                  if (opt) act('set_consent_pref', { pref: flag, value: opt.value });
                }}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
    </Stack>
  );
};
