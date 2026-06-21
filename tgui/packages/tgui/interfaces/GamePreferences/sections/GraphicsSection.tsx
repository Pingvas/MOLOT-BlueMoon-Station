import { useBackend } from '../../../backend';
import { Dropdown, Stack } from '../../../components';
import { PrefRow } from '../components/PrefRow';

type GraphicsData = {
  parallax: number;
  ambient_occlusion: boolean;
  widescreen: boolean;
  fullscreen: boolean;
  fit_viewport: boolean;
  outline_enabled: boolean;
  screentip_pref: boolean;
  screentip_images: boolean;
  tgui_fancy: boolean;
  tgui_lock: boolean;
  chat_on_map: boolean;
  chat_on_map_looc: boolean;
  see_chat_non_mob: boolean;
  see_rc_emotes: boolean;
  hud_button_flashes: boolean;
};

const PARALLAX_OPTIONS = [
  { value: 0, label: 'Выкл.' },
  { value: 1, label: 'Низкий' },
  { value: 2, label: 'Средний' },
  { value: 3, label: 'Высокий' },
  { value: 4, label: 'Безумный' },
];

const GFX_TOGGLES: { key: string; label: string; flag: string }[] = [
  { key: 'ambient_occlusion', label: 'Объёмное затенение (AO)', flag: 'ambient_occlusion' },
  { key: 'widescreen', label: 'Широкоэкранный режим', flag: 'widescreen' },
  { key: 'fullscreen', label: 'Полноэкранный режим', flag: 'fullscreen' },
  { key: 'fit_viewport', label: 'Подгонка экрана', flag: 'fit_viewport' },
  { key: 'outline_enabled', label: 'Контур вокруг объектов', flag: 'outline_enabled' },
  { key: 'screentip_pref', label: 'Подсказки на экране', flag: 'screentip_pref' },
  { key: 'screentip_images', label: 'Подсказки с изображениями', flag: 'screentip_images' },
  { key: 'tgui_fancy', label: 'Украшенный стиль TGUI', flag: 'tgui_fancy' },
  { key: 'tgui_lock', label: 'Блокировка окон TGUI', flag: 'tgui_lock' },
  { key: 'hud_button_flashes', label: 'Мигание кнопок HUD', flag: 'hud_button_flashes' },
  { key: 'chat_on_map', label: 'Руначат', flag: 'chat_on_map' },
  { key: 'chat_on_map_looc', label: 'Руначат для LOOC', flag: 'chat_on_map_looc' },
  { key: 'see_chat_non_mob', label: 'Руначат для не-мобов', flag: 'see_chat_non_mob' },
  { key: 'see_rc_emotes', label: 'Руначат для эмоутов', flag: 'see_rc_emotes' },
];

export const GraphicsSection = (props, context) => {
  const { act, data } = useBackend<GraphicsData>(context);
  const parallaxValue = Number(data.parallax ?? 4);
  const selectedParallax = PARALLAX_OPTIONS.find(o => o.value === parallaxValue)?.label
    || PARALLAX_OPTIONS[4].label;

  return (
    <Stack vertical>
      <Stack.Item>
        <Stack align="center" fill className="GamePreferences__row">
          <Stack.Item grow basis={0}>
            <div className="GamePreferences__label">Параллакс</div>
          </Stack.Item>
          <Stack.Item>
            <Dropdown
              width="160px"
              options={PARALLAX_OPTIONS.map(o => o.label)}
              selected={selectedParallax}
              onSelected={value => {
                const opt = PARALLAX_OPTIONS.find(o => o.label === value);
                if (opt) act('set_parallax', { value: opt.value });
              }}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      {GFX_TOGGLES.map(({ key, label, flag }) => (
        <PrefRow
          key={key}
          label={label}
          checked={data[key]}
          onClick={() => act('toggle_gfx', { flag })}
        />
      ))}
    </Stack>
  );
};
