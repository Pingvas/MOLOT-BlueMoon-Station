/**
 * Tests for panelFocus — orphaned keyup detection and key mapping.
 *
 * @file
 */

// Mock external dependencies before any imports.
// Use plain functions (not jest.fn) so resetMocks:true won't wipe them.
jest.mock('common/defer', () => ({
  __esModule: true,
  defer: (fn) => fn,
}));

jest.mock('common/keycodes', () => ({
  __esModule: true,
  KEY_ALT: 'Alt',
  KEY_CTRL: 'Control',
  KEY_SHIFT: 'Shift',
}));

jest.mock('common/vector', () => ({
  __esModule: true,
  vecLength: () => 0,
  vecSubtract: () => [0, 0],
}));

jest.mock('tgui/events', () => ({
  __esModule: true,
  canStealFocus: () => false,
  globalEvents: { on: () => {}, emit: () => {} },
}));

jest.mock('tgui/focus', () => ({
  __esModule: true,
  focusMap: () => {},
}));

import { eventToByondKey, setupPanelFocusHacks } from './panelFocus';

// ───────────────────────────────────────────────────────
// eventToByondKey — pure function, no mocks needed
// ───────────────────────────────────────────────────────

describe('eventToByondKey', () => {
  /** Helper: create a minimal KeyboardEvent-like object. */
  const ev = (code, key) => ({ code, key });

  describe('буквы (layout-independent через event.code)', () => {
    test('KeyW → W', () => {
      expect(eventToByondKey(ev('KeyW', 'w'))).toBe('W');
    });

    test('KeyA → A', () => {
      expect(eventToByondKey(ev('KeyA', 'a'))).toBe('A');
    });

    test('KeyS → S', () => {
      expect(eventToByondKey(ev('KeyS', 's'))).toBe('S');
    });

    test('KeyD → D', () => {
      expect(eventToByondKey(ev('KeyD', 'd'))).toBe('D');
    });

    test('KeyZ → Z (крайняя буква)', () => {
      expect(eventToByondKey(ev('KeyZ', 'z'))).toBe('Z');
    });

    test('русская раскладка: KeyW + ц → W', () => {
      expect(eventToByondKey(ev('KeyW', 'ц'))).toBe('W');
    });

    test('русская раскладка: KeyA + ф → A', () => {
      expect(eventToByondKey(ev('KeyA', 'ф'))).toBe('A');
    });
  });

  describe('цифры (layout-independent через event.code)', () => {
    test('Digit1 → 1', () => {
      expect(eventToByondKey(ev('Digit1', '1'))).toBe('1');
    });

    test('Digit0 → 0', () => {
      expect(eventToByondKey(ev('Digit0', '0'))).toBe('0');
    });

    test('Digit9 → 9', () => {
      expect(eventToByondKey(ev('Digit9', '9'))).toBe('9');
    });
  });

  describe('стрелки и навигация', () => {
    test('ArrowUp → North', () => {
      expect(eventToByondKey(ev('ArrowUp', 'ArrowUp'))).toBe('North');
    });

    test('ArrowDown → South', () => {
      expect(eventToByondKey(ev('ArrowDown', 'ArrowDown'))).toBe('South');
    });

    test('ArrowLeft → West', () => {
      expect(eventToByondKey(ev('ArrowLeft', 'ArrowLeft'))).toBe('West');
    });

    test('ArrowRight → East', () => {
      expect(eventToByondKey(ev('ArrowRight', 'ArrowRight'))).toBe('East');
    });

    test('PageUp → Northeast', () => {
      expect(eventToByondKey(ev('PageUp', 'PageUp'))).toBe('Northeast');
    });

    test('PageDown → Southeast', () => {
      expect(eventToByondKey(ev('PageDown', 'PageDown'))).toBe('Southeast');
    });

    test('End → Southwest', () => {
      expect(eventToByondKey(ev('End', 'End'))).toBe('Southwest');
    });

    test('Home → Northwest', () => {
      expect(eventToByondKey(ev('Home', 'Home'))).toBe('Northwest');
    });
  });

  describe('F-клавиши', () => {
    test('F1 → F1', () => {
      expect(eventToByondKey(ev('F1', 'F1'))).toBe('F1');
    });

    test('F5 → F5', () => {
      expect(eventToByondKey(ev('F5', 'F5'))).toBe('F5');
    });

    test('F12 → F12', () => {
      expect(eventToByondKey(ev('F12', 'F12'))).toBe('F12');
    });
  });

  describe('Numpad', () => {
    test('Numpad0 → Numpad0', () => {
      expect(eventToByondKey(ev('Numpad0', '0'))).toBe('Numpad0');
    });

    test('Numpad5 → Numpad5', () => {
      expect(eventToByondKey(ev('Numpad5', '5'))).toBe('Numpad5');
    });

    test('Numpad9 → Numpad9', () => {
      expect(eventToByondKey(ev('Numpad9', '9'))).toBe('Numpad9');
    });
  });

  describe('специальные клавиши', () => {
    test('Insert → Insert', () => {
      expect(eventToByondKey(ev('Insert', 'Insert'))).toBe('Insert');
    });

    test('Delete → Delete', () => {
      expect(eventToByondKey(ev('Delete', 'Delete'))).toBe('Delete');
    });

    test('Comma → ,', () => {
      expect(eventToByondKey(ev('Comma', ','))).toBe(',');
    });

    test('Minus → -', () => {
      expect(eventToByondKey(ev('Minus', '-'))).toBe('-');
    });

    test('Period → .', () => {
      expect(eventToByondKey(ev('Period', '.'))).toBe('.');
    });
  });

  describe('неизвестные клавиши → null', () => {
    test('модификатор Shift → null', () => {
      expect(eventToByondKey(ev('ShiftLeft', 'Shift'))).toBeNull();
    });

    test('модификатор Control → null', () => {
      expect(eventToByondKey(ev('ControlLeft', 'Control'))).toBeNull();
    });

    test('модификатор Alt → null', () => {
      expect(eventToByondKey(ev('AltLeft', 'Alt'))).toBeNull();
    });

    test('Enter → null', () => {
      expect(eventToByondKey(ev('Enter', 'Enter'))).toBeNull();
    });

    test('Backspace → null', () => {
      expect(eventToByondKey(ev('Backspace', 'Backspace'))).toBeNull();
    });

    test('Space → null', () => {
      expect(eventToByondKey(ev('Space', ' '))).toBeNull();
    });
  });
});

