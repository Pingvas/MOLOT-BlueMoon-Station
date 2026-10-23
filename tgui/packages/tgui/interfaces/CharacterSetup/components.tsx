import { useState } from 'react';

import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Dropdown,
  Input,
  NoticeBox,
  NumberInput,
  Stack,
  TextArea,
} from '../../components';
import { ColorPicker, normalizeHex, safeHex } from './ColorPicker';

const textTimers = new Map<HTMLTextAreaElement, ReturnType<typeof setTimeout>>();

const commitText = (
  element: HTMLTextAreaElement,
  commit: (value: string) => void,
) => {
  clearTimeout(textTimers.get(element));
  textTimers.set(element, setTimeout(() => commit(element.value), 600));
};

export const TabDataMissing = (props: { title: string }) => (
  <NoticeBox>
    Сервер ещё не прислал данные вкладки «{props.title}». Если сообщение не
    пропадает - обновите окно и проверьте лог сервера на runtime-ошибки.
  </NoticeBox>
);

export type SelectOption =
  | string
  | { value: string | number; label?: string; displayText?: string };

export type ActParams = Record<string, string | number | boolean>;

export const FieldRow = (props: {
  label: string;
  tooltip?: string;
  labelBasis?: string;
  children: React.ReactNode;
}) => {
  const { label, tooltip, labelBasis, children } = props;
  return (
    <Stack align="center" mb={1}>
      <Stack.Item basis={labelBasis || '48%'}>
        <Box title={tooltip}>{label}</Box>
      </Stack.Item>
      <Stack.Item grow>
        <Box
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'flex-end',
            width: '100%',
          }}
        >
          {children}
        </Box>
      </Stack.Item>
    </Stack>
  );
};

export const ColorField = (props: {
  label: string;
  value: string | null | undefined;
  action?: string;
  params?: ActParams;
  disabled?: boolean;
  disabledNote?: string;
  tooltip?: string;
  labelBasis?: string;
}) => {
  const { act } = useBackend<any>();
  const {
    label,
    value,
    action,
    params,
    disabled,
    disabledNote,
    tooltip,
    labelBasis,
  } = props;
  const [draft, setDraft] = useState<string | null>(null);
  const hex = safeHex(value);

  if (disabled) {
    return (
      <FieldRow label={label} tooltip={tooltip} labelBasis={labelBasis}>
        <Box color="label">{disabledNote || 'выключено'}</Box>
      </FieldRow>
    );
  }

  if (!action) {
    return null;
  }

  return (
    <FieldRow label={label} tooltip={tooltip} labelBasis={labelBasis}>
      <Box
        style={{ display: 'flex', alignItems: 'center', width: '100%' }}
        onBlur={() => setDraft(null)}
      >
        <Stack align="center" style={{ width: '100%' }}>
          <Stack.Item>
            <ColorPicker
              value={hex}
              tooltip={`Пикер цвета: ${hex}`}
              onCommit={(next) => act(action, { ...params, color: next })}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Input
              width="100%"
              placeholder="#rrggbb"
              value={draft ?? hex}
              onInput={(e, next) => setDraft(next)}
              onChange={(e, next) => {
                const normalized = normalizeHex(next);
                setDraft(null);
                if (normalized) {
                  act(action, { ...params, color: normalized });
                }
              }}
            />
          </Stack.Item>
        </Stack>
      </Box>
    </FieldRow>
  );
};

export const ColorChip = (props: {
  value: string | null | undefined;
  action: string;
  params?: ActParams;
  tooltip?: string;
}) => {
  const { act } = useBackend<any>();
  const { value, action, params, tooltip } = props;
  return (
    <ColorPicker
      value={value}
      tooltip={tooltip}
      width="30px"
      height="20px"
      onCommit={(next) => act(action, { ...params, color: next })}
    />
  );
};

