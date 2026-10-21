import { type RefObject, useEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';

import { Button, Input } from '../../components';

const PANEL_WIDTH = 190;
const PANEL_HEIGHT = 152;

const clamp = (value: number, min: number, max: number) =>
  Math.min(max, Math.max(min, value));

export const safeHex = (value: string | null | undefined): string => {
  if (!value) {
    return '#000000';
  }
  let hex = value.charAt(0) === '#' ? value.slice(1) : value;
  if (hex.length === 3) {
    hex = hex.replace(/./g, (char) => char + char);
  }
  return /^[0-9a-fA-F]{6}$/.test(hex) ? `#${hex}` : '#000000';
};

export const normalizeHex = (raw: string): string | null => {
  let hex = raw.trim();
  if (hex.charAt(0) === '#') {
    hex = hex.slice(1);
  }
  if (hex.length === 3) {
    hex = hex.replace(/./g, (char) => char + char);
  }
  return /^[0-9a-fA-F]{6}$/.test(hex) ? `#${hex.toLowerCase()}` : null;
};

const hexToHsv = (hex: string): [number, number, number] => {
  const clean = safeHex(hex).slice(1);
  const r = parseInt(clean.slice(0, 2), 16) / 255;
  const g = parseInt(clean.slice(2, 4), 16) / 255;
  const b = parseInt(clean.slice(4, 6), 16) / 255;
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  const delta = max - min;
  let hue = 0;
  if (delta !== 0) {
    if (max === r) {
      hue = 60 * (((g - b) / delta) % 6);
    } else if (max === g) {
      hue = 60 * ((b - r) / delta + 2);
    } else {
      hue = 60 * ((r - g) / delta + 4);
    }
  }
  if (hue < 0) {
    hue += 360;
  }
  return [hue, max === 0 ? 0 : delta / max, max];
};

const hsvToHex = (hue: number, saturation: number, brightness: number) => {
  const chroma = brightness * saturation;
  const sector = hue / 60;
  const mix = chroma * (1 - Math.abs((sector % 2) - 1));
  const base = brightness - chroma;
  let channels: [number, number, number];
  if (sector < 1) {
    channels = [chroma, mix, 0];
  } else if (sector < 2) {
    channels = [mix, chroma, 0];
  } else if (sector < 3) {
    channels = [0, chroma, mix];
  } else if (sector < 4) {
    channels = [0, mix, chroma];
  } else if (sector < 5) {
    channels = [mix, 0, chroma];
  } else {
    channels = [chroma, 0, mix];
  }
  const toByte = (channel: number) =>
    clamp(Math.round((channel + base) * 255), 0, 255)
      .toString(16)
      .padStart(2, '0');
  return `#${toByte(channels[0])}${toByte(channels[1])}${toByte(channels[2])}`;
};

const useDrag = (
  ref: RefObject<HTMLDivElement | null>,
  onPick: (x: number, y: number) => void,
) => {
  const pickRef = useRef(onPick);
  pickRef.current = onPick;
  return (event: React.MouseEvent) => {
    event.preventDefault();
    const node = ref.current;
    if (!node) {
      return;
    }
    const pick = (clientX: number, clientY: number) => {
      const rect = node.getBoundingClientRect();
      pickRef.current(
        clamp((clientX - rect.left) / rect.width, 0, 1),
        clamp((clientY - rect.top) / rect.height, 0, 1),
      );
    };
    pick(event.clientX, event.clientY);
    const move = (e: MouseEvent) => pick(e.clientX, e.clientY);
    const stop = () => {
      window.removeEventListener('mousemove', move);
      window.removeEventListener('mouseup', stop);
    };
    window.addEventListener('mousemove', move);
    window.addEventListener('mouseup', stop);
  };
};

const ColorPanel = (props: {
  value: string;
  left: number;
  top: number;
  onCommit: (hex: string) => void;
  onClose: () => void;
}) => {
  const { value, left, top, onCommit, onClose } = props;
  const [hsv, setHsv] = useState<[number, number, number]>(() =>
    hexToHsv(safeHex(value)),
  );
  const [hue, saturation, brightness] = hsv;
  const hex = hsvToHex(hue, saturation, brightness);
  const [draft, setDraft] = useState(hex);

  const commitRef = useRef(onCommit);
  commitRef.current = onCommit;
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const latest = useRef(hex);
  const dirty = useRef(false);

  const schedule = (next: string) => {
    dirty.current = true;
    latest.current = next;
    setDraft(next);
    if (timer.current) {
      clearTimeout(timer.current);
    }
    timer.current = setTimeout(() => commitRef.current(latest.current), 120);
  };

  useEffect(
    () => () => {
      if (timer.current) {
        clearTimeout(timer.current);
        if (dirty.current) {
          commitRef.current(latest.current);
        }
      }
    },
    [],
  );

  const svRef = useRef<HTMLDivElement>(null);
  const hueRef = useRef<HTMLDivElement>(null);

  const pickSv = useDrag(svRef, (x, y) => {
    const next: [number, number, number] = [hue, x, 1 - y];
    setHsv(next);
    schedule(hsvToHex(next[0], next[1], next[2]));
  });

  const pickHue = useDrag(hueRef, (_x, y) => {
    const next: [number, number, number] = [
      (1 - y) * 360,
      saturation,
      brightness,
    ];
    setHsv(next);
    schedule(hsvToHex(next[0], next[1], next[2]));
  });

  const swatch: React.CSSProperties = {
    flex: '0 0 auto',
    width: '24px',
    height: '20px',
    borderRadius: '2px',
    border: '1px solid rgba(255, 255, 255, 0.3)',
    background: hex,
  };

  return (
    <div
      style={{
        position: 'fixed',
        left,
        top,
        zIndex: 1000,
        width: PANEL_WIDTH,
        padding: '6px',
        borderRadius: '4px',
        border: '1px solid rgba(255, 255, 255, 0.18)',
        background: '#1b1e27',
        boxShadow: '0 6px 16px rgba(0, 0, 0, 0.55)',
        color: '#fff',
        fontFamily: 'Verdana, sans-serif',
        fontSize: '12px',
      }}
    >
      <div style={{ display: 'flex', gap: '6px' }}>
        <div
          ref={svRef}
          onMouseDown={pickSv}
          style={{
            position: 'relative',
            flex: '0 0 auto',
            width: '132px',
            height: '104px',
            cursor: 'crosshair',
            borderRadius: '2px',
            border: '1px solid rgba(0, 0, 0, 0.5)',
            background:
              'linear-gradient(to top, #000, rgba(0,0,0,0)), '
              + 'linear-gradient(to right, #fff, rgba(255,255,255,0)), '
              + `hsl(${hue}, 100%, 50%)`,
          }}
        >
          <div
            style={{
              position: 'absolute',
              left: `${saturation * 100}%`,
              top: `${(1 - brightness) * 100}%`,
              width: '10px',
              height: '10px',
              marginLeft: '-5px',
              marginTop: '-5px',
              borderRadius: '50%',
              border: '2px solid #fff',
              boxShadow: '0 0 3px rgba(0, 0, 0, 0.8)',
              pointerEvents: 'none',
            }}
          />
        </div>
        <div
          ref={hueRef}
          onMouseDown={pickHue}
          style={{
            position: 'relative',
            flex: '0 0 auto',
            width: '16px',
            height: '104px',
            cursor: 'pointer',
            borderRadius: '2px',
            border: '1px solid rgba(0, 0, 0, 0.5)',
            background:
              'linear-gradient(to top, #f00 0%, #ff0 17%, #0f0 33%, '
              + '#0ff 50%, #00f 67%, #f0f 83%, #f00 100%)',
          }}
        >
          <div
            style={{
              position: 'absolute',
              left: '-2px',
              right: '-2px',
              bottom: `${(hue / 360) * 100}%`,
              height: '5px',
              marginTop: '-2px',
              borderRadius: '2px',
              border: '1px solid #fff',
              boxShadow: '0 0 3px rgba(0, 0, 0, 0.8)',
              pointerEvents: 'none',
            }}
          />
        </div>
      </div>
      <div
        style={{ display: 'flex', alignItems: 'center', marginTop: '6px' }}
      >
        <div style={{ flex: '1 1 auto', marginRight: '6px' }}>
          <Input
            width="100%"
            value={draft}
            onInput={(e, next) => setDraft(next)}
            onChange={(e, next) => {
              const normalized = normalizeHex(next);
              if (!normalized) {
                setDraft(hex);
                return;
              }
              setHsv(hexToHsv(normalized));
              schedule(normalized);
            }}
          />
        </div>
        <div style={swatch} />
        <div style={{ flex: '0 0 auto', marginLeft: '6px' }}>
          <Button compact icon="check" tooltip="Закрыть пикер" onClick={onClose} />
        </div>
      </div>
    </div>
  );
};

let panelRoot: HTMLDivElement | null = null;

const getPanelRoot = () => {
  if (!panelRoot) {
    panelRoot = document.createElement('div');
    document.documentElement.appendChild(panelRoot);
  }
  return panelRoot;
};

export const ColorPicker = (props: {
  value: string | null | undefined;
  onCommit: (hex: string) => void;
  tooltip?: string;
  width?: string;
  height?: string;
}) => {
  const { value, onCommit, tooltip, width = '28px', height = '24px' } = props;
  const [open, setOpen] = useState(false);
  const [position, setPosition] = useState({ left: 0, top: 0 });
  const anchorRef = useRef<HTMLDivElement>(null);
  const panelRef = useRef<HTMLDivElement>(null);
  const hex = safeHex(value);

  const toggle = () => {
    const node = anchorRef.current;
    if (node) {
      const rect = node.getBoundingClientRect();
      const gap = 4;
      const left = clamp(
        rect.left,
        4,
        Math.max(4, window.innerWidth - PANEL_WIDTH - 4),
      );
      const below = rect.bottom + gap;
      setPosition({
        left,
        top:
          below + PANEL_HEIGHT > window.innerHeight - 4
            ? Math.max(4, rect.top - gap - PANEL_HEIGHT)
            : below,
      });
    }
    setOpen(!open);
  };

  useEffect(() => {
    if (!open) {
      return;
    }
    const away = (event: Event) => {
      const target = event.target as Node | null;
      if (
        (panelRef.current && target && panelRef.current.contains(target))
        || (anchorRef.current && target && anchorRef.current.contains(target))
      ) {
        return;
      }
      setOpen(false);
    };
    const escape = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        setOpen(false);
      }
    };
    document.addEventListener('mousedown', away);
    document.addEventListener('keydown', escape);
    return () => {
      document.removeEventListener('mousedown', away);
      document.removeEventListener('keydown', escape);
    };
  }, [open]);

  return (
    <>
      <div
        ref={anchorRef}
        title={tooltip || hex}
        onClick={toggle}
        style={{
          display: 'inline-block',
          width,
          height,
          padding: 0,
          cursor: 'pointer',
          border: '1px solid rgba(255, 255, 255, 0.3)',
          borderRadius: '2px',
          background: hex,
          verticalAlign: 'middle',
        }}
      />
      {open
        && createPortal(
          <div
            ref={panelRef}
            style={{ zoom: document.body.style.zoom || '100%' }}
          >
            <ColorPanel
              value={hex}
              left={position.left}
              top={position.top}
              onCommit={onCommit}
              onClose={() => setOpen(false)}
            />
          </div>,
          getPanelRoot(),
        )}
    </>
  );
};
