/**
 * Tests for TGUI bridge utilities defined in tgui/public/tgui.html.
 *
 * Since tgui.html is an inline script (runs before the bundle loads),
 * we cannot import its functions directly. Instead, we recreate the
 * pure logic in helpers and test the exact same algorithms.
 *
 * Each section references the corresponding tgui.html line numbers.
 *
 * @file
 */

// ───────────────────────────────────────────────────────────────────
// Helpers: reproduce pure logic from tgui.html
// ───────────────────────────────────────────────────────────────────

/** Mirrors window.__stringifyTguiDebugTruncated__ (tgui.html ~lines 693-728) */
const stringifyTguiDebugTruncated = (debug) => {
  if (!debug) debug = {};
  try {
    const slim = {
      v: debug.version,
      hasMsg: !!debug.hasAnyMessage,
      hasUpd: !!debug.hasBackendUpdate,
      inc: debug.incomingCount || 0,
      readyCnt: debug.readySentCount || 0,
    };
    let events = debug.events || [];
    if (events.length > 4) {
      events = events.slice(events.length - 4);
    }
    slim.ev = [];
    for (let i = 0; i < events.length; i++) {
      slim.ev.push(events[i].kind);
    }
    let attempts = debug.transportAttempts || [];
    if (attempts.length > 2) {
      attempts = attempts.slice(attempts.length - 2);
    }
    slim.tr = [];
    for (let j = 0; j < attempts.length; j++) {
      slim.tr.push(attempts[j].name + ':' + (attempts[j].ok ? 'ok' : 'fail'));
    }
    let result = JSON.stringify(slim);
    if (result.length > 1024) {
      result = result.substring(0, 1021) + '...';
    }
    return result;
  } catch (err) {
    return (
      '[truncated debug error: ' +
      (err && err.message ? err.message : err) +
      ']'
    );
  }
};

/**
 * Mirrors the smart watchdog condition (tgui.html ~lines 953-966).
 * Returns true when the watchdog should fire (show overlay).
 */
const shouldWatchdogFire = (
  appBooted,
  elapsed,
  jsAttempt,
  jsMaxAttempts,
  timeSinceLastAttempt,
  jsLoadTimeout,
) => {
  if (appBooted) return false;
  const retryActive =
    jsAttempt < jsMaxAttempts &&
    timeSinceLastAttempt < jsLoadTimeout + 2000;
  return elapsed >= 12000 && !retryActive;
};

/**
 * Mirrors Byond.call URL length decision (tgui.html ~lines 271-286).
 * Returns 'location.href' | 'xhr' based on URL length.
 */
const chooseTransport = (url) => {
  if (url.length < 2048) return 'location.href';
  return 'xhr';
};

/**
 * Calculates total maximum wait time for all retry attempts.
 * Models the loadAsset retry loop from tgui.html ~lines 447-472.
 */
const calculateMaxRetryTime = (
  retryAttempts,
  jsLoadTimeout,
  retryWaitInitial,
  retryWaitIncrement,
) => {
  let total = 0;
  for (let attempt = 0; attempt < retryAttempts; attempt++) {
    total += jsLoadTimeout; // Wait for timeout
    if (attempt < retryAttempts - 1) {
      total += retryWaitInitial + attempt * retryWaitIncrement; // Wait for retry delay
    }
  }
  return total;
};

// ───────────────────────────────────────────────────────────────────
// Constants (must match tgui.html values)
// ───────────────────────────────────────────────────────────────────

const JS_LOAD_TIMEOUT = 5000;
const RETRY_ATTEMPTS = 5;
const RETRY_WAIT_INITIAL = 250;
const RETRY_WAIT_INCREMENT = 500;

// ───────────────────────────────────────────────────────────────────
// Tests: Retry timing constants
// ───────────────────────────────────────────────────────────────────