export const ToggleRow = (props: {
  label: string;
  value: boolean;
  action: string;
  params?: ActParams;
  onLabel?: string;
  offLabel?: string;
  tooltip?: string;
  labelBasis?: string;
}) => {
  const { act } = useBackend<any>();
  const {
    label,
    value,
    action,
    params,
    onLabel = 'Да',
    offLabel = 'Нет',
    tooltip,
    labelBasis,
  } = props;
  return (
    <FieldRow label={label} tooltip={tooltip} labelBasis={labelBasis}>
      <Button
        selected={!!value}
        content={value ? onLabel : offLabel}
        onClick={() => (params ? act(action, params) : act(action))}
      />
    </FieldRow>
  );
};

export const asOptions = (source: unknown): SelectOption[] => {
  if (Array.isArray(source)) {
    return source as SelectOption[];
  }
  if (source && typeof source === 'object') {
    return Object.entries(source as Record<string, string | number>).map(
      ([value, label]) => ({ value, displayText: `${label}` }),
    );
  }
  return [];
};

const normalizeOptions = (
  options: unknown,
): (string | { value: string | number; displayText: string })[] =>
  asOptions(options).map((option) => {
    if (typeof option === 'string') {
      return option;
    }
    return {
      value: option.value,
      displayText: option.displayText || option.label || `${option.value}`,
    };
  });

export const SelectRow = (props: {
  label: string;
  value: string | number | null | undefined;
  options: SelectOption[];
  action: string;
  params?: ActParams;
  width?: string;
  tooltip?: string;
  labelBasis?: string;
  extra?: React.ReactNode;
}) => {
  const { act } = useBackend<any>();
  const {
    label,
    value,
    options,
    action,
    params,
    width,
    tooltip,
    labelBasis,
    extra,
  } = props;
  const dropdown = (
    <Dropdown
      width={width || '100%'}
      options={normalizeOptions(options || [])}
      selected={value}
      onSelected={(next) => act(action, { ...params, value: next })}
    />
  );
  return (
    <FieldRow label={label} tooltip={tooltip} labelBasis={labelBasis}>
      {extra ? (
        <Stack align="center" style={{ width: '100%' }}>
          <Stack.Item grow>{dropdown}</Stack.Item>
          <Stack.Item>{extra}</Stack.Item>
        </Stack>
      ) : (
        dropdown
      )}
    </FieldRow>
  );
};

export const TextRow = (props: {
  label: string;
  value: string | null | undefined;
  action: string;
  width?: string;
  tooltip?: string;
  labelBasis?: string;
}) => {
  const { act } = useBackend<any>();
  const { label, value, action, width, tooltip, labelBasis } = props;
  return (
    <FieldRow label={label} tooltip={tooltip} labelBasis={labelBasis}>
      <Input
        width={width || '100%'}
        value={value || ''}
        onChange={(e, next) => act(action, { value: next })}
      />
    </FieldRow>
  );
};

export const TextAreaRow = (props: {
  label: string;
  value: string | null | undefined;
  action: string;
  height?: string;
  maxLength?: number;
  tooltip?: string;
  placeholder?: string;
  editField?: string;
}) => {
  const { act } = useBackend<any>();
  const {
    label,
    value,
    action,
    height,
    maxLength,
    tooltip,
    placeholder,
    editField,
  } = props;
  const [expanded, setExpanded] = useState(false);
  return (
    <Box mb={1}>
      <Stack align="center" mb={1}>
        <Stack.Item grow>
          <Box title={tooltip}>{label}</Box>
        </Stack.Item>
        {editField && (
          <Stack.Item>
            <Button
              compact
              icon="window-maximize"
              tooltip="Редактировать в отдельном окне"
              onClick={() => act('edit_text', { field: editField })}
            />
          </Stack.Item>
        )}
        <Stack.Item>
          <Button
            compact
            icon={expanded ? 'compress' : 'expand'}
            tooltip={expanded ? 'Свернуть редактор' : 'Развернуть редактор'}
            onClick={() => setExpanded(!expanded)}
          />
        </Stack.Item>
      </Stack>
      {expanded && !!tooltip && (
        <Box color="label" mb={1}>
          <b>Формат описания:</b> {tooltip}
        </Box>
      )}
      <TextArea
        fluid
        scrollbar
        height={expanded ? '400px' : height || '110px'}
        maxLength={maxLength}
        placeholder={placeholder}
        value={value || ''}
        onInput={(e) =>
          commitText(e.target as HTMLTextAreaElement, (next) =>
            act(action, { text: next }),
          )
        }
      />
    </Box>
  );
};

