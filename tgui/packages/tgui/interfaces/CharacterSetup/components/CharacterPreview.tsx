import { useBackend } from '../../../backend';
import { Box, Button, Stack } from '../../../components';
import { CharacterSetupData } from '../types';

const PREVIEW_PREF_JOB = 'Job';
const PREVIEW_PREF_LOADOUT = 'Loadout';
const PREVIEW_PREF_NAKED = 'Naked';
const PREVIEW_PREF_NAKED_AROUSED = 'Naked - Aroused';

const PREVIEW_MODE_BUTTONS = [
  { pref: PREVIEW_PREF_JOB, icon: 'briefcase', tooltip: 'Job outfit' },
  { pref: PREVIEW_PREF_LOADOUT, icon: 'box-open', tooltip: 'Loadout' },
  { pref: PREVIEW_PREF_NAKED, icon: 'tshirt', tooltip: 'Naked' },
  { pref: PREVIEW_PREF_NAKED_AROUSED, icon: 'heart', tooltip: 'Aroused' },
];

const PREVIEW_BASE_SIZE = 256;
const PREVIEW_MIN_ZOOM = 50;
const PREVIEW_MAX_ZOOM = 200;
const PREVIEW_ZOOM_STEP = 25;

const PREVIEW_CANVAS_STYLE = {
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  overflow: 'hidden',
  position: 'relative',
  padding: '6px',
  background:
    'radial-gradient(circle at 30% 20%, rgba(77, 109, 156, 0.25), rgba(12, 16, 24, 0.95) 58%), linear-gradient(140deg, rgba(36,52,73,0.42), rgba(12,16,24,0.92))',
} as const;

const PREVIEW_PATTERN_STYLE = {
  position: 'absolute',
  inset: '0',
  pointerEvents: 'none',
  opacity: '0.22',
  backgroundImage:
    'linear-gradient(0deg, rgba(255,255,255,0.03) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.03) 1px, transparent 1px)',
  backgroundSize: '18px 18px',
} as const;

const PREVIEW_FRAME_STYLE = {
  width: `${PREVIEW_BASE_SIZE}px`,
  height: `${PREVIEW_BASE_SIZE}px`,
  position: 'relative',
  overflow: 'hidden',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  borderRadius: '6px',
  border: '1px solid rgba(120, 163, 219, 0.28)',
  boxShadow: 'inset 0 0 0 1px rgba(255, 255, 255, 0.04)',
  background: 'rgba(5, 10, 18, 0.45)',
} as const;

const PREVIEW_EMPTY_STYLE = {
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  width: '100%',
  height: '100%',
} as const;

const PREVIEW_ZOOM_STYLE = {
  minWidth: '38px',
  textAlign: 'center',
  fontSize: '11px',
} as const;

const PREVIEW_SPINNER_STYLE = {
  position: 'absolute',
  bottom: '6px',
  right: '8px',
  fontSize: '10px',
  opacity: '0.55',
} as const;

const clampPreviewZoom = (value: unknown): number => {
  const numericValue = Number(value);
  if (!Number.isFinite(numericValue)) {
    return 100;
  }
  return Math.max(PREVIEW_MIN_ZOOM, Math.min(PREVIEW_MAX_ZOOM, numericValue));
};

const sanitizePreviewIcon = (value: unknown): string | null => {
  if (typeof value !== 'string') {
    return null;
  }
  const normalized = value.trim();
  return normalized.length ? normalized : null;
};

export const CharacterPreview = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    preview_icon = null,
    preview_generating = false,
    preview_pref = PREVIEW_PREF_JOB,
    preview_zoom = 100,
  } = data as any;

  const previewSrc = sanitizePreviewIcon(preview_icon);
  const isPreviewGenerating = Boolean(preview_generating);
  const clampedZoom = clampPreviewZoom(preview_zoom);
  const previewRenderSize = Math.max(1, Math.round(PREVIEW_BASE_SIZE * (clampedZoom / 100)));

  const setZoom = (nextZoom: number) => {
    act('set_preview_zoom', { zoom: clampPreviewZoom(nextZoom) });
  };

  return (
    <Stack vertical fill>
      <Stack.Item grow style={PREVIEW_CANVAS_STYLE}>
        <Box style={PREVIEW_PATTERN_STYLE} />

        {previewSrc ? (
          <Box style={PREVIEW_FRAME_STYLE}>
            <Box
              as="img"
              src={previewSrc}
              style={{
                width: `${previewRenderSize}px`,
                height: `${previewRenderSize}px`,
                maxWidth: 'none',
                maxHeight: 'none',
                display: 'block',
                flexShrink: 0,
                imageRendering: 'pixelated',
              }}
            />
          </Box>
        ) : (
          <Box style={PREVIEW_EMPTY_STYLE}>
            <Stack vertical align="center">
              <Stack.Item>
                <Box color="label" italic>
                  {isPreviewGenerating ? 'Generating...' : 'Preview not ready'}
                </Box>
              </Stack.Item>
            </Stack>
          </Box>
        )}

        {isPreviewGenerating && Boolean(previewSrc) ? (
          <Box
            style={PREVIEW_SPINNER_STYLE}
            color="label"
            italic>
            ...
          </Box>
        ) : null}
      </Stack.Item>

      <Stack.Item>
        <Stack align="center">
          <Stack.Item>
            <Button
              icon="undo"
              tooltip="Rotate left"
              onClick={() => act('rotate_preview', { backwards: 1 })}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="redo"
              tooltip="Rotate right"
              onClick={() => act('rotate_preview', { backwards: 0 })}
            />
          </Stack.Item>

          <Stack.Item>
            <Button
              icon="search-minus"
              tooltip="Zoom out"
              disabled={clampedZoom <= PREVIEW_MIN_ZOOM}
              onClick={() => setZoom(clampedZoom - PREVIEW_ZOOM_STEP)}
            />
          </Stack.Item>
          <Stack.Item>
            <Box style={PREVIEW_ZOOM_STYLE} color="label">
              {clampedZoom}%
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="search-plus"
              tooltip="Zoom in"
              disabled={clampedZoom >= PREVIEW_MAX_ZOOM}
              onClick={() => setZoom(clampedZoom + PREVIEW_ZOOM_STEP)}
            />
          </Stack.Item>

          <Stack.Item grow />

          {PREVIEW_MODE_BUTTONS.map((mode) => (
            <Stack.Item key={mode.pref}>
              <Button
                selected={preview_pref === mode.pref}
                icon={mode.icon}
                tooltip={mode.tooltip}
                onClick={() => act('set_preview_pref', { pref: mode.pref })}
              />
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