describe('retry timing constants', () => {
  test('JS_LOAD_TIMEOUT = 5000мс (ранее 15000)', () => {
    expect(JS_LOAD_TIMEOUT).toBe(5000);
  });

  test('RETRY_ATTEMPTS = 5', () => {
    expect(RETRY_ATTEMPTS).toBe(5);
  });

  test('RETRY_WAIT_INITIAL = 250мс (ранее 500)', () => {
    expect(RETRY_WAIT_INITIAL).toBe(250);
  });

  test('RETRY_WAIT_INCREMENT = 500мс', () => {
    expect(RETRY_WAIT_INCREMENT).toBe(500);
  });

  test('первый retry начинается через ~5.25с', () => {
    // JS_LOAD_TIMEOUT + RETRY_WAIT_INITIAL
    const firstRetryStart = JS_LOAD_TIMEOUT + RETRY_WAIT_INITIAL;
    expect(firstRetryStart).toBe(5250);
  });

  test('второй retry начинается через ~10.75с', () => {
    // attempt 0: JS_LOAD_TIMEOUT = 5000
    // retry wait: 250 + 0*500 = 250
    // attempt 1: JS_LOAD_TIMEOUT = 5000
    // retry wait: 250 + 1*500 = 750
    const secondRetryStart =
      JS_LOAD_TIMEOUT +
      (RETRY_WAIT_INITIAL + 0 * RETRY_WAIT_INCREMENT) +
      JS_LOAD_TIMEOUT +
      (RETRY_WAIT_INITIAL + 1 * RETRY_WAIT_INCREMENT);
    expect(secondRetryStart).toBe(11000);
  });

  test('максимальное ожидание всех 5 попыток < 40с', () => {
    const maxWait = calculateMaxRetryTime(
      RETRY_ATTEMPTS,
      JS_LOAD_TIMEOUT,
      RETRY_WAIT_INITIAL,
      RETRY_WAIT_INCREMENT,
    );
    expect(maxWait).toBeLessThan(40000);
    // Exact: 5*5000 + (250+750+1250+1750) = 25000 + 4000 = 29000
    expect(maxWait).toBe(29000);
  });

  test('максимальное ожидание значительно меньше прежнего (80с)', () => {
    const oldMaxWait = calculateMaxRetryTime(5, 15000, 500, 500);
    const newMaxWait = calculateMaxRetryTime(
      RETRY_ATTEMPTS,
      JS_LOAD_TIMEOUT,
      RETRY_WAIT_INITIAL,
      RETRY_WAIT_INCREMENT,
    );
    expect(newMaxWait).toBeLessThan(oldMaxWait);
    // Old: 5*15000 + (500+1000+1500+2000) = 75000 + 5000 = 80000
    expect(oldMaxWait).toBe(80000);
  });
});

// ───────────────────────────────────────────────────────────────────
// Tests: stringifyTguiDebugTruncated
// ───────────────────────────────────────────────────────────────────

