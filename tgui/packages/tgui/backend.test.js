/**
 * Tests for backend.ts middleware and reducer.
 *
 * Focus: suspendSuccess winset retry, suspendStart interval,
 * backendReducer state transitions.
 *
 * @file
 */

// Mock external dependencies before any imports.
jest.mock('common/defer', () => ({
  __esModule: true,
  defer: (fn) => fn(),
}));

jest.mock('common/perf', () => ({
  __esModule: true,
  perf: { mark: () => {} },
}));

jest.mock('./drag', () => ({
  __esModule: true,
  resetInitialGeometryReady: () => {},
  setupDrag: () => {},
  waitForInitialGeometryReady: () => Promise.resolve(),
}));

jest.mock('./focus', () => ({
  __esModule: true,
  focusMap: jest.fn(),
}));

jest.mock('./logging', () => ({
  __esModule: true,
  createLogger: () => ({
    log: () => {},
    error: () => {},
  }),
}));

jest.mock('./renderer', () => ({
  __esModule: true,
  resumeRenderer: jest.fn(),
  suspendRenderer: jest.fn(),
}));

import {
  backendMiddleware,
  backendReducer,
  backendSuspendStart,
  backendSuspendSuccess,
  backendUpdate,
  sendMessage,
} from './backend';
import { suspendRenderer } from './renderer';

// ───────────────────────────────────────────────────────────────────
// Setup: mock Byond global
// ───────────────────────────────────────────────────────────────────

beforeEach(() => {
  window.__windowId__ = 'tgui-window-1';
  global.Byond = {
    winset: jest.fn(),
    topic: jest.fn(),
  };
});

afterEach(() => {
  jest.restoreAllMocks();
});

// ───────────────────────────────────────────────────────────────────
// Tests: backendReducer
// ───────────────────────────────────────────────────────────────────

describe('backendReducer', () => {
  test('начальное состояние: suspended=truthy, suspending=false', () => {
    const state = backendReducer(undefined, { type: 'init' });
    expect(state.suspended).toBeTruthy();
    expect(state.suspending).toBe(false);
    expect(state.data).toEqual({});
    expect(state.config).toEqual({});
  });

  test('backend/update: снимает suspended, устанавливает data и config', () => {
    const initialState = backendReducer(undefined, { type: 'init' });
    const payload = {
      config: { title: 'Test UI', status: 2, interface: 'TestInterface' },
      data: { items: [1, 2, 3] },
      // shared values are JSON-encoded strings from the DM side
      shared: { key: '"value"' },
    };
    const state = backendReducer(initialState, backendUpdate(payload));
    expect(state.suspended).toBe(false);
    expect(state.data).toEqual({ items: [1, 2, 3] });
    expect(state.config.title).toBe('Test UI');
    expect(state.shared.key).toBe('value');
  });

  test('backend/update: мержит data с предыдущим состоянием', () => {
    const prev = backendReducer(undefined, { type: 'init' });
    const withData = backendReducer(
      prev,
      backendUpdate({
        config: { title: 'T' },
        data: { a: 1, b: 2 },
      }),
    );
    // Update без data — data сохраняется
    const withoutData = backendReducer(
      withData,
      backendUpdate({ config: { title: 'T2' } }),
    );
    expect(withoutData.data).toEqual({ a: 1, b: 2 });
    expect(withoutData.config.title).toBe('T2');
  });

  test('backend/suspendStart: устанавливает suspending=true', () => {
    const state = backendReducer(undefined, backendSuspendStart());
    expect(state.suspending).toBe(true);
  });

  test('backend/suspendSuccess: устанавливает suspended, сбрасывает suspending', () => {
    jest.spyOn(Date, 'now').mockReturnValue(12345);
    const prev = backendReducer(undefined, backendSuspendStart());
    expect(prev.suspending).toBe(true);

    const state = backendReducer(prev, backendSuspendSuccess());
    expect(state.suspended).toBe(12345);
    expect(state.suspending).toBe(false);
  });

  test('backend/suspendSuccess: очищает config.title', () => {
    const withConfig = backendReducer(
      undefined,
      backendUpdate({
        config: { title: 'My Window' },
        data: {},
      }),
    );
    expect(withConfig.config.title).toBe('My Window');

    const suspended = backendReducer(withConfig, backendSuspendSuccess());
    expect(suspended.config.title).toBe('');
  });
});

