# CharacterSetup TGUI — Полный план миграции
> Ветка: `modern_char_menu_upd` | Дата: 2026-04-08

---

## 0. Легенда статусов
| Маркер | Смысл |
|--------|-------|
| ✅ | Сделано |
| 🔄 | В процессе |
| ❌ | Не начато |
| ⚠️ | Нужна проверка |
| 🗑️ | Удалить |
| 🔴 | Критично |
| 🟡 | Важно |
| 🟢 | Малый приоритет |

---

## 1. Что уже сделано ✅

- [x] Перенесены 16 TGUI React файлов из ветки `character_menu` (UTF-8 без BOM)
- [x] Добавлен `modular_bluemoon/code/modules/client/character_setup_ui.dm` (основной TGUI datum)
- [x] Добавлен `modular_bluemoon/code/modules/client/antag_preview_icons.dm`
- [x] Добавлен `modular_bluemoon/code/modules/asset_cache/assets/loadout_items.dm`
- [x] `tgstation.dme` обновлён (+4 `#include`)
- [x] Заменены 3 точки вызова ShowChoices → `open_character_setup_tgui()`:
  - `escape_menu/home_page.dm`
  - `lobby/lobby_new_player.dm`
  - `client/preferences_toggles.dm`
- [x] Удалён `ShowChoices()` (2040 строк HTML-рендерера) из `preferences_ui.dm`
- [x] Удалены `build_preview_html()`, `update_preview_html_only()`, `cycle_character_creation_modern_accent()`
- [x] Все 45 вызовов `ShowChoices(user)` в `preferences_handlers.dm` → `SStgui.update_user_uis(user)`
- [x] Удалён `TG_PLAYER_PANEL` из `character_setup_ui.dm`
- [x] `hair_style_picker.dm` confirm: `ShowChoices` → `SStgui.update_user_uis`

---

## 2. Мёртвый код — удалить немедленно 🗑️

### 2.1 `preferences_jobs_quirks.dm`

**`SetChoices()`** (строка 1–142) — полный HTML-рендерер выбора работ (browser popup).
Полностью заменён `JobsTab.tsx`. **Удалить весь proc целиком.**

**`SetQuirks()`** (строка 197–270) — HTML-рендерер квирков (browser popup).  
Полностью заменён `QuirksTab.tsx`. **Удалить весь proc целиком.**

**`GetInlineQuirksMarkup()`** (строка 271–393) — HTML-рендерер инлайн-квирков для старого ShowChoices.
Нигде не вызывается в TGUI. **Удалить.**

> ⚠️ Перед удалением проверить через grep что нет вызовов в modular_ папках:
> ```powershell
> Select-String -Path ".\**\*.dm" -Pattern "SetChoices|SetQuirks|GetInlineQuirksMarkup" -Recurse
> ```

### 2.2 `preferences_handlers.dm`

**`skip_preview` / `skip_preview_update` параметр** — оптимизация для HTML, вся логика вокруг него:
- Переменная `var/skip_preview = FALSE` (строка 328)
- Все строки вида `preview_change_hint = PREVIEW_HINT_*` (20+ вхождений)

В TGUI нет нужды управлять "нужно ли перерисовывать HTML". `SStgui.update_user_uis()` вызывается один раз в конце `process_link()`. `preview_change_hint` влияет ТОЛЬКО на `update_preview_icon()` (регенерацию спрайта) — это нужно сохранить, но убрать весь код, связанный со `skip_preview_update`.

**Итого в конце `process_link()` должно быть:**
```dm
if(preview_change_hint)
    update_preview_icon()
SStgui.update_user_uis(user)
return TRUE
```

### 2.3 `preferences.dm` — переменные тем старого меню 🗑️

Следующие переменные использовались только для CSS-классов старого HTML-интерфейса.  
В TGUI тема задаётся через `<Layout theme="...">` на стороне React — эти vars больше не нужны:

```dm
var/charcreation_theme = "modern"           // → УДАЛИТЬ
var/modern_custom_bg_primary               // → УДАЛИТЬ
var/modern_custom_bg_secondary             // → УДАЛИТЬ
var/modern_custom_text_primary             // → УДАЛИТЬ
var/modern_custom_text_secondary           // → УДАЛИТЬ
var/modern_custom_button_bg                // → УДАЛИТЬ
var/modern_custom_button_hover             // → УДАЛИТЬ
var/modern_custom_button_active            // → УДАЛИТЬ
var/modern_custom_button_text              // → УДАЛИТЬ
var/modern_custom_border_color             // → УДАЛИТЬ
var/modern_custom_accent_color             // → УДАЛИТЬ
var/modern_custom_bg_pattern               // → УДАЛИТЬ
var/modern_custom_enabled                  // → УДАЛИТЬ
```