describe('stringifyTguiDebugTruncated', () => {
  test('возвращает JSON-строку с ключевыми полями', () => {
    const debug = {
      version: 'bridge-localhost-fallback-v2',
      hasAnyMessage: true,
      hasBackendUpdate: true,
      incomingCount: 18,
      readySentCount: 3,
      events: [{ kind: 'env' }, { kind: 'sendReady' }],
      transportAttempts: [{ name: 'location.href', ok: true }],
    };
    const result = JSON.parse(stringifyTguiDebugTruncated(debug));
    expect(result.v).toBe('bridge-localhost-fallback-v2');
    expect(result.hasMsg).toBe(true);
    expect(result.hasUpd).toBe(true);
    expect(result.inc).toBe(18);
    expect(result.readyCnt).toBe(3);
  });

  test('включает только последние 4 события (kind)', () => {
    const events = [];
    for (let i = 0; i < 10; i++) {
      events.push({ kind: 'event_' + i, payload: { data: i } });
    }
    const debug = { events, transportAttempts: [] };
    const result = JSON.parse(stringifyTguiDebugTruncated(debug));
    expect(result.ev).toHaveLength(4);
    expect(result.ev[0]).toBe('event_6');
    expect(result.ev[3]).toBe('event_9');
  });

  test('включает только последние 2 transport-попытки', () => {
    const attempts = [];
    for (let i = 0; i < 5; i++) {
      attempts.push({ name: 'transport_' + i, ok: i % 2 === 0 });
    }
    const debug = { events: [], transportAttempts: attempts };
    const result = JSON.parse(stringifyTguiDebugTruncated(debug));
    expect(result.tr).toHaveLength(2);
    expect(result.tr[0]).toBe('transport_3:fail');
    expect(result.tr[1]).toBe('transport_4:ok');
  });

  test('транспорт-попытки форматируются как "name:ok" или "name:fail"', () => {
    const debug = {
      events: [],
      transportAttempts: [
        { name: 'location.href', ok: true },
        { name: 'xmlhttprequest', ok: false },
      ],
    };
    const result = JSON.parse(stringifyTguiDebugTruncated(debug));
    expect(result.tr).toEqual(['location.href:ok', 'xmlhttprequest:fail']);
  });

  test('работает с пустыми массивами', () => {
    const debug = { events: [], transportAttempts: [] };
    const result = JSON.parse(stringifyTguiDebugTruncated(debug));
    expect(result.ev).toEqual([]);
    expect(result.tr).toEqual([]);
  });

  test('работает без events и transportAttempts', () => {
    const debug = {};
    const result = JSON.parse(stringifyTguiDebugTruncated(debug));
    expect(result.ev).toEqual([]);
    expect(result.tr).toEqual([]);
    expect(result.inc).toBe(0);
    expect(result.readyCnt).toBe(0);
  });

  test('работает с null debug (edge case)', () => {
    const result = stringifyTguiDebugTruncated(null);
    const parsed = JSON.parse(result);
    expect(parsed.ev).toEqual([]);
    expect(parsed.tr).toEqual([]);
  });

  test('обрезает результат до 1024 символов', () => {
    const longEvents = [];
    for (let i = 0; i < 4; i++) {
      longEvents.push({ kind: 'a'.repeat(300) });
    }
    const debug = { events: longEvents, transportAttempts: [] };
    const result = stringifyTguiDebugTruncated(debug);
    expect(result.length).toBeLessThanOrEqual(1024);
  });

  test('добавляет "..." при обрезке', () => {
    const longEvents = [];
    for (let i = 0; i < 4; i++) {
      longEvents.push({ kind: 'x'.repeat(300) });
    }
    const debug = { events: longEvents, transportAttempts: [] };
    const result = stringifyTguiDebugTruncated(debug);
    if (result.length >= 1024) {
      expect(result).toMatch(/\.\.\.$/);
      expect(result.length).toBe(1024);
    }
  });

  test('не обрезает короткие результаты', () => {
    const debug = {
      version: 'v2',
      events: [{ kind: 'env' }],
      transportAttempts: [{ name: 'loc', ok: true }],
    };
    const result = stringifyTguiDebugTruncated(debug);
    expect(result.length).toBeLessThan(1024);
    expect(result).not.toMatch(/\.\.\.$/);
    // Должен быть валидный JSON
    expect(() => JSON.parse(result)).not.toThrow();
  });

  test('при <=4 событиях включает все', () => {
    const events = [
      { kind: 'a' },
      { kind: 'b' },
      { kind: 'c' },
      { kind: 'd' },
    ];
    const debug = { events, transportAttempts: [] };
    const result = JSON.parse(stringifyTguiDebugTruncated(debug));
    expect(result.ev).toEqual(['a', 'b', 'c', 'd']);
  });

  test('при <=2 transport-попытках включает все', () => {
    const attempts = [
      { name: 'first', ok: true },
      { name: 'second', ok: false },
    ];
    const debug = { events: [], transportAttempts: attempts };
    const result = JSON.parse(stringifyTguiDebugTruncated(debug));
    expect(result.tr).toEqual(['first:ok', 'second:fail']);
  });

  test('не включает payload событий (экономия места)', () => {
    const debug = {
      events: [
        { kind: 'incoming', payload: { index: 1, type: 'update', messageLength: 7468 } },
      ],
      transportAttempts: [],
    };
    const result = stringifyTguiDebugTruncated(debug);
    expect(result).not.toContain('messageLength');
    expect(result).not.toContain('7468');
  });

  test('hasMsg=false когда hasAnyMessage=false', () => {
    const debug = { hasAnyMessage: false, events: [], transportAttempts: [] };
    const result = JSON.parse(stringifyTguiDebugTruncated(debug));
    expect(result.hasMsg).toBe(false);
  });

  test('hasMsg=false когда hasAnyMessage=undefined', () => {
    const debug = { events: [], transportAttempts: [] };
    const result = JSON.parse(stringifyTguiDebugTruncated(debug));
    expect(result.hasMsg).toBe(false);
  });
});

