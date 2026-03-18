import { useBackend } from '../../../backend';
import { Box, Button, ByondUi, Stack } from '../../../components';
import { CharacterSetupData } from '../types';

const PREVIEW_PREF_JOB = 'Job';
const PREVIEW_PREF_LOADOUT = 'Loadout';
const PREVIEW_PREF_NAKED = 'Naked';
const PREVIEW_PREF_NAKED_AROUSED = 'Naked - Aroused';

export const CharacterPreview = (_props, context) => {
  const { act, data, config } = useBackend<CharacterSetupData>(context);
  const {
    character_preview_view,
    preview_pref = PREVIEW_PREF_JOB,
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
        }}>
        {character_preview_view && config.status >= 2 ? (
          <ByondUi
            height="100%"
            width="100%"
            params={{
              id: character_preview_view,
              type: 'map',
              zoom: 0,
            }}
          />
        ) : (
          <Box
            height="100%"
            width="100%"
            style={{
              'display': 'flex',
              'align-items': 'center',
              'justify-content': 'center',
              'background': 'rgba(0,0,0,0.3)',
            }}>
            <Box color="label" italic>
              Загрузка...
            </Box>
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
              tooltip="Обновить"
              onClick={() => act('refresh_preview')}
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
