import { debounce } from 'common/timer';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, Section, Stack } from '../components';
import { PixelArtImage } from '../components';
import { Window } from '../layouts';

const PAGE_SIZE = 24;
const ICON_SIZE = 64; // px – displayed size (32px native scaled 2x via CSS)
const COLS = 6; // icons per row

// Module-level debounced navigate to avoid re-creating on every render.
// Stores the latest act() reference and calls it after 300ms of inactivity.
let _debouncedNavigateAct: ((action: string, payload: object) => void) | null = null;
const debouncedNavigate = debounce((page: number, search: string) => {
  _debouncedNavigateAct?.('navigate', { page, search });
}, 300);

interface HairStylePickerData {
  pick_type: 'hair' | 'facial_hair' | 'gradient';
  current_style: string;
  filtered_names: string[];
  loaded_icons: Record<string, string | null>;
  preview_icon64: string | null;
}

const getWindowTitle = (pick_type: string) => {
  if (pick_type === 'facial_hair') return 'Выбор Стиля Бороды';
  if (pick_type === 'gradient') return 'Выбор Цветового Перехода';
  return 'Выбор Причёски';
};

export const HairStylePicker = (props, context) => {
  const { act, data } = useBackend<HairStylePickerData>(context);
  const {
    pick_type,
    current_style,
    filtered_names,
    loaded_icons,
    preview_icon64,
  } = data;

  // Local search text – updated on every keystroke; sent to server on navigate
  const [localSearch, setLocalSearch] = useLocalState(context, 'localSearch', '');

  // Current page managed locally; server page may lag slightly until act completes
  const [localPage, setLocalPage] = useLocalState(context, 'localPage', 0);

  // Which items are on the current page (derived from server-provided filtered list)
  const pageStart = localPage * PAGE_SIZE;
  const pageItems: string[] = (filtered_names || []).slice(pageStart, pageStart + PAGE_SIZE);
  const effectiveTotalPages = Math.max(
    1,
    Math.ceil((filtered_names || []).length / PAGE_SIZE),
  );

  // Keep module-level debounce in sync with current act() reference
  _debouncedNavigateAct = act;

  const navigate = (page: number, search: string) => {
    const clampedPage = Math.max(0, Math.min(page, effectiveTotalPages - 1));
    setLocalPage(clampedPage);
    act('navigate', { page: clampedPage, search });
  };

  const onSearchChange = (_, value: string) => {
    setLocalSearch(value);
    setLocalPage(0);
    // Debounce server call — local state updates instantly for responsive UI
    debouncedNavigate(0, value);
  };

  const onSelect = (style: string) => {
    act('preview', { style });
  };

  return (
    <Window
      title={getWindowTitle(pick_type)}
      width={950}
      height={580}>
      <Window.Content>
        {/* Горизонтальный сплит: сетка слева, превью справа */}
        <Stack fill>

          {/* Левая колонка: поиск + сетка иконок */}
          <Stack.Item grow>
            <Stack vertical fill>

              {/* Строка поиска и навигации */}
              <Stack.Item>
                <Section>
                  <Stack align="center">
                    <Stack.Item grow>
                      <Input
                        fluid
                        autoFocus
                        placeholder="Поиск по названию..."
                        value={localSearch}
                        onInput={onSearchChange}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Box ml={1} color="label" fontSize="0.85em">
                        {(filtered_names || []).length} вариантов
                      </Box>
                    </Stack.Item>
                    <Stack.Item ml={2}>
                      <Button
                        icon="chevron-left"
                        disabled={localPage <= 0}
                        onClick={() => navigate(localPage - 1, localSearch)}
                      />
                      <Box
                        inline
                        mr={1}
                        ml={1}
                        style={{ "white-space": "nowrap", "font-size": "0.9em" }}>
                        {localPage + 1} / {effectiveTotalPages}
                      </Box>
                      <Button
                        icon="chevron-right"
                        disabled={localPage >= effectiveTotalPages - 1}
                        onClick={() => navigate(localPage + 1, localSearch)}
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>

              {/* Сетка иконок */}
              <Stack.Item grow>
                <Section fill scrollable>
                  <Box
                    style={{
                      display: "grid",
                      "grid-template-columns": `repeat(${COLS}, 1fr)`,
                      gap: "6px",
                      padding: "2px",
                    }}>
                    {pageItems.map(style_name => {
                      const isSelected = style_name === current_style;
                      const iconBase64 = (loaded_icons || {})[style_name];
                      const iconSrc = iconBase64
                        ? `data:image/png;base64,${iconBase64}`
                        : null;

                      return (
                        <Box
                          key={style_name}
                          onClick={() => onSelect(style_name)}
                          style={{
                            display: "flex",
                            "flex-direction": "column",
                            "align-items": "center",
                            "justify-content": "flex-start",
                            padding: "4px",
                            cursor: "pointer",
                            border: isSelected
                              ? "2px solid #4fc3f7"
                              : "2px solid transparent",
                            "border-radius": "4px",
                            background: isSelected
                              ? "rgba(79,195,247,0.12)"
                              : "transparent",
                            transition: "border 0.1s,background 0.1s",
                          }}>
                          {iconSrc ? (
                            <img
                              src={iconSrc}
                              style={{
                                width: `${ICON_SIZE}px`,
                                height: `${ICON_SIZE}px`,
                                "image-rendering": "pixelated",
                                display: "block",
                              }}
                            />
                          ) : (
                            <Box
                              style={{
                                width: `${ICON_SIZE}px`,
                                height: `${ICON_SIZE}px`,
                                display: "flex",
                                "align-items": "center",
                                "justify-content": "center",
                                background: "rgba(255,255,255,0.05)",
                                "border-radius": "2px",
                                "font-size": "1.6em",
                                color: "rgba(255,255,255,0.4)",
                              }}>
                              —
                            </Box>
                          )}
                          <Box
                            style={{
                              "font-size": "0.72em",
                              "text-align": "center",
                              "margin-top": "3px",
                              "max-width": `${ICON_SIZE + 8}px`,
                              overflow: "hidden",
                              "text-overflow": "ellipsis",
                              "white-space": "nowrap",
                              color: isSelected ? "#4fc3f7" : "inherit",
                              "font-weight": isSelected ? "bold" : "normal",
                            }}>
                            {style_name}
                          </Box>
                        </Box>
                      );
                    })}

                    {/* Заполнение последней строки */}
                    {Array.from({
                      length:
                        pageItems.length < PAGE_SIZE
                          ? PAGE_SIZE - pageItems.length
                          : 0,
                    }).map((_, i) => (
                      <Box key={`pad_${i}`} style={{ visibility: "hidden" }} />
                    ))}
                  </Box>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          {/* Правая колонка: превью персонажа + подтверждение */}
          <Stack.Item width="200px" shrink={0}>
            <Stack vertical fill>

              {/* Превью персонажа */}
              <Stack.Item grow>
                <Section
                  fill
                  title="Превью"
                  textAlign="center">
                  {preview_icon64 ? (
                    <Box
                      style={{
                        display: "flex",
                        "align-items": "center",
                        "justify-content": "center",
                        height: "100%",
                        "min-height": "140px",
                      }}>
                      <PixelArtImage
                        src={preview_icon64}
                        style={{
                          width: "128px",
                          height: "128px",
                        }}
                      />
                    </Box>
                  ) : (
                    <Box
                      style={{
                        display: "flex",
                        "align-items": "center",
                        "justify-content": "center",
                        height: "140px",
                        color: "rgba(255,255,255,0.3)",
                        "font-size": "0.85em",
                      }}>
                      Загрузка...
                    </Box>
                  )}
                </Section>
              </Stack.Item>

              {/* Текущий выбор + кнопка */}
              <Stack.Item>
                <Section>
                  <Box color="label" fontSize="0.8em" mb={1}>
                    Выбрано:
                  </Box>
                  <Box
                    bold
                    style={{
                      overflow: "hidden",
                      "text-overflow": "ellipsis",
                      "white-space": "nowrap",
                      "font-size": "0.85em",
                      "margin-bottom": "8px",
                    }}>
                    {current_style || '—'}
                  </Box>
                  <Button
                    fluid
                    color="good"
                    onClick={() => act('confirm')}>
                    Подтвердить выбор
                  </Button>
                </Section>
              </Stack.Item>

            </Stack>
          </Stack.Item>

        </Stack>
      </Window.Content>
    </Window>
  );
};