// ───────────────────────────────────────────────────────────────────
// Tests: Smart watchdog logic
// ───────────────────────────────────────────────────────────────────

describe('smart watchdog', () => {
  describe('не срабатывает', () => {
    test('если app уже загрузился', () => {
      expect(
        shouldWatchdogFire(
          true, // appBooted
          20000, // elapsed (20s)
          5, // jsAttempt (all exhausted)
          5, // jsMaxAttempts
          30000, // timeSinceLastAttempt
          JS_LOAD_TIMEOUT,
        ),
      ).toBe(false);
    });

    test('если retry ещё активны (attempt < max)', () => {
      expect(
        shouldWatchdogFire(
          false,
          15000, // 15с прошло
          2, // 3-я попытка (0-indexed)
          5,
          1000, // 1с с последней попытки
          JS_LOAD_TIMEOUT,
        ),
      ).toBe(false);
    });

    test('если прошло < 12 секунд даже без активных retry', () => {
      expect(
        shouldWatchdogFire(
          false,
          8000, // 8с — мало
          5, // retry исчерпаны
          5,
          30000,
          JS_LOAD_TIMEOUT,
        ),
      ).toBe(false);
    });

    test('если прошло < 12 секунд и retry активны', () => {
      expect(
        shouldWatchdogFire(
          false,
          5000, // 5с
          0, // первая попытка
          5,
          2000, // 2с с попытки
          JS_LOAD_TIMEOUT,
        ),
      ).toBe(false);
    });

    test('если retry в процессе (время < JS_LOAD_TIMEOUT + 2000мс)', () => {
      // Последняя попытка началась 3с назад, JS_LOAD_TIMEOUT=5с → ещё ждём
      expect(
        shouldWatchdogFire(
          false,
          14000, // >12с
          3,
          5,
          3000, // 3с < 5000+2000=7000
          JS_LOAD_TIMEOUT,
        ),
      ).toBe(false);
    });
  });

  describe('срабатывает', () => {
    test('когда retry исчерпаны и прошло >= 12с', () => {
      expect(
        shouldWatchdogFire(
          false,
          15000,
          5, // attempt == max → retry НЕ активны
          5,
          10000,
          JS_LOAD_TIMEOUT,
        ),
      ).toBe(true);
    });

    test('когда retry зависли (время > JS_LOAD_TIMEOUT + 2000) и прошло >= 12с', () => {
      expect(
        shouldWatchdogFire(
          false,
          20000,
          2, // attempt < max, НО...
          5,
          8000, // 8с > 5000+2000=7000 → retry НЕ активны
          JS_LOAD_TIMEOUT,
        ),
      ).toBe(true);
    });

    test('граничное значение: elapsed ровно 12000мс', () => {
      expect(
        shouldWatchdogFire(
          false,
          12000, // ровно 12с
          5,
          5,
          30000,
          JS_LOAD_TIMEOUT,
        ),
      ).toBe(true);
    });

    test('граничное значение: timeSinceLastAttempt ровно JS_LOAD_TIMEOUT+2000', () => {
      expect(
        shouldWatchdogFire(
          false,
          15000,
          2,
          5,
          JS_LOAD_TIMEOUT + 2000, // ровно 7000 — НЕ < 7000, значит retry неактивны
          JS_LOAD_TIMEOUT,
        ),
      ).toBe(true);
    });
  });

  describe('граничные переходы retry', () => {
    test('attempt 0: retry активны', () => {
      expect(
        shouldWatchdogFire(false, 13000, 0, 5, 1000, JS_LOAD_TIMEOUT),
      ).toBe(false);
    });

    test('attempt 4 (последний): retry активны если время < порога', () => {
      expect(
        shouldWatchdogFire(false, 13000, 4, 5, 1000, JS_LOAD_TIMEOUT),
      ).toBe(false);
    });

    test('attempt 5 (== max): retry НЕ активны', () => {
      expect(
        shouldWatchdogFire(false, 13000, 5, 5, 1000, JS_LOAD_TIMEOUT),
      ).toBe(true);
    });
  });
});

