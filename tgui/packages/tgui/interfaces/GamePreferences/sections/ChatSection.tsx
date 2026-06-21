import { useBackend } from '../../../backend';
import { Stack } from '../../../components';
import { PrefRow } from '../components/PrefRow';

type ChatData = {
  chat_ooc: boolean;
  chat_looc: boolean;
  chat_ghostears: boolean;
  chat_ghostsight: boolean;
  chat_ghostwhisper: boolean;
  chat_ghostpda: boolean;
  chat_ghostradio: boolean;
  chat_dead: boolean;
  chat_prayer: boolean;
  chat_radio: boolean;
  chat_pullr: boolean;
  chat_bankcard: boolean;
  windowflashing: boolean;
  windownoise: boolean;
};

const CHAT_TOGGLES: { key: string; label: string; flag: string }[] = [
  { key: 'chat_ooc', label: 'OOC чат', flag: 'chat_ooc' },
  { key: 'chat_looc', label: 'LOOC чат', flag: 'chat_looc' },
  { key: 'chat_ghostears', label: 'Вся речь в режиме призрака', flag: 'chat_ghostears' },
  { key: 'chat_ghostsight', label: 'Все эмоуты в режиме призрака', flag: 'chat_ghostsight' },
  { key: 'chat_ghostwhisper', label: 'Шёпот в режиме призрака', flag: 'chat_ghostwhisper' },
  { key: 'chat_ghostpda', label: 'PDA в режиме призрака', flag: 'chat_ghostpda' },
  { key: 'chat_ghostradio', label: 'Радио в режиме призрака', flag: 'chat_ghostradio' },
  { key: 'chat_dead', label: 'Чат мёртвых (Deadchat)', flag: 'chat_dead' },
  { key: 'chat_prayer', label: 'Молитвы', flag: 'chat_prayer' },
  { key: 'chat_radio', label: 'Радио чат', flag: 'chat_radio' },
  { key: 'chat_pullr', label: 'Уведомления о пулл-реквестах', flag: 'chat_pullr' },
  { key: 'chat_bankcard', label: 'Уведомления о доходах', flag: 'chat_bankcard' },
  { key: 'windowflashing', label: 'Мигание окна при событиях', flag: 'windowflashing' },
  { key: 'windownoise', label: 'Звук окна при событиях', flag: 'windownoise' },
];

export const ChatSection = (props, context) => {
  const { act, data } = useBackend<ChatData>(context);

  return (
    <Stack vertical>
      {CHAT_TOGGLES.map(({ key, label, flag }) => (
        <PrefRow
          key={key}
          label={label}
          checked={data[key]}
          onClick={() => act('toggle_chat', { flag })}
        />
      ))}
    </Stack>
  );
};