// ───────────────────────────────────────────────────────────────────
// Tests: backendMiddleware — suspend flow
// ───────────────────────────────────────────────────────────────────

describe('backendMiddleware — suspend flow', () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  /** Create a mock Redux store + middleware chain. */
  const createMockStore = (initialBackendState = {}) => {
    let state = {
      backend: {
        config: {},
        data: {},
        shared: {},
        outgoingPayloadQueues: {},
        suspended: false,
        suspending: false,
        ...initialBackendState,
      },
    };
    const dispatched = [];
    const store = {
      getState: () => state,
      dispatch: jest.fn((action) => {
        dispatched.push(action);
        // Apply reducer for key actions
        if (
          action.type === 'backend/suspendSuccess' ||
          action.type === 'backend/suspendStart' ||
          action.type === 'backend/update'
        ) {
          state = {
            ...state,
            backend: backendReducer(state.backend, action),
          };
        }
      }),
    };
    const next = jest.fn();
    const middleware = backendMiddleware(store);
    const invoke = middleware(next);
    return { store, next, invoke, dispatched };
  };

  test('backend/suspendStart: отправляет suspend-сообщение', () => {
    const { invoke } = createMockStore();

    invoke(backendSuspendStart());

    expect(Byond.topic).toHaveBeenCalledWith(
      expect.objectContaining({
        tgui: 1,
        window_id: 'tgui-window-1',
        type: 'suspend',
      }),
    );
  });

  test('backend/suspendStart: устанавливает retry-интервал каждые 2с', () => {
    const { invoke } = createMockStore();

    invoke(backendSuspendStart());
    expect(Byond.topic).toHaveBeenCalledTimes(1);

    jest.advanceTimersByTime(2000);
    expect(Byond.topic).toHaveBeenCalledTimes(2);

    jest.advanceTimersByTime(2000);
    expect(Byond.topic).toHaveBeenCalledTimes(3);
  });

  test('backend/suspendStart: не создаёт второй интервал при повторном вызове', () => {
    const { invoke } = createMockStore();

    invoke(backendSuspendStart());
    invoke(backendSuspendStart());

    // Только 1 вызов topic (от первого suspendStart)
    expect(Byond.topic).toHaveBeenCalledTimes(1);

    jest.advanceTimersByTime(2000);
    // Только 1 retry (один интервал, не два)
    expect(Byond.topic).toHaveBeenCalledTimes(2);
  });

  test('suspend message: middleware диспатчит backendSuspendSuccess', () => {
    const { invoke, store } = createMockStore();

    invoke({ type: 'suspend' });

    expect(store.dispatch).toHaveBeenCalledWith(
      expect.objectContaining({ type: 'backend/suspendSuccess' }),
    );
  });

  test('backend/suspendSuccess: вызывает suspendRenderer', () => {
    const { invoke } = createMockStore();

    invoke(backendSuspendSuccess());

    expect(suspendRenderer).toHaveBeenCalled();
  });

  test('backend/suspendSuccess: отправляет is-visible=false через winset', () => {
    const { invoke } = createMockStore();

    invoke(backendSuspendSuccess());

    expect(Byond.winset).toHaveBeenCalledWith('tgui-window-1', {
      'is-visible': false,
    });
  });

  test('backend/suspendSuccess: retry winset через 200мс', () => {
    const { invoke } = createMockStore();

    invoke(backendSuspendSuccess());

    // Первый вызов — сразу
    expect(Byond.winset).toHaveBeenCalledTimes(1);

    // Retry через 200мс
    jest.advanceTimersByTime(200);
    expect(Byond.winset).toHaveBeenCalledTimes(2);
    expect(Byond.winset).toHaveBeenLastCalledWith('tgui-window-1', {
      'is-visible': false,
    });
  });

  test('backend/suspendSuccess: ровно 1 retry (не более)', () => {
    const { invoke } = createMockStore();

    invoke(backendSuspendSuccess());

    jest.advanceTimersByTime(1000); // Много больше 200мс
    expect(Byond.winset).toHaveBeenCalledTimes(2); // 1 сразу + 1 retry
  });

  test('backend/suspendSuccess: очищает suspendStart интервал', () => {
    const { invoke } = createMockStore();

    // Запускаем suspend flow
    invoke(backendSuspendStart());
    expect(Byond.topic).toHaveBeenCalledTimes(1);

    // Получаем подтверждение
    invoke(backendSuspendSuccess());

    // Интервал должен быть очищен — topic больше не вызывается
    jest.advanceTimersByTime(4000);
    // Только начальный вызов от suspendStart (topic), без retry
    expect(Byond.topic).toHaveBeenCalledTimes(1);
  });

  test('полный цикл: suspendStart → suspend → suspendSuccess → winset retry', () => {
    const { invoke, store } = createMockStore();

    // 1. Нажатие X — frontend отправляет suspend
    invoke(backendSuspendStart());
    expect(Byond.topic).toHaveBeenCalledTimes(1);

    // 2. DM отвечает suspend-подтверждением
    invoke({ type: 'suspend' });
    expect(store.dispatch).toHaveBeenCalledWith(
      expect.objectContaining({ type: 'backend/suspendSuccess' }),
    );

    // 3. suspendSuccess: winset + retry
    invoke(backendSuspendSuccess());
    expect(Byond.winset).toHaveBeenCalledTimes(1);
    expect(Byond.winset).toHaveBeenCalledWith('tgui-window-1', {
      'is-visible': false,
    });

    jest.advanceTimersByTime(200);
    expect(Byond.winset).toHaveBeenCalledTimes(2);

    // 4. Интервал retry отключён
    jest.advanceTimersByTime(5000);
    expect(Byond.topic).toHaveBeenCalledTimes(1); // без дополнительных вызовов
  });
});