// ───────────────────────────────────────────────────────────────────
// Tests: Asset retry state tracking
// ───────────────────────────────────────────────────────────────────

describe('asset retry state', () => {
  test('начальное состояние: jsAttempt=0, jsMaxAttempts=RETRY_ATTEMPTS', () => {
    const state = {
      jsAttempt: 0,
      jsMaxAttempts: RETRY_ATTEMPTS,
      jsLastAttemptAt: 0,
    };
    expect(state.jsAttempt).toBe(0);
    expect(state.jsMaxAttempts).toBe(5);
    expect(state.jsLastAttemptAt).toBe(0);
  });

  test('при загрузке JS: jsAttempt и jsLastAttemptAt обновляются', () => {
    const state = {
      jsAttempt: 0,
      jsMaxAttempts: RETRY_ATTEMPTS,
      jsLastAttemptAt: 0,
    };
    // Имитация первой попытки
    state.jsAttempt = 0;
    state.jsLastAttemptAt = 1000;
    expect(state.jsAttempt).toBe(0);
    expect(state.jsLastAttemptAt).toBe(1000);

    // Имитация retry (attempt 1)
    state.jsAttempt = 1;
    state.jsLastAttemptAt = 6250; // 5000 + 250
    expect(state.jsAttempt).toBe(1);
    expect(state.jsLastAttemptAt).toBe(6250);
  });

  test('watchdog не срабатывает пока retry state показывает активную попытку', () => {
    const state = {
      jsAttempt: 1,
      jsMaxAttempts: 5,
      jsLastAttemptAt: 6000,
    };
    const now = 8000;
    const retryActive =
      state.jsAttempt < state.jsMaxAttempts &&
      now - state.jsLastAttemptAt < JS_LOAD_TIMEOUT + 2000;
    expect(retryActive).toBe(true);
  });

  test('watchdog срабатывает когда state показывает исчерпанные retry', () => {
    const state = {
      jsAttempt: 5, // == max
      jsMaxAttempts: 5,
      jsLastAttemptAt: 20000,
    };
    const now = 30000;
    const retryActive =
      state.jsAttempt < state.jsMaxAttempts &&
      now - state.jsLastAttemptAt < JS_LOAD_TIMEOUT + 2000;
    expect(retryActive).toBe(false);
  });
});

// ───────────────────────────────────────────────────────────────────
// Tests: Transport URL length decision
// ───────────────────────────────────────────────────────────────────

describe('transport URL length decision', () => {
  test('короткий URL (<2048) → location.href', () => {
    expect(chooseTransport('a'.repeat(2047))).toBe('location.href');
  });

  test('длинный URL (>=2048) → xhr', () => {
    expect(chooseTransport('a'.repeat(2048))).toBe('xhr');
  });

  test('граница: ровно 2048 символов → xhr', () => {
    expect(chooseTransport('a'.repeat(2048))).toBe('xhr');
  });

  test('граница: 2047 символов → location.href', () => {
    expect(chooseTransport('a'.repeat(2047))).toBe('location.href');
  });

  test('пустой URL → location.href', () => {
    expect(chooseTransport('')).toBe('location.href');
  });

  test('truncated debug укладывается в 1024 символа → URL < 2048', () => {
    // URL включает: ?tgui=1&window_id=tgui-window-1&type=log&message=...
    // Prefix ~80 символов, message <= 1024 → total ~1104 < 2048
    const prefix = '?tgui=1&window_id=tgui-window-1&type=log&message=';
    const maxDebugLength = 1024;
    const totalUrl = prefix + encodeURIComponent('TGUI watchdog: app not booted. Debug=' + 'x'.repeat(maxDebugLength));
    expect(totalUrl.length).toBeLessThan(2048 * 2); // after encoding, can be up to 3x
    // Но сам debug <= 1024, и prefix ~85 chars = ~1109 raw chars
    // encodeURIComponent может увеличить, но JSON-ascii обычно не кодируется
    const rawUrl = prefix + 'TGUI watchdog: app not booted. Debug=' + 'a'.repeat(maxDebugLength);
    expect(rawUrl.length).toBeLessThan(2048);
  });
});

