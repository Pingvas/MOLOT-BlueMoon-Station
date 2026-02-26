/**
 * Basically, hacks from goonchat which try to keep the map focused at all
 * times, except for when some meaningful action happens o
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { defer } from 'common/defer';
import { KEY_ALT, KEY_CTRL, KEY_SHIFT } from 'common/keycodes';
import { vecLength, vecSubtract } from 'common/vector';
import { canStealFocus, globalEvents } from 'tgui/events';
import { focusMap } from 'tgui/focus';

// Empyrically determined number for the smallest possible
// text you can select with the mouse.
const MIN_SELECTION_DISTANCE = 10;

const deferredFocusMap = () => defer(() => focusMap());

// Maps browser event.key values to BYOND key names for modifier keys.
const MODIFIER_TO_BYOND = {
  [KEY_ALT]: 'Alt',
  [KEY_CTRL]: 'Ctrl',
  [KEY_SHIFT]: 'Shift',
};

// Maps browser event.key values to BYOND key names for navigation keys.
const DIRECTION_TO_BYOND = {
  'ArrowLeft': 'West',
  'ArrowUp': 'North',
  'ArrowRight': 'East',
  'ArrowDown': 'South',
  'PageUp': 'Northeast',
  'PageDown': 'Southeast',
  'End': 'Southwest',
  'Home': 'Northwest',
};

/**
 * Converts a raw DOM KeyboardEvent to a BYOND key name.
 * Uses event.code for layout-independent letter/digit mapping.
 */
export const eventToByondKey = (e) => {
  const { code, key } = e;
  // Numpad digits
  if (/^Numpad\d$/.test(code)) return 'Numpad' + code.slice(6);
  // Direction/navigation keys
  if (DIRECTION_TO_BYOND[key]) return DIRECTION_TO_BYOND[key];
  // Letters (layout-independent via physical key code)
  if (/^Key[A-Z]$/.test(code)) return code.charAt(3);
  // Digits (layout-independent via physical key code)
  if (/^Digit\d$/.test(code)) return code.charAt(5);
  // F-keys
  if (/^F\d+$/.test(key)) return key;
  // Special keys
  if (key === 'Insert') return 'Insert';
  if (key === 'Delete') return 'Delete';
  if (code === 'Comma') return ',';
  if (code === 'Minus') return '-';
  if (code === 'Period') return '.';
  return null;
};

export const setupPanelFocusHacks = () => {
  let focusStolen = false;
  let clickStartPos = null;
  window.addEventListener('focusin', e => {
    focusStolen = canStealFocus(e.target);
  });
  window.addEventListener('mousedown', e => {
    clickStartPos = [e.screenX, e.screenY];
  });
  window.addEventListener('mouseup', e => {
    if (clickStartPos) {
      const clickEndPos = [e.screenX, e.screenY];
      const dist = vecLength(vecSubtract(clickEndPos, clickStartPos));
      if (dist >= MIN_SELECTION_DISTANCE) {
        focusStolen = true;
      }
    }
    if (!focusStolen) {
      deferredFocusMap();
    }
  });
  globalEvents.on('keydown', key => {
    if (key.isModifierKey()) {
      return;
    }
    deferredFocusMap();
  });

  // Fix for stuck modifier keys (Alt, Ctrl, Shift) after BYOND 516 migration.
  // When a modifier is pressed while the map has focus and released while the
  // WebView2 panel has focus, BYOND never receives the KeyUp event.
  // We track whether each modifier was pressed in the panel; if we see a KeyUp
  // without a preceding KeyDown, the key was pressed on the map side, and we
  // forward the KeyUp to BYOND.
  // Uses raw DOM listeners to bypass the canStealFocus filter in events.js,
  // which would block events when an input/textarea (e.g. chat) is focused.
  const modifierPressedInPanel = {};

  document.addEventListener('keydown', (e) => {
    const byondKey = MODIFIER_TO_BYOND[e.key];
    if (byondKey) {
      modifierPressedInPanel[byondKey] = true;
    }
  });

  document.addEventListener('keyup', (e) => {
    const byondKey = MODIFIER_TO_BYOND[e.key];
    if (byondKey) {
      if (!modifierPressedInPanel[byondKey]) {
        Byond.command(`KeyUp "${byondKey}"`);
      }
      modifierPressedInPanel[byondKey] = false;
    }
  });

  // Fix for stuck regular keys (WASD, arrows, etc.) after BYOND 516 migration.
  // Same principle as modifier keys above: track keys pressed in the panel,
  // and forward orphaned KeyUp events (released without preceding KeyDown in
  // the panel) to BYOND. This covers the scenario where a movement key is
  // held on the map, focus moves to the panel (e.g. player clicks chat),
  // and the key is released while the panel has focus.
  const regularKeyPressedInPanel = {};

  document.addEventListener('keydown', (e) => {
    const byondKey = eventToByondKey(e);
    if (byondKey) {
      regularKeyPressedInPanel[byondKey] = true;
    }
  });

  document.addEventListener('keyup', (e) => {
    const byondKey = eventToByondKey(e);
    if (byondKey) {
      if (!regularKeyPressedInPanel[byondKey]) {
        Byond.command(`KeyUp "${byondKey}"`);
      }
      regularKeyPressedInPanel[byondKey] = false;
    }
  });

  window.addEventListener('blur', () => {
    for (const key of Object.keys(modifierPressedInPanel)) {
      modifierPressedInPanel[key] = false;
    }
    for (const key of Object.keys(regularKeyPressedInPanel)) {
      regularKeyPressedInPanel[key] = false;
    }
  });

  // When the BYOND application is minimized / Alt-Tabbed and the player
  // releases keys while the app is in the background, neither BYOND macros
  // nor JS event listeners fire. Release all server-side keys when the
  // page becomes visible again.
  document.addEventListener('visibilitychange', () => {
    if (!document.hidden) {
      Byond.command('force_release_all_keys');
    }
  });
};