// ───────────────────────────────────────────────────────────────────
// Tests: backendMiddleware — message routing
// ───────────────────────────────────────────────────────────────────

describe('backendMiddleware — message routing', () => {
  const createMockStore = (initialBackendState = {}) => {
    const state = {
      backend: {
        config: {},
        data: {},
        shared: {},
        outgoingPayloadQueues: {},
        suspended: Date.now(),
        suspending: false,
        ...initialBackendState,
      },
    };
    const store = {
      getState: () => state,
      dispatch: jest.fn(),
    };
    const next = jest.fn();
    const middleware = backendMiddleware(store);
    const invoke = middleware(next);
    return { store, next, invoke };
  };

  test('update → dispatch backendUpdate', () => {
    const { store, invoke, next } = createMockStore();
    const payload = { config: { title: 'T' }, data: { x: 1 } };

    invoke({ type: 'update', payload });

    expect(store.dispatch).toHaveBeenCalledWith(
      expect.objectContaining({
        type: 'backend/update',
        payload,
      }),
    );
    expect(next).not.toHaveBeenCalled(); // update не проходит к next
  });

  test('ping → отправляет pingReply', () => {
    const { invoke, next } = createMockStore();

    invoke({ type: 'ping' });

    expect(Byond.topic).toHaveBeenCalledWith(
      expect.objectContaining({
        tgui: 1,
        window_id: 'tgui-window-1',
        type: 'pingReply',
      }),
    );
    expect(next).not.toHaveBeenCalled();
  });

  test('неизвестный action → проходит к next', () => {
    const { next, invoke } = createMockStore();
    const action = { type: 'some/unknown', payload: {} };

    invoke(action);

    expect(next).toHaveBeenCalledWith(action);
  });
});

// ───────────────────────────────────────────────────────────────────
// Tests: sendMessage
// ───────────────────────────────────────────────────────────────────

describe('sendMessage', () => {
  test('отправляет topic с tgui=1 и window_id', () => {
    sendMessage({ type: 'ready' });

    expect(Byond.topic).toHaveBeenCalledWith(
      expect.objectContaining({
        tgui: 1,
        window_id: 'tgui-window-1',
        type: 'ready',
      }),
    );
  });

  test('JSON-кодирует payload', () => {
    sendMessage({
      type: 'act/test',
      payload: { key: 'value', num: 42 },
    });

    expect(Byond.topic).toHaveBeenCalledWith(
      expect.objectContaining({
        type: 'act/test',
        payload: '{"key":"value","num":42}',
      }),
    );
  });

  test('не включает payload если он undefined', () => {
    sendMessage({ type: 'suspend' });

    const call = Byond.topic.mock.calls[0][0];
    expect(call.type).toBe('suspend');
    expect('payload' in call).toBe(false);
  });

  test('не включает payload если он null', () => {
    sendMessage({ type: 'test', payload: null });

    const call = Byond.topic.mock.calls[0][0];
    expect('payload' in call).toBe(false);
  });

  test('пустой вызов без аргументов не падает', () => {
    expect(() => sendMessage()).not.toThrow();
    expect(Byond.topic).toHaveBeenCalled();
  });
});