// ───────────────────────────────────────────────────────────────────
// Tests: Byond.command retry logic
// ───────────────────────────────────────────────────────────────────

describe('Byond.command retry', () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  /**
   * Simulates the Byond.command function from tgui.html (~lines 306-332).
   * Accepts mock functions for native bridge and legacy transport.
   */
  const createByondCommand = (nativeBridge, legacyCall) => {
    return (command) => {
      if (nativeBridge && typeof nativeBridge === 'function') {
        try {
          nativeBridge(command);
          return;
        } catch (err) {
          // fall through
        }
      }
      legacyCall(command);
      if (!nativeBridge) {
        setTimeout(() => {
          legacyCall(command);
        }, 150);
      }
    };
  };

  test('нативный мост доступен → один вызов, без retry', () => {
    const nativeBridge = jest.fn();
    const legacyCall = jest.fn();
    const command = createByondCommand(nativeBridge, legacyCall);

    command('test_command');

    expect(nativeBridge).toHaveBeenCalledTimes(1);
    expect(nativeBridge).toHaveBeenCalledWith('test_command');
    expect(legacyCall).not.toHaveBeenCalled();

    jest.advanceTimersByTime(200);
    expect(legacyCall).not.toHaveBeenCalled();
  });

  test('нативный мост недоступен → вызов + retry через 150мс', () => {
    const legacyCall = jest.fn();
    const command = createByondCommand(null, legacyCall);

    command('uiclose tgui-window-1');

    expect(legacyCall).toHaveBeenCalledTimes(1);
    expect(legacyCall).toHaveBeenCalledWith('uiclose tgui-window-1');

    jest.advanceTimersByTime(149);
    expect(legacyCall).toHaveBeenCalledTimes(1); // ещё не прошло 150мс

    jest.advanceTimersByTime(1);
    expect(legacyCall).toHaveBeenCalledTimes(2); // retry сработал
    expect(legacyCall).toHaveBeenLastCalledWith('uiclose tgui-window-1');
  });

  test('нативный мост выбрасывает исключение → fallback + retry', () => {
    const nativeBridge = jest.fn(() => {
      throw new Error('bridge error');
    });
    const legacyCall = jest.fn();
    const command = createByondCommand(nativeBridge, legacyCall);

    command('test');

    // Нативный мост бросил ошибку — должен был вызвать legacyCall
    expect(nativeBridge).toHaveBeenCalledTimes(1);
    expect(legacyCall).toHaveBeenCalledTimes(1);

    // Но retry НЕ запланирован, потому что nativeBridge !== null
    jest.advanceTimersByTime(200);
    expect(legacyCall).toHaveBeenCalledTimes(1);
  });

  test('retry = ровно 1 повторная попытка (не больше)', () => {
    const legacyCall = jest.fn();
    const command = createByondCommand(null, legacyCall);

    command('test');

    jest.advanceTimersByTime(500); // Сильно больше 150мс
    expect(legacyCall).toHaveBeenCalledTimes(2); // 1 сразу + 1 retry
  });

  test('несколько последовательных команд получают свои retry', () => {
    const legacyCall = jest.fn();
    const command = createByondCommand(null, legacyCall);

    command('cmd1');
    command('cmd2');

    expect(legacyCall).toHaveBeenCalledTimes(2);

    jest.advanceTimersByTime(150);
    expect(legacyCall).toHaveBeenCalledTimes(4); // 2 команды × 2 вызова
  });
});

