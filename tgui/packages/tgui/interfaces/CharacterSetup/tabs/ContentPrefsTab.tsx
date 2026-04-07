import { useBackend } from '../../../backend';
import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from '../../../components';
import { CharacterSetupData } from '../types';

// toggles bitflags
const VERB_CONSENT = 1 << 17;
const LEWD_VERB_SOUNDS = 1 << 18;
const RANGED_VERBS_CONSENT = 1 << 21;

// cit_toggles bitflags
const MEDIHOUND_SLEEPER = 1 << 0;
const EATING_NOISES = 1 << 1;
const DIGESTION_NOISES = 1 << 2;
const BREAST_ENLARGEMENT = 1 << 3;
const PENIS_ENLARGEMENT = 1 << 4;
const FORCED_FEM = 1 << 5;
const FORCED_MASC = 1 << 6;
const HYPNO = 1 << 7;
const NEVER_HYPNO = 1 << 8;
const NO_APHRO = 1 << 9;
const NO_ASS_SLAP = 1 << 10;
const BIMBOFICATION = 1 << 11;
const NO_AUTO_WAG = 1 << 12;
const GENITAL_EXAMINE = 1 << 13;
const VORE_EXAMINE = 1 << 14;
const TRASH_FORCEFEED = 1 << 15;
const BUTT_ENLARGEMENT = 1 << 16;
const BELLY_INFLATION = 1 << 17;
const CHASTITY = 1 << 18;
const STIMULATION = 1 << 19;
const EDGING = 1 << 20;
const NO_DISCO_DANCE = 1 << 21;
const CUM_ONTO = 1 << 22;
const SEX_JITTER = 1 << 23;

const PrefButton = (props: {
  value: string;
  onChange: (value: string) => void;
}) => {
  return (
    <>
      <Button
        icon="check"
        color={props.value === 'Yes' ? 'green' : 'default'}
        onClick={() => props.onChange('Yes')}
      >
        Yes
      </Button>
      <Button
        icon="question"
        color={props.value === 'Ask' ? 'yellow' : 'default'}
        onClick={() => props.onChange('Ask')}
      >
        Ask
      </Button>
      <Button
        icon="times"
        color={props.value === 'No' ? 'red' : 'default'}
        onClick={() => props.onChange('No')}
      >
        No
      </Button>
    </>
  );
};

// Two-value toggle (Yes/No)
const PrefToggle = (props: {
  value: string;
  onChange: (value: string) => void;
}) => {
  return (
    <>
      <Button
        icon="check"
        color={props.value === 'Yes' ? 'green' : 'default'}
        onClick={() => props.onChange('Yes')}
      >
        Yes
      </Button>
      <Button
        icon="times"
        color={props.value === 'No' ? 'red' : 'default'}
        onClick={() => props.onChange('No')}
      >
        No
      </Button>
    </>
  );
};