> ⚠️ Перед удалением проверить: нет ли этих vars в `save_preferences()`/`load_preferences()` — если есть, нужно убрать из savefile тоже (иначе старые сейвы сломаются с warning).

---

## 3. BlueMoon-фичи, отсутствующие в TGUI — нужно реализовать ❌

Это ключевой раздел. Всё перечисленное есть в DM-бэкенде `character_setup_ui.dm`, но **не отражено** в соответствующем `.tsx` файле или не передаётся через `ui_data()`.

### 3.1 🔴 КРИТИЧНО — ContentPrefsTab

#### Arousal / Moaning multipliers
**Переменные DM:**
```dm
var/use_arousal_multiplier = FALSE
var/arousal_multiplier = 100        // 0–300%
var/use_moaning_multiplier = FALSE
var/moaning_multiplier = 65         // 0–100%
```
**Что нужно:**
1. В `ui_data()` добавить: `use_arousal_multiplier`, `arousal_multiplier`, `use_moaning_multiplier`, `moaning_multiplier`
2. В `handle_ui_action()` добавить: `toggle_arousal_multiplier`, `set_arousal_multiplier`, `toggle_moaning_multiplier`, `set_moaning_multiplier`
3. В `types.ts` добавить поля в `CharacterSetupData`
4. В `ContentPrefsTab.tsx` добавить секцию "Тело / Реакции" с двумя NumberInput

#### Favorite Interactions
**Переменные DM:**
```dm
var/list/favorite_interactions = list()
```
**Что нужно:**
1. `ui_data()`: `favorite_interactions` (список), `available_interactions` (GLOB)
2. `handle_ui_action()`: `toggle_favorite_interaction`
3. UI: список чекбоксов или мультиселект в ContentPrefsTab

---

### 3.2 🟡 ВАЖНО — AppearanceTab

#### Color Presets / Тинты
**Переменная DM:**
```dm
var/list/color_presets_tint = list()   // presets per item type
```
Это функция сохранения цветовых пресетов для быстрого применения к нескольким вещам.  
**Что нужно:** Добавить в `AppearanceTab.tsx` или `LoadoutTab.tsx` секцию "Пресеты цветов" с кнопками сохранить/применить.

---

### 3.3 🟡 ВАЖНО — GamePrefsTab

**Antag: `toggle_combat_mouse_lock`** — в `handle_ui_action()` есть, в `GamePrefsTab.tsx` нужно проверить наличие.  
Проверить строку в `GamePrefsTab.tsx`:
```tsx
act('toggle_combat_mouse_lock')
```
Если отсутствует — добавить чекбокс "Блокировка мыши в бою".

---

### 3.4 🟡 ВАЖНО — Темы TGUI (замена старой CSS-системы)

Старый `charcreation_theme` (6 CSS-тем) **устарел**. В TGUI тема задаётся через компонент `Layout`.  
**Что нужно:**
1. Выбрать набор тем TGUI (default, ntos, solarized, etc.) или создать кастомную
2. В `ui_data()`: добавить `tgui_theme` (строка)
3. В `handle_ui_action()`: `set_tgui_theme`
4. В `index.tsx`: обернуть `<Window>` в выбранную тему по данным
5. Сохранять `tgui_theme` в savefile (заменяет `charcreation_theme`)

**Доступные темы TGUI** (из `tgui/packages/common/src/themes.ts`): `default`, `ntos`, `paper`, `retro`, `syndicate`  
Можно создать `bluemoon` тему — файл `tgui/packages/tgui-styles/styles/themes/bluemoon.scss`

---

### 3.5 🟢 Малый приоритет — SpeechTab  

#### Кастомный смех (Custom Laugh)
Проверить: `set_custom_laugh` и `preview_laugh` действия **уже есть** в `character_setup_ui.dm`. Убедиться что в `SpeechTab.tsx` они отображаются (строки с `act('set_custom_laugh')` и `act('preview_laugh')`). Если нет — добавить.

#### Кастомный язык (Custom Tongue)
Аналогично проверить `set_custom_tongue`.

---

## 4. Переводы — выявленные проблемы 🟡

В `character_setup_ui.dm` встречается **смешанный язык** (русский + английский) в диалоговых окнах `input()` и `to_chat()`. Нужно привести к единому русскому.

### 4.1 Смешанные строки в DM (input() диалоги)

