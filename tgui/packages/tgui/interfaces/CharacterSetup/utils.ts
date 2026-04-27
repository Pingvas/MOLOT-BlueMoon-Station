// MARK: Value Sanitizers
const normalize = (value: unknown): string => String(value ?? '').trim();

export const isJunkValue = (value: unknown): boolean => {
  if (value === null || value === undefined) {
    return true;
  }

  if (typeof value === 'number') {
    return value === 0;
  }

  const text = normalize(value).toLowerCase();
  return text.length === 0 || text === '0' || text === 'null' || text === 'undefined';
};

export const textOrFallback = (value: unknown, fallback: string): string =>
  isJunkValue(value) ? fallback : normalize(value);

export const sanitizeStringOptions = (options: unknown[] = []): string[] =>
  options
    .map((option) => normalize(option))
    .filter((option) => !isJunkValue(option));

export const resolveOptionValue = (
  value: unknown,
  options: unknown[] = [],
  fallback = '',
): string => {
  const safeOptions = sanitizeStringOptions(options);
  const normalizedValue = normalize(value);
  if (!isJunkValue(normalizedValue) && safeOptions.includes(normalizedValue)) {
    return normalizedValue;
  }
  return safeOptions[0] || fallback;
};