export const ContentPrefsTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    erppref = 'Ask',
    nonconpref = 'Ask',
    vorepref = 'Ask',
    extremepref = 'No',
    unholypref = 'No',
    mobsexpref = 'No',
    hornyantagspref = 'No',
    tattoopref = 'Ask',
    extremeharm = 'No',
    cit_toggles = 0,
    toggles = 0,
    arousable = false,
    sexknotting = false,
    lust_tolerance = 100,
    sexual_potency = 15,
  } = data as any;

  return (
    <Stack vertical>
      {/* Consent preferences */}
      <Stack.Item>
        <Section title="Настройки согласия">
          <Stack>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="ERP">
                  <PrefButton
                    value={erppref}
                    onChange={(v) => act('set_content_pref', {
                      pref: 'erp_pref', value: v,
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Non-Con">
                  <PrefButton
                    value={nonconpref}
                    onChange={(v) => act('set_content_pref', {
                      pref: 'noncon_pref', value: v,
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Vore">
                  <PrefButton
                    value={vorepref}
                    onChange={(v) => act('set_content_pref', {
                      pref: 'vore_pref', value: v,
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Экстрим">
                  <PrefButton
                    value={extremepref}
                    onChange={(v) => act('set_content_pref', {
                      pref: 'extreme_pref', value: v,
                    })}
                  />
                </LabeledList.Item>
                {extremepref !== 'No' && (
                  <LabeledList.Item label="Жёсткий ERP">
                    <PrefButton
                      value={extremeharm}
                      onChange={(v) => act('set_content_pref', {
                        pref: 'extremeharm', value: v,
                      })}
                    />
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Священное">
                  <PrefButton
                    value={unholypref}
                    onChange={(v) => act('set_content_pref', {
                      pref: 'unholy_pref', value: v,
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Мобы Non-Con">
                  <PrefToggle
                    value={mobsexpref}
                    onChange={(v) => act('toggle_flag', {
                      flag: 'mobsex_pref',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Хорни-антаги">
                  <PrefToggle
                    value={hornyantagspref}
                    onChange={(v) => act('toggle_flag', {
                      flag: 'hornyantags_pref',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Тату">
                  <PrefButton
                    value={tattoopref}
                    onChange={(v) => act('set_content_pref', {
                      pref: 'tattoo_pref', value: v,
                    })}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* Lewd Settings */}
      <Stack.Item>
        <Section title="18+ настройки">
          <Stack>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Сист. возбуждения">
                  <Button.Checkbox
                    checked={arousable}
                    content={arousable ? 'Вкл.' : 'Выкл.'}
                    onClick={() => act('toggle_arousable')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Узлы">
                  <Button.Checkbox
                    checked={sexknotting}
                    onClick={() => act('toggle_knotting')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="18+ вербы">
                  <Button.Checkbox
                    checked={!!(toggles & VERB_CONSENT)}
                    onClick={() => act('toggle_flag', {
                      flag: 'verb_consent',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Звуки 18+ вербов">
                  <Button.Checkbox
                    checked={!!(toggles & LEWD_VERB_SOUNDS)}
                    onClick={() => act('toggle_flag', {
                      flag: 'lewd_verb_sounds',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Дальние 18+ вербы">
                  <Button.Checkbox
                    checked={!!(toggles & RANGED_VERBS_CONSENT)}
                    onClick={() => act('toggle_flag', {
                      flag: 'ranged_verb_consent',
                    })}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Порог похоти">
                  <NumberInput
                    value={lust_tolerance}
                    minValue={0}
                    maxValue={200}
                    step={5}
                    onChange={(e, value) => act('set_lust_tolerance', {
                      value,
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Потенция">
                  <NumberInput
                    value={sexual_potency}
                    minValue={0}
                    maxValue={100}
                    step={1}
                    onChange={(e, value) => act('set_sexual_potency', {
                      value,
                    })}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* Content Toggles */}
      <Stack.Item>
        <Section title="Переключатели контента">
          <Stack>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Осм. гениталий">
                  <Button.Checkbox
                    checked={!!(cit_toggles & GENITAL_EXAMINE)}
                    onClick={() => act('toggle_cit', {
                      flag: 'genital_examine',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Осм. вора">
                  <Button.Checkbox
                    checked={!!(cit_toggles & VORE_EXAMINE)}
                    onClick={() => act('toggle_cit', {
                      flag: 'vore_examine',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Медихаунд спячка">
                  <Button.Checkbox
                    checked={!!(cit_toggles & MEDIHOUND_SLEEPER)}
                    onClick={() => act('toggle_cit', {
                      flag: 'hound_sleeper',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Звуки еды">
                  <Button.Checkbox
                    checked={!!(cit_toggles & EATING_NOISES)}
                    onClick={() => act('toggle_cit', {
                      flag: 'toggleeatingnoise',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Звуки пищеварения">
                  <Button.Checkbox
                    checked={!!(cit_toggles & DIGESTION_NOISES)}
                    onClick={() => act('toggle_cit', {
                      flag: 'toggledigestionnoise',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Принуд. феминизация">
                  <Button.Checkbox
                    checked={!!(cit_toggles & FORCED_FEM)}
                    onClick={() => act('toggle_cit', {
                      flag: 'feminization',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Принуд. маскулинизация">
                  <Button.Checkbox
                    checked={!!(cit_toggles & FORCED_MASC)}
                    onClick={() => act('toggle_cit', {
                      flag: 'masculinization',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="18+ гипноз">
                  <Button.Checkbox
                    checked={!!(cit_toggles & HYPNO)}
                    onClick={() => act('toggle_cit', {
                      flag: 'hypno',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Гипноз (все)">
                  <Button.Checkbox
                    checked={!(cit_toggles & NEVER_HYPNO)}
                    content={cit_toggles & NEVER_HYPNO ? 'Запрещ.' : 'Разреш.'}
                    onClick={() => act('toggle_cit', {
                      flag: 'never_hypno',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Бимбофикация">
                  <Button.Checkbox
                    checked={!!(cit_toggles & BIMBOFICATION)}
                    onClick={() => act('toggle_cit', {
                      flag: 'bimbo',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Афродизиаки">
                  <Button.Checkbox
                    checked={!(cit_toggles & NO_APHRO)}
                    content={cit_toggles & NO_APHRO ? 'Запрещ.' : 'Разрещ.'}
                    onClick={() => act('toggle_cit', {
                      flag: 'aphro',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Шлепки">
                  <Button.Checkbox
                    checked={!(cit_toggles & NO_ASS_SLAP)}
                    content={cit_toggles & NO_ASS_SLAP ? 'Запрещ.' : 'Разрещ.'}
                    onClick={() => act('toggle_cit', {
                      flag: 'ass_slap',
                    })}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <LabeledList>
                <LabeledList.Item label="Увел. груди">
                  <Button.Checkbox
                    checked={!!(cit_toggles & BREAST_ENLARGEMENT)}
                    onClick={() => act('toggle_cit', {
                      flag: 'breast_enlargement',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Увел. пениса">
                  <Button.Checkbox
                    checked={!!(cit_toggles & PENIS_ENLARGEMENT)}
                    onClick={() => act('toggle_cit', {
                      flag: 'penis_enlargement',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Увел. ягодиц">
                  <Button.Checkbox
                    checked={!!(cit_toggles & BUTT_ENLARGEMENT)}
                    onClick={() => act('toggle_cit', {
                      flag: 'butt_enlargement',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Надув. живота">
                  <Button.Checkbox
                    checked={!!(cit_toggles & BELLY_INFLATION)}
                    onClick={() => act('toggle_cit', {
                      flag: 'belly_inflation',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Chastity пояс">
                  <Button.Checkbox
                    checked={!!(cit_toggles & CHASTITY)}
                    onClick={() => act('toggle_cit', {
                      flag: 'chastitypref',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Стимуляция">
                  <Button.Checkbox
                    checked={!!(cit_toggles & STIMULATION)}
                    onClick={() => act('toggle_cit', {
                      flag: 'stimulationpref',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Эджинг">
                  <Button.Checkbox
                    checked={!!(cit_toggles & EDGING)}
                    onClick={() => act('toggle_cit', {
                      flag: 'edgingpref',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Обливание">
                  <Button.Checkbox
                    checked={!!(cit_toggles & CUM_ONTO)}
                    onClick={() => act('toggle_cit', {
                      flag: 'cumontopref',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Тряска (18+)">
                  <Button.Checkbox
                    checked={!!(cit_toggles & SEX_JITTER)}
                    onClick={() => act('toggle_cit', {
                      flag: 'sex_jitter',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Принуд. кормление">
                  <Button.Checkbox
                    checked={!!(cit_toggles & TRASH_FORCEFEED)}
                    onClick={() => act('toggle_cit', {
                      flag: 'toggleforcefeedtrash',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Авто-виляние">
                  <Button.Checkbox
                    checked={!(cit_toggles & NO_AUTO_WAG)}
                    content={cit_toggles & NO_AUTO_WAG ? 'Выкл.' : 'Вкл.'}
                    onClick={() => act('toggle_cit', {
                      flag: 'auto_wag',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Диско-танец">
                  <Button.Checkbox
                    checked={!(cit_toggles & NO_DISCO_DANCE)}
                    content={cit_toggles & NO_DISCO_DANCE ? 'Выкл.' : 'Вкл.'}
                    onClick={() => act('toggle_cit', {
                      flag: 'disco_dance',
                    })}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* Genital configuration + Fluid blacklist */}
      <Stack.Item>
        <Section title="Гениталии">
          <Stack>
            <Stack.Item grow>
              <Button
                fluid
                icon="cog"
                content="Настроить гениталии"
                onClick={() => act('open_genital_config')}
              />
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                icon="list"
                content="Чёрный список жидкостей"
                onClick={() => act('set_gfluid_blacklist')}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