export interface FeatureField {
  key: string;
  label: string;
  type: 'bool' | 'num' | 'list' | 'color' | 'cycle' | 'reagent';
  scope: string;
  hint?: string;
  min?: number;
  max?: number;
  step?: number;
  scale?: number;
  options?: unknown;
  colorCheck?: string;
  deletable?: boolean;
  zeroLabel?: string;
  clampTo?: string;
  clampAbove?: boolean;
  clampBelow?: boolean;
}

export function asArray<T>(value: T[] | undefined | null): T[] {
  return Array.isArray(value) ? (value as T[]) : [];
}

const asReagentOptions = (source: unknown): SelectOption[] => {
  if (!Array.isArray(source)) {
    return [];
  }
  return source.map((option) => {
    const fluid = option as { name?: string; type?: string };
    return { value: fluid.type || '', displayText: fluid.name || '' };
  });
};

export const FeatureFieldView = (props: {
  field: FeatureField;
  value: unknown;
}) => {
  const { act } = useBackend<any>();
  const { field, value } = props;

  if (field.type === 'bool') {
    return (
      <ToggleRow
        label={field.label}
        tooltip={field.hint}
        value={!!value}
        action="set_feature"
        params={{ key: field.key, value: !value }}
      />
    );
  }

  if (field.type === 'color') {
    return (
      <ColorField
        label={field.label}
        tooltip={field.hint}
        value={value as string}
        action="set_feature"
        params={{ key: field.key }}
      />
    );
  }

  if (field.type === 'num') {
    const empty = field.deletable && !(value as number);
    return (
      <FieldRow label={field.label} tooltip={field.hint}>
        <Stack align="center" style={{ width: '100%' }}>
          <Stack.Item grow>
            <NumberInput
              width="100%"
              step={field.step || 1}
              value={(value as number) || 0}
              minValue={field.min}
              maxValue={field.max}
              onChange={(e, next) =>
                act('set_feature', { key: field.key, value: next })
              }
            />
          </Stack.Item>
          {empty && (
            <Stack.Item>
              <Box color="label">{field.zeroLabel || 'отключено'}</Box>
            </Stack.Item>
          )}
        </Stack>
      </FieldRow>
    );
  }

  if (field.type === 'reagent') {
    return (
      <SelectRow
        label={field.label}
        tooltip={field.hint}
        value={value as string}
        options={asReagentOptions(field.options)}
        action="set_feature"
        params={{ key: field.key }}
      />
    );
  }

  const listOptions = asOptions(field.options);
  if (field.deletable) {
    listOptions.unshift({
      value: '',
      displayText: field.zeroLabel || 'Отключено',
    });
  }
  return (
    <SelectRow
      label={field.label}
      tooltip={field.hint}
      value={
        field.deletable && !value ? ('' as string) : (value as string | number)
      }
      options={listOptions}
      action="set_feature"
      params={{ key: field.key }}
    />
  );
};

export const renderFeatureField = (
  fields: FeatureField[],
  values: Record<string, unknown>,
  key: string,
) => {
  const field = fields.find((entry) => entry.key === key);
  if (!field) {
    return null;
  }
  return <FeatureFieldView key={key} field={field} value={values[key]} />;
};