// ───────────────────────────────────────────────────────
// setupPanelFocusHacks — DOM event integration
// ───────────────────────────────────────────────────────

describe('setupPanelFocusHacks', () => {
  // Set up the global Byond mock and register handlers once.
  beforeAll(() => {
    window.Byond = { command: jest.fn() };
    setupPanelFocusHacks();
  });

  // Give each test a fresh mock for Byond.command.
  beforeEach(() => {
    window.Byond.command = jest.fn();
  });

  /** Dispatch a real DOM keyboard event. */
  const press = (code, key) => {
    document.dispatchEvent(
      new KeyboardEvent('keydown', { code, key, bubbles: true }),
    );
  };

  const release = (code, key) => {
    document.dispatchEvent(
      new KeyboardEvent('keyup', { code, key, bubbles: true }),
    );
  };

  // ── Regular-key orphaned keyup ───────────────────────

  describe('orphaned keyup для обычных клавиш', () => {
    test('keyup без keydown пробрасывает KeyUp в BYOND (клавиша с карты)', () => {
      // A was pressed on the map, released in panel — no preceding keydown.
      release('KeyA', 'a');
      expect(window.Byond.command).toHaveBeenCalledWith('KeyUp "A"');
    });

    test('keyup после keydown в панели НЕ пробрасывает лишний KeyUp', () => {
      press('KeyA', 'a');
      release('KeyA', 'a');
      // Should NOT forward since the key was pressed in the panel.
      expect(window.Byond.command).not.toHaveBeenCalledWith('KeyUp "A"');
    });

    test('стрелки: orphaned keyup пробрасывает KeyUp "North"', () => {
      release('ArrowUp', 'ArrowUp');
      expect(window.Byond.command).toHaveBeenCalledWith('KeyUp "North"');
    });

    test('стрелки: orphaned keyup пробрасывает KeyUp "West"', () => {
      release('ArrowLeft', 'ArrowLeft');
      expect(window.Byond.command).toHaveBeenCalledWith('KeyUp "West"');
    });

    test('цифра: orphaned keyup пробрасывает KeyUp "1"', () => {
      release('Digit1', '1');
      expect(window.Byond.command).toHaveBeenCalledWith('KeyUp "1"');
    });

    test('неизвестная клавиша не пробрасывается', () => {
      release('Space', ' ');
      // eventToByondKey returns null for Space — nothing forwarded.
      const calls = window.Byond.command.mock.calls.map((c) => c[0]);
      const keyUpCalls = calls.filter((c) => c.startsWith('KeyUp'));
      expect(keyUpCalls).toEqual([]);
    });
  });

  // ── Modifier-key orphaned keyup ──────────────────────

  describe('orphaned keyup для модификаторов', () => {
    test('Shift released без keydown → KeyUp "Shift"', () => {
      release('ShiftLeft', 'Shift');
      expect(window.Byond.command).toHaveBeenCalledWith('KeyUp "Shift"');
    });

    test('Ctrl released без keydown → KeyUp "Ctrl"', () => {
      release('ControlLeft', 'Control');
      expect(window.Byond.command).toHaveBeenCalledWith('KeyUp "Ctrl"');
    });

    test('Alt released без keydown → KeyUp "Alt"', () => {
      release('AltLeft', 'Alt');
      expect(window.Byond.command).toHaveBeenCalledWith('KeyUp "Alt"');
    });

    test('Shift pressed+released в панели НЕ пробрасывает лишний KeyUp', () => {
      press('ShiftLeft', 'Shift');
      release('ShiftLeft', 'Shift');
      expect(window.Byond.command).not.toHaveBeenCalledWith('KeyUp "Shift"');
    });
  });

  // ── Window blur clears tracking state ────────────────

  describe('window blur сбрасывает tracking', () => {
    test('после blur orphaned keyup снова пробрасывается', () => {
      // Press in panel, then blur (simulates panel→map focus switch)
      press('KeyW', 'w');
      window.dispatchEvent(new Event('blur'));

      // Now release — tracking was cleared by blur, so it looks orphaned.
      release('KeyW', 'w');
      expect(window.Byond.command).toHaveBeenCalledWith('KeyUp "W"');
    });
  });

  // ── visibilitychange ─────────────────────────────────

  describe('visibilitychange при возврате видимости', () => {
    test('отправляет force_release_all_keys когда страница становится видимой', () => {
      // Mock document.hidden = false (page becoming visible).
      Object.defineProperty(document, 'hidden', {
        configurable: true,
        get: () => false,
      });

      document.dispatchEvent(new Event('visibilitychange'));
      expect(window.Byond.command).toHaveBeenCalledWith(
        'force_release_all_keys',
      );
    });

    test('НЕ отправляет при скрытии страницы', () => {
      Object.defineProperty(document, 'hidden', {
        configurable: true,
        get: () => true,
      });

      document.dispatchEvent(new Event('visibilitychange'));
      expect(window.Byond.command).not.toHaveBeenCalledWith(
        'force_release_all_keys',
      );
    });
  });

  // ── Множественные клавиши ────────────────────────────

  describe('множественные клавиши одновременно', () => {
    test('две orphaned клавиши обе пробрасываются', () => {
      release('KeyW', 'w');
      release('KeyA', 'a');
      expect(window.Byond.command).toHaveBeenCalledWith('KeyUp "W"');
      expect(window.Byond.command).toHaveBeenCalledWith('KeyUp "A"');
    });

    test('одна нажата в панели, другая orphaned — только orphaned пробрасывается', () => {
      press('KeyW', 'w'); // W pressed in panel
      release('KeyW', 'w'); // W released — was in panel, not forwarded
      release('KeyA', 'a'); // A released — orphaned, forwarded

      expect(window.Byond.command).not.toHaveBeenCalledWith('KeyUp "W"');
      expect(window.Byond.command).toHaveBeenCalledWith('KeyUp "A"');
    });
  });

  // ── Последовательность press → blur → press → release ───

  describe('цикл фокуса', () => {
    test('press → blur → новый press → release: не пробрасывает (key заново нажат в панели)', () => {
      press('KeyD', 'd'); // Pressed in panel
      window.dispatchEvent(new Event('blur')); // Focus moved away
      press('KeyD', 'd'); // Pressed AGAIN in panel
      release('KeyD', 'd'); // Released — has preceding keydown

      expect(window.Byond.command).not.toHaveBeenCalledWith('KeyUp "D"');
    });

    test('press → blur → release: пробрасывает (blur очистил tracking)', () => {
      press('KeyS', 's');
      window.dispatchEvent(new Event('blur'));
      release('KeyS', 's');

      expect(window.Byond.command).toHaveBeenCalledWith('KeyUp "S"');
    });
  });
});
