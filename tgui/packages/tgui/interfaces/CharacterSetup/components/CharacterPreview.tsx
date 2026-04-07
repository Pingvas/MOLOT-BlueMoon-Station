import { useBackend } from '../../../backend';
import { Box, Button, Stack } from '../../../components';
import { CharacterSetupData } from '../types';

const PREVIEW_PREF_JOB = 'Job';
const PREVIEW_PREF_LOADOUT = 'Loadout';
const PREVIEW_PREF_NAKED = 'Naked';
const PREVIEW_PREF_NAKED_AROUSED = 'Naked - Aroused';

export const CharacterPreview = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    preview_icon = null,
    preview_generating = false,
    preview_pref = PREVIEW_PREF_JOB,
    preview_zoom = 100,
  } = data as any;

  return (
    <Stack vertical fill>
      {/* Preview area */}
      <Stack.Item
        grow
        style={{
          'display': 'flex',
          'align-items': 'center',
          'justify-content': 'center',
          'overflow': 'hidden',
          'background': 'rgba(0,0,0,0.25)',
          'position': 'relative',
        }}>
        {preview_icon ? (
          <Box
            as="img"
            src={preview_icon}
            style={{
              'image-rendering': 'pixelated',
              'transform': `scale(${preview_zoom / 100})`,
              'transform-origin': 'center bottom',
              'max-width': '100%',
              'max-height': '100%',
            }}
          />
        ) : (
          <Box
            style={{
              'display': 'flex',
              'align-items': 'center',
              'justify-content': 'center',
              'width': '100%',
              'height': '100%',
            }}>
            <Box color="label" italic>
              {preview_generating ? 'Генерация...' : 'Загрузка...'}
            </Box>
          </Box>
        )}
        {/* Индикатор обновления */}
        {preview_generating && preview_icon && (
          <Box
            style={{
              'position': 'absolute',
              'bottom': '4px',
              'right': '4px',
              'font-size': '10px',
              'opacity': '0.5',
            }}
            color="label"
            italic>
            •••
          </Box>
        )}
      </Stack.Item>

      {/* Controls */}
      <Stack.Item>
        <Stack align="center">
          {/* Rotate */}
          <Stack.Item>
            <Button
              icon="undo"
              tooltip="Повернуть влево"
              onClick={() => act('rotate_preview', { backwards: 1 })}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="redo"
              tooltip="Повернуть вправо"
              onClick={() => act('rotate_preview', { backwards: 0 })}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="sync"
              tooltip="Перестроить"
              onClick={() => act('refresh_preview')}
            />
          </Stack.Item>

          {/* Zoom */}
          <Stack.Item>
            <Button
              icon="search-minus"
              tooltip="Уменьшить"
              disabled={preview_zoom <= 50}
              onClick={() => act('set_preview_zoom', { zoom: preview_zoom - 25 })}
            />
          </Stack.Item>
          <Stack.Item>
            <Box
              style={{ 'min-width': '38px', 'text-align': 'center', 'font-size': '11px' }}
              color="label">
              {preview_zoom}%
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="search-plus"
              tooltip="Увеличить"
              disabled={preview_zoom >= 200}
              onClick={() => act('set_preview_zoom', { zoom: preview_zoom + 25 })}
            />
          </Stack.Item>

          <Stack.Item grow />

          {/* Preview mode */}
          <Stack.Item>
            <Button
              selected={preview_pref === PREVIEW_PREF_JOB}
              icon="briefcase"
              tooltip="Работа"
              onClick={() => act('set_preview_pref', {
                pref: PREVIEW_PREF_JOB,
              })}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              selected={preview_pref === PREVIEW_PREF_LOADOUT}
              icon="box-open"
              tooltip="Лоадаут"
              onClick={() => act('set_preview_pref', {
                pref: PREVIEW_PREF_LOADOUT,
              })}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              selected={preview_pref === PREVIEW_PREF_NAKED}
              icon="tshirt"
              tooltip="Голый"
              onClick={() => act('set_preview_pref', {
                pref: PREVIEW_PREF_NAKED,
              })}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              selected={preview_pref === PREVIEW_PREF_NAKED_AROUSED}
              icon="heart"
              tooltip="Возбуждён"
              onClick={() => act('set_preview_pref', {
                pref: PREVIEW_PREF_NAKED_AROUSED,
              })}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
