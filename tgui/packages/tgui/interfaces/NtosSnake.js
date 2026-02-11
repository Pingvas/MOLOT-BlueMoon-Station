import { useBackend, useLocalState } from '../backend';
import { Button } from '../components';
import { NtosWindow } from '../layouts';

const DIR_UP = 1;
const DIR_DOWN = 2;
const DIR_LEFT = 3;
const DIR_RIGHT = 4;

export const NtosSnake = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    game_active = false,
    paused = false,
    score = 0,
    high_score = 0,
    death_reason = '',
    grid_w = 20,
    grid_h = 15,
    body = [],
    food = {},
  } = data;

  // Построим Set для O(1) проверки тела
  const bodySet = new Set();
  body.forEach((seg) => bodySet.add(seg.x + ',' + seg.y));
  const headSeg = body.length > 0 ? body[body.length - 1] : null;
  const headKey = headSeg ? headSeg.x + ',' + headSeg.y : null;

  // Строим строки
  const rows = [];
  for (let y = 1; y <= grid_h; y++) {
    const cells = [];
    for (let x = 1; x <= grid_w; x++) {
      const key = x + ',' + y;
      let cls = 'NtosSnake__cell';
      if (key === headKey) {
        cls += ' NtosSnake__cell--head';
      } else if (bodySet.has(key)) {
        cls += ' NtosSnake__cell--body';
      } else if (food && food.x === x && food.y === y) {
        cls += ' NtosSnake__cell--food';
      }
      cells.push(<div key={key} className={cls} />);
    }
    rows.push(
      <div key={'row' + y} className="NtosSnake__row">
        {cells}
      </div>
    );
  }

  return (
    <NtosWindow width={480} height={500}>
      <NtosWindow.Content>
        <div className="NtosSnake">
          {/* Заголовок */}
          <div className="NtosSnake__header">
            <span className="NtosSnake__title">
              {'🐍 Змейка'}
            </span>
            <span className="NtosSnake__score">
              {'Счёт: '}
              <b>{score}</b>
              {high_score > 0 && (
                <span className="NtosSnake__highscore">
                  {' | Рекорд: ' + high_score}
                </span>
              )}
            </span>
          </div>

          {/* Игровое поле */}
          <div className="NtosSnake__field-wrap">
            <div className="NtosSnake__field">
              {rows}
            </div>

            {/* Оверлей при паузе */}
            {!!game_active && !!paused && (
              <div className="NtosSnake__overlay">
                <div className="NtosSnake__overlay-text">{'⏸ ПАУЗА'}</div>
              </div>
            )}

            {/* Оверлей game over */}
            {!game_active && !!death_reason && (
              <div className="NtosSnake__overlay NtosSnake__overlay--dead">
                <div className="NtosSnake__overlay-text">{'💀 ИГРА ОКОНЧЕНА'}</div>
                <div className="NtosSnake__overlay-reason">{death_reason}</div>
                <div className="NtosSnake__overlay-score">{'Счёт: ' + score}</div>
              </div>
            )}

            {/* Оверлей стартовый */}
            {!game_active && !death_reason && (
              <div className="NtosSnake__overlay">
                <div className="NtosSnake__overlay-text">{'🐍 ЗМЕЙКА'}</div>
                <div className="NtosSnake__overlay-reason">
                  {'Нажмите «Старт» чтобы начать'}
                </div>
              </div>
            )}
          </div>

          {/* Управление */}
          <div className="NtosSnake__controls">
            <div className="NtosSnake__dpad">
              <div className="NtosSnake__dpad-row">
                <Button
                  className="NtosSnake__dpad-btn"
                  onClick={() => act('dir', { dir: DIR_UP })}
                  disabled={!game_active || !!paused}>
                  {'▲'}
                </Button>
              </div>
              <div className="NtosSnake__dpad-row">
                <Button
                  className="NtosSnake__dpad-btn"
                  onClick={() => act('dir', { dir: DIR_LEFT })}
                  disabled={!game_active || !!paused}>
                  {'◄'}
                </Button>
                <Button
                  className="NtosSnake__dpad-btn"
                  onClick={() => act('dir', { dir: DIR_DOWN })}
                  disabled={!game_active || !!paused}>
                  {'▼'}
                </Button>
                <Button
                  className="NtosSnake__dpad-btn"
                  onClick={() => act('dir', { dir: DIR_RIGHT })}
                  disabled={!game_active || !!paused}>
                  {'►'}
                </Button>
              </div>
            </div>
            <div className="NtosSnake__action-btns">
              {!game_active ? (
                <Button
                  className="NtosSnake__btn-start"
                  onClick={() => act('start')}
                  color="green"
                  bold
                  fluid>
                  {death_reason ? '▶ Заново' : '▶ Старт'}
                </Button>
              ) : (
                <Button
                  className="NtosSnake__btn-pause"
                  onClick={() => act('pause')}
                  color={paused ? 'green' : 'yellow'}
                  fluid>
                  {paused ? '▶ Продолжить' : '⏸ Пауза'}
                </Button>
              )}
            </div>
          </div>
        </div>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