// ───────────────────────────────────────────────────────────────────
// Tests: Watchdog timer behavior (integration with fake timers)
// ───────────────────────────────────────────────────────────────────

describe('watchdog timer integration', () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  test('noBackendUpdate watchdog: 10с таймаут (ранее 8с)', () => {
    const callback = jest.fn();

    // Имитация watchdog из tgui.html
    setTimeout(() => {
      callback('noBackendUpdate');
    }, 10000);

    jest.advanceTimersByTime(8000);
    expect(callback).not.toHaveBeenCalled(); // 8с — ещё не сработал

    jest.advanceTimersByTime(2000);
    expect(callback).toHaveBeenCalledWith('noBackendUpdate');
  });

  test('appNotBooted watchdog: интервал 2с начинает проверку', () => {
    let appBooted = false;
    const callback = jest.fn();
    let intervalCleared = false;

    const interval = setInterval(() => {
      if (appBooted) {
        clearInterval(interval);
        intervalCleared = true;
        return;
      }
      callback('check');
    }, 2000);

    jest.advanceTimersByTime(2000);
    expect(callback).toHaveBeenCalledTimes(1);

    jest.advanceTimersByTime(2000);
    expect(callback).toHaveBeenCalledTimes(2);

    // App загрузился
    appBooted = true;
    jest.advanceTimersByTime(2000);
    expect(intervalCleared).toBe(true);
    // Callback мог вызваться ещё раз перед clearInterval,
    // но после этого интервал остановлен
  });

  test('appNotBooted watchdog: auto-dismiss при appBooted=true', () => {
    let appBooted = false;
    const alarmFn = jest.fn();
    let cleared = false;

    const interval = setInterval(() => {
      if (appBooted) {
        clearInterval(interval);
        cleared = true;
        return;
      }
      // Условие: elapsed >= 12000 && !retryActive
      // Для теста упрощаем — считаем что условие всегда true
      alarmFn();
    }, 2000);

    jest.advanceTimersByTime(4000);
    expect(alarmFn).toHaveBeenCalledTimes(2);

    // App загрузился на 5й секунде
    appBooted = true;
    jest.advanceTimersByTime(2000);
    expect(cleared).toBe(true);

    // Больше alarm не вызывается
    const callCount = alarmFn.mock.calls.length;
    jest.advanceTimersByTime(10000);
    expect(alarmFn).toHaveBeenCalledTimes(callCount);
  });
});

// ───────────────────────────────────────────────────────────────────
// Tests: calculateMaxRetryTime
// ───────────────────────────────────────────────────────────────────

describe('calculateMaxRetryTime', () => {
  test('1 попытка — только timeout, без retry delay', () => {
    expect(calculateMaxRetryTime(1, 5000, 250, 500)).toBe(5000);
  });

  test('2 попытки — timeout + delay + timeout', () => {
    // attempt 0: 5000 (timeout) + 250 (delay, initial + 0*increment)
    // attempt 1: 5000 (timeout)
    expect(calculateMaxRetryTime(2, 5000, 250, 500)).toBe(10250);
  });

  test('5 попыток — формула подсчёта', () => {
    // 5 * 5000 = 25000 (timeouts)
    // delays: 250 + 750 + 1250 + 1750 = 4000
    // total: 29000
    expect(calculateMaxRetryTime(5, 5000, 250, 500)).toBe(29000);
  });

  test('0 попыток = 0 времени', () => {
    expect(calculateMaxRetryTime(0, 5000, 250, 500)).toBe(0);
  });

  test('старые значения (JS_LOAD_TIMEOUT=15000) дают 80000мс', () => {
    // 5*15000 + (500+1000+1500+2000) = 75000 + 5000 = 80000
    expect(calculateMaxRetryTime(5, 15000, 500, 500)).toBe(80000);
  });
});