| Строка (английская/смешанная) | Файл | Исправить на |
|-------------------------------|------|--------------|
| `"Silicon preference"` | `character_setup_ui.dm` ~1751 | `"Настройки силикона"` |
| `"Polychromic Color"` | `character_setup_ui.dm` ~2130 | `"Полихромный цвет"` |
| `"Loadout Color"` | `character_setup_ui.dm` ~2153 | `"Цвет снаряжения"` |
| `"Polychromic Color"` | заголовок диалога | `"Полихромный цвет"` |

### 4.2 Строки в TGUI (React)

Все строки в `.tsx` уже на русском ✅. Если добавляете новые компоненты — писать по-русски.

### 4.3 Typo в переменной DM
```dm
// В character_setup_ui.dm и types.ts
var/prefered_security_department   // ← опечатка (пропущена 'r')
// НЕЛЬЗЯ переименовывать — сломает savefile у игроков
// Оставить как есть, добавить комментарий
```

---

## 5. Ревью кода — что исправить 🔴🟡

### 5.1 🟡 `SStgui.update_user_uis(user)` — агрессивный вызов

**Файл:** `preferences_handlers.dm` — конец `process_link()`  
**Проблема:** `SStgui.update_user_uis(user)` обновляет **все** открытые у юзера TGUI-окна, не только CharacterSetup. Это избыточно.

**Исправление:** Использовать `SStgui.update_user_uis(user, /datum/character_setup_ui)` чтобы обновлять только наше окно:
```dm
SStgui.update_user_uis(user, /datum/character_setup_ui)
```
Проверить сигнатуру `SStgui.update_user_uis` — второй аргумент может быть datum type или экземпляр.

---

### 5.2 🟡 `process_link()` вызывается через href — потенциальный вектор атаки

**Файл:** `preferences_handlers.dm`  
**Проблема:** Старый HTML-механизм `?_src_=prefs;preference=X;task=Y` всё ещё работает и принимает входные данные из браузерных href. В TGUI это уже не нужно для основного меню, но handler может остаться активным.

**Проверить:** Есть ли `Topic()` вызов в `character_setup_ui.dm` или `preferences.dm` который маршрутизирует на `process_link()`? Если `process_link()` больше не нужен для портретов — ограничить его.

Портретная система (строки 3092+) использует `?_src_=prefs;preference=headshot_link` — это **нужно сохранить** (headshots задаются через input(), не через TGUI напрямую). Но все остальные маршруты в `process_link()` можно ограничить проверкой.

---

### 5.3 🟡 `set_languages` — заглушка

**Файл:** `character_setup_ui.dm`
**Проблема:** Экшн `set_languages` — no-op с комментарием "Legacy fallback". Занимает место и вводит в заблуждение.

```dm
// Удалить этот обработчик полностью или оставить для совместимости с импортом сейвов
if("set_languages")
    return TRUE  // legacy no-op
```

---

### 5.4 🟡 `preview_bark` — сложная асинхронная логика

**Файл:** `character_setup_ui.dm`  
**Проблема:** `preview_bark` использует `addtimer` с вычислениями задержек звука. При быстром кликании и закрытии меню таймер продолжает работать. Потенциальный memory/audio leak.

**Исправление:** Хранить reference на таймер и отменять при закрытии UI:
```dm
var/preview_bark_timer = null

// В preview_bark:
if(preview_bark_timer)
    deltimer(preview_bark_timer)
preview_bark_timer = addtimer(...)

// В ui_close():
if(preview_bark_timer)
    deltimer(preview_bark_timer)
    preview_bark_timer = null
```

---

### 5.5 🟡 Маппинг `bodypart_names` / `bodypart_values` — GLOB предположение

**Файл:** `character_setup_ui.dm`, логика конечностей  
**Проблема:** Используется `GLOB.bodypart_names[num2text()]` и `text2num(GLOB.bodypart_values[limb_name])` без проверки на null/существование ключа. При добавлении новых частей тела или несоответствии — тихий баг или runtime error.

**Исправление:** Добавить guard checks:
```dm
var/zone_id = GLOB.bodypart_values[limb_name]
if(!zone_id)
    return
```

---

### 5.6 🟢 Typo в данных: `"prefered_security_department"`

**Файл:** `character_setup_ui.dm`, `types.ts`  
Опечатка в имени поля (`prefered` вместо `preferred`). **Не трогать** — сломает savefile игроков. Только добавить комментарий:
```dm
var/prefered_security_department // typo kept intentionally: changing breaks savefiles
```

---

## 6. Оптимизации, которые нужно УБРАТЬ ❌

Следующие механизмы были специфичны для дорогого HTML-рендеринга. В TGUI они избыточны или вредны:

