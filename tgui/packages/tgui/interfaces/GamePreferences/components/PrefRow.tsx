import { Button, Stack } from '../../../components';

type PrefRowProps = {
  label: string;
  checked?: boolean;
  onClick: () => void;
  hint?: string;
};

export const PrefRow = (props: PrefRowProps) => {
  const { label, checked, onClick, hint } = props;

  return (
    <Stack.Item>
      <Stack align="center" fill className="GamePreferences__row">
        <Stack.Item grow basis={0}>
          <div className="GamePreferences__label">{label}</div>
          {hint && (
            <div className="GamePreferences__hint">{hint}</div>
          )}
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={checked ? 'toggle-on' : 'toggle-off'}
            selected={checked}
            color={checked ? 'good' : 'default'}
            onClick={onClick}
          />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

export const CONSENT_OPTIONS = [
  { value: 'Yes', label: 'Да' },
  { value: 'Ask', label: 'Спросить' },
  { value: 'No', label: 'Нет' },
];
