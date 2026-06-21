import { useBackend } from '../../../backend';
import { Dropdown, NumberInput, Stack } from '../../../components';
import { PrefRow } from '../components/PrefRow';

type GameplayData = {
  no_antag: boolean;
  midround_antag: boolean;
  be_victim: string;
  disable_combat_cursor: boolean;
  disable_combat_mouse_lock: boolean;
  tg_player_panel: boolean;
  deathrattle: boolean;
  arrivalrattle: boolean;
  intent_style: boolean;
  screenshake: number;
  damage_screenshake: number;
  recoil_push: number;
  action_buttons_hide: boolean;
  announce_login: boolean;
  combohud_lighting: boolean;
};

const BE_VICTIM_OPTIONS = [
  { value: 'No', label: 'Нет' },
  { value: 'Ask', label: 'Спросить' },
  { value: 'Yes', label: 'Да' },
];

const DAMAGE_SHAKE_OPTIONS = [
  { value: 0, label: 'Отключено' },
  { value: 1, label: 'Всегда' },
  { value: 2, label: 'Только лёжа' },
];

const GAMEPLAY_TOGGLES: { key: string; label: string; flag: string; invert?: boolean }[] = [
  { key: 'no_antag', label: 'Разрешить роли антагонистов', flag: 'no_antag', invert: true },
  { key: 'midround_antag', label: 'Выдача антага в середине раунда', flag: 'midround_antag' },
  { key: 'deathrattle', label: 'Уведомления о смерти мобов', flag: 'deathrattle' },
  { key: 'arrivalrattle', label: 'Уведомления о прибытии игроков', flag: 'arrivalrattle' },
  { key: 'intent_style', label: 'Прямой выбор интента', flag: 'intent_style' },
  { key: 'action_buttons_hide', label: 'Скрыть кнопки действий при спавне', flag: 'action_buttons_hide' },
  { key: 'disable_combat_cursor', label: 'Отключить курсор боя', flag: 'disable_combat_cursor' },
  { key: 'disable_combat_mouse_lock', label: 'Отключить захват мыши в бою', flag: 'disable_combat_mouse_lock' },
  { key: 'tg_player_panel', label: 'Новый стиль панели игрока (TG)', flag: 'tg_player_panel' },
  { key: 'announce_login', label: 'Объявлять о входе админа', flag: 'announce_login' },
  { key: 'combohud_lighting', label: 'Combo HUD освещение', flag: 'combohud_lighting' },
];

export const GameplaySection = (props, context) => {
  const { act, data } = useBackend<GameplayData>(context);
  const damageShakeValue = Number(data.damage_screenshake ?? 2);

  return (
    <Stack vertical>
      {GAMEPLAY_TOGGLES.map(({ key, label, flag, invert }) => (
        <PrefRow
          key={key}
          label={label}
          checked={invert ? !data[key] : data[key]}
          onClick={() => act('toggle_gameplay', { flag })}
        />
      ))}
      <Stack.Item>
        <Stack align="center" fill className="GamePreferences__row">
          <Stack.Item grow basis={0}>
            <div className="GamePreferences__label">Стать жертвой антагониста</div>
          </Stack.Item>
          <Stack.Item>
            <Dropdown
              width="160px"
              options={BE_VICTIM_OPTIONS.map(o => o.label)}
              selected={BE_VICTIM_OPTIONS.find(o => o.value === data.be_victim)?.label || 'Нет'}
              onSelected={value => {
                const opt = BE_VICTIM_OPTIONS.find(o => o.label === value);
                if (opt) act('set_be_victim', { value: opt.value });
              }}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack align="center" fill className="GamePreferences__row">
          <Stack.Item grow basis={0}>
            <div className="GamePreferences__label">Тряска экрана</div>
            <div className="GamePreferences__hint">0 — выкл., 100 — максимум</div>
          </Stack.Item>
          <Stack.Item>
            <NumberInput
              width="80px"
              minValue={0}
              maxValue={100}
              step={5}
              value={Number(data.screenshake ?? 100)}
              onChange={(e, value) => act('set_screenshake', { flag: 'screenshake', value })}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack align="center" fill className="GamePreferences__row">
          <Stack.Item grow basis={0}>
            <div className="GamePreferences__label">Тряска при получении урона</div>
          </Stack.Item>
          <Stack.Item>
            <Dropdown
              width="160px"
              options={DAMAGE_SHAKE_OPTIONS.map(o => o.label)}
              selected={DAMAGE_SHAKE_OPTIONS.find(o => o.value === damageShakeValue)?.label || 'Только лёжа'}
              onSelected={value => {
                const opt = DAMAGE_SHAKE_OPTIONS.find(o => o.label === value);
                if (opt) act('set_screenshake', { flag: 'damage_screenshake', value: opt.value });
              }}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack align="center" fill className="GamePreferences__row">
          <Stack.Item grow basis={0}>
            <div className="GamePreferences__label">Отдача / толчок камеры</div>
            <div className="GamePreferences__hint">0 — выкл., 100 — максимум</div>
          </Stack.Item>
          <Stack.Item>
            <NumberInput
              width="80px"
              minValue={0}
              maxValue={100}
              step={5}
              value={Number(data.recoil_push ?? 100)}
              onChange={(e, value) => act('set_screenshake', { flag: 'recoil_push', value })}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