### 6.1 `skip_preview_update` параметр везде

Весь код `skip_preview_update = TRUE/FALSE` в `process_link()` — смысл был "не перегружать HTML пересчётом превью при каждом клике". В TGUI `ui_data()` уже разделяет статичные данные (`ui_static_data`) и динамические. Превью и так обновляется когда нужно.

**Убрать:**
- Параметр `skip_preview_update` из сигнатуры `process_link()`
- Все присвоения `skip_preview_update` внутри handlers

**Оставить:** `preview_change_hint` — он нужен для решения "нужно ли регенерировать спрайт".

### 6.2 Комментарий про "дорой ShowChoices" в `hair_style_picker.dm`

```dm
// ShowChoices() не вызывается при каждом клике — слишком дорого (2500+ строк логики).
```

Комментарий устарел, вводит в заблуждение. Убрать.

### 6.3 QuirkCategory server-side state (`var/quirk_category`)

В старом меню сервер хранил какая категория квирков открыта (`QUIRK_POSITIVE/NEUTRAL/NEGATIVE`). В TGUI эта вкладка управляется на стороне React — переменная `quirk_category` в DM больше не нужна как стейт.

Проверить: используется ли `quirk_category` ещё где-то, кроме удалённого `GetInlineQuirksMarkup`. Если нет — удалить.

---

## 7. Оптимизации, которые нужно СОХРАНИТЬ ✅

### 7.1 Pooled Dummy — `DUMMY_HUMAN_SLOT_PREFERENCES`

`generate_or_wait_for_human_dummy()` / `unset_busy_human_dummy()` — важная оптимизация. Генерация превью без пула значительно дороже. **Сохранить как есть.**

### 7.2 `tainted_slots` cache

Кэш имён слотов персонажей — нужен для быстрого отображения в сайдбаре без чтения всех savefile. **Сохранить.**

### 7.3 `preview_change_hint` — умное обновление спрайта

Разделение на `PREVIEW_HINT_HAIR` / `PREVIEW_HINT_BODY` / `PREVIEW_HINT_MUTANT_BODYPARTS` позволяет делать инкрементальное обновление спрайта. В TGUI это по-прежнему ценно — рендер превью тяжёлый. **Сохранить.**

### 7.4 `ui_static_data()` разделение

Большие статические списки (списки причёсок, underwear, etc.) передаются один раз при открытии, не при каждом обновлении. **Это правильно, не трогать.**

---

## 8. Порядок задач — по приоритету

### Фаза 1: Сборка чистая 🔴 (делать прямо сейчас)

| # | Задача | Файл | Размер |
|---|--------|------|--------|
| 1 | Исправить ошибки текущей сборки | — | — |
| 2 | Удалить `SetChoices()` из `preferences_jobs_quirks.dm` | `preferences_jobs_quirks.dm` | 142 стр. |
| 3 | Удалить `SetQuirks()` из `preferences_jobs_quirks.dm` | `preferences_jobs_quirks.dm` | 73 стр. |
| 4 | Удалить `GetInlineQuirksMarkup()` | `preferences_jobs_quirks.dm` | 122 стр. |
| 5 | Убрать параметр `skip_preview_update` из конца `process_link` | `preferences_handlers.dm` | уже сделано |
| 6 | Исправить `SStgui.update_user_uis` → `SStgui.update_user_uis(user, /datum/character_setup_ui)` | `preferences_handlers.dm` | — |

### Фаза 2: Переменные и мёртвый код 🟡

| # | Задача | Файл |
|---|--------|------|
| 7 | Найти и удалить `charcreation_theme` и `modern_custom_*` vars | `preferences.dm` + savefile |
| 8 | Убрать `quirk_category` var если нигде не используется | `preferences.dm` |
| 9 | Убрать `skip_preview_update` параметр из сигнатур | handlers |
| 10 | Убрать устаревший комментарий в `hair_style_picker.dm` | hair_style_picker |

### Фаза 3: Новые фичи в TGUI 🟡

| # | Задача | Файлы |
|---|--------|-------|
| 11 | Добавить arousal/moaning multipliers в ui_data + ContentPrefsTab | character_setup_ui.dm, ContentPrefsTab.tsx, types.ts |
| 12 | Добавить favorite_interactions в ContentPrefsTab | то же |
| 13 | Тема TGUI — добавить `tgui_theme` var + picker в index.tsx | preferences.dm, character_setup_ui.dm, index.tsx |
| 14 | Проверить + добавить `set_custom_laugh`/`preview_laugh` в SpeechTab | SpeechTab.tsx |
| 15 | Проверить `toggle_combat_mouse_lock` в GamePrefsTab | GamePrefsTab.tsx |

### Фаза 4: Безопасность и стабильность 🟡

| # | Задача | Файл |
|---|--------|------|
| 16 | Ограничить `ui_state()` — нельзя открывать живым во время раунда | character_setup_ui.dm |
| 17 | Исправить `preview_bark` timer leak | character_setup_ui.dm |
| 18 | Добавить null-guard в bodypart_names/bodypart_values | character_setup_ui.dm |
| 19 | Перевести смешанные строки: "Silicon preference" и пр. | character_setup_ui.dm |

### Фаза 5: Полировка 🟢

| # | Задача |
|---|--------|
| 20 | Добавить color_presets_tint систему в AppearanceTab/LoadoutTab |
| 21 | Custom TGUI тема `bluemoon.scss` |
| 22 | Убрать `set_languages` legacy no-op stub |
| 23 | Добавить `// typo kept intentionally` к `prefered_security_department` |

---

## 9. Структура TGUI файлов (справочник)

```
tgui/packages/tgui/interfaces/CharacterSetup/
├── index.tsx              — Главный компонент, 3 основных таба + слоты
├── types.ts               — Все TypeScript типы (CharacterSetupData и др.)
├── components/
│   ├── CharacterPreview.tsx   — ByondUi map_view (превью персонажа)
│   └── CharacterSlots.tsx     — Слоты персонажей (сайдбар)
└── tabs/
    ├── GeneralTab.tsx         — Имя, внешность, PDA, силикон
    ├── AppearanceTab.tsx      — Тело, цвета, волосы, одежда, конечности
    ├── BackgroundTab.tsx      — Описание, портреты, рекорды, смерть
    ├── MarkingsTab.tsx        — Маркинги / тату
    ├── SpeechTab.tsx          — Глагол речи, голос, языки
    ├── LoadoutTab.tsx         — Снаряжение
    ├── QuirksTab.tsx          — Особенности (только если roundstart_traits)
    ├── JobsTab.tsx            — Профессии
    ├── GamePrefsTab.tsx       — Игровые настройки, антаги
    ├── OOCPrefsTab.tsx        — OOC настройки, призрак
    ├── ContentPrefsTab.tsx    — Контент-преференции (ERP/Adult)
    └── KeybindingsTab.tsx     — Клавиши
```

---

## 10. Связанные файлы DM (справочник)

| Файл | Назначение | Статус |
|------|-----------|--------|
| `modular_bluemoon/code/modules/client/character_setup_ui.dm` | TGUI datum, ui_data, handle_ui_action, preview | ✅ Основной |
| `code/modules/client/preferences_handlers.dm` | Обработчик href/process_link + headshots (3093+) | 🔄 Чистится |
| `code/modules/client/preferences_ui.dm` | CaptureKeybinding, SetLanguage, toggle_language, check_language_maxhit | ✅ Очищен |
| `code/modules/client/preferences_jobs_quirks.dm` | SetChoices/SetQuirks/GetInlineQuirksMarkup — УДАЛИТЬ | 🗑️ Мёртвый |
| `code/modules/client/preferences.dm` | Все vars preferences datum | ⚠️ Проверить |
| `code/modules/client/preferences_toggles.dm` | Верб-тогглы | ✅ OK |
| `code/modules/client/hair_style_picker.dm` | TGUI HairStylePicker, confirm → update_user_uis | ✅ OK |
| `modular_bluemoon/code/modules/client/antag_preview_icons.dm` | preview_outfit для антагов | ✅ OK |
| `modular_bluemoon/code/modules/asset_cache/assets/loadout_items.dm` | Спрайтшит иконок лоадаута | ✅ OK |

---

## 11. Контрольный чеклист перед мержем

- [ ] `tools\build\build.bat -DLOWMEMORYMODE -DABSOLUTE_MINIMUM_MODE` — EXIT CODE 0
- [ ] `tgui build` — без ошибок TypeScript
- [ ] Открыть меню в лобби — все вкладки загружаются
- [ ] Превью персонажа отображается в ByondUi map_view
- [ ] Смена слота персонажа работает
- [ ] Сохранение/загрузка — прокверить что savefile не сломался
- [ ] Все портреты (headshots) задаются и отображаются
- [ ] Квирки — баланс считается правильно (включая body_weight)
- [ ] Работы — приоритеты сохраняются
- [ ] Лоадаут — слоты 1-5 работают
- [ ] ContentPrefs — ERP-настройки сохраняются
- [ ] Меню недоступно живым игрокам во время раунда (после фазы 4)
