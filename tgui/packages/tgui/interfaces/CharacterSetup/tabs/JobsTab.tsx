import { useBackend, useLocalState } from '../../../backend';
import {
  Box,
  Button,
  Dropdown,
  Input,
  Section,
  Stack,
  Tooltip,
} from '../../../components';
import { CharacterSetupData, JobInfo } from '../types';
import { sanitizeStringOptions, textOrFallback } from '../utils';

// MARK: Constants
const JP_LOW = 1;
const JP_MEDIUM = 2;
const JP_HIGH = 3;

const BEOVERFLOW = 1;
const BERANDOMJOB = 2;
const RETURNTOLOBBY = 3;

const DEPARTMENT_ORDER = [
  'Command',
  'Security',
  'Engineering',
  'Science',
  'Medical',
  'Supply',
  'Service',
  'Silicon',
  'Law',
  'Other',
];

const DEPARTMENT_COLORS: Record<string, string> = {
  Command: '#4f73d8',
  Security: '#ca4f4f',
  Engineering: '#cf9550',
  Science: '#9f63c9',
  Medical: '#56b0b0',
  Supply: '#b88c4e',
  Service: '#59ab66',
  Silicon: '#b865a0',
  Law: '#8e8e8e',
  Other: '#6f6f6f',
};

const DEPARTMENT_LABELS: Record<string, string> = {
  Command: 'Командование',
  Security: 'Безопасность',
  Engineering: 'Инженерия',
  Science: 'Наука',
  Medical: 'Медицина',
  Supply: 'Снабжение',
  Service: 'Сервис',
  Silicon: 'Силикон',
  Law: 'Юриспруденция',
  Other: 'Прочее',
};

// MARK: Types
type JobCardData = {
  job: JobInfo;
  isLocked: boolean;
  lockReason: string;
};

type JobColumns = [string[], string[], string[]];

// MARK: Helpers
const normalizeText = (text: string) => String(text || '').toLowerCase();

const getJobLockReason = (
  title: string,
  bannedSet: Set<string>,
  blockedSet: Set<string>,
  jobDaysLeft: Record<string, number>,
  jobExpLeft: Record<string, number>,
): string => {
  if (bannedSet.has(title)) {
    return 'Есть бан на эту должность';
  }

  if (blockedSet.has(title)) {
    return 'Недоступно для выбранного вида';
  }

  const daysLeft = jobDaysLeft[title];
  if (daysLeft) {
    return `Нужно ${daysLeft} дн. на сервере`;
  }

  const expLeft = jobExpLeft[title];
  if (expLeft) {
    return `Нужно ${expLeft} ч. наигранного времени`;
  }

  return '';
};

const getLevelAccent = (level: number, isLocked: boolean): string => {
  if (isLocked) {
    return 'rgba(120,120,120,0.12)';
  }

  switch (level) {
    case JP_HIGH:
      return 'rgba(66, 170, 96, 0.18)';
    case JP_MEDIUM:
      return 'rgba(210, 173, 70, 0.18)';
    case JP_LOW:
      return 'rgba(190, 93, 93, 0.18)';
    default:
      return 'rgba(255,255,255,0.02)';
  }
};

const splitDepartmentsIntoColumns = (
  departments: string[],
  jobsByDept: Record<string, JobCardData[]>,
): JobColumns => {
  const columns: JobColumns = [[], [], []];
  const loads = [0, 0, 0];

  for (const dept of departments) {
    const nextColumn = loads.indexOf(Math.min(...loads));
    columns[nextColumn].push(dept);
    loads[nextColumn] += jobsByDept[dept]?.length || 0;
  }

  return columns;
};

// MARK: Root
export const JobsTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);
  const {
    jobs_info = [],
    job_preferences = {},
    joblessrole = RETURNTOLOBBY,
    alt_titles_preferences = {},
    job_bans = [],
    job_days_left = {},
    job_exp_left = {},
    job_species_blocked = [],
    overflow_role = 'Assistant',
  } = data;

  const [search, setSearch] = useLocalState(context, 'jobs_search', '');
  const [hideLocked, setHideLocked] = useLocalState(context, 'jobs_hide_locked', false);

  const bannedSet = new Set(job_bans);
  const blockedSet = new Set(job_species_blocked);
  const searchText = normalizeText(search).trim();

  const jobsByDept: Record<string, JobCardData[]> = {};
  for (const job of jobs_info) {
    const lockReason = getJobLockReason(
      job.title,
      bannedSet,
      blockedSet,
      job_days_left,
      job_exp_left,
    );

    const isLocked = lockReason.length > 0;
    if (hideLocked && isLocked) {
      continue;
    }

    const matchesSearch = !searchText
      || normalizeText(job.title).includes(searchText)
      || (job.alt_titles || []).some((alt) => normalizeText(alt).includes(searchText));

    if (!matchesSearch) {
      continue;
    }

    if (!jobsByDept[job.department]) {
      jobsByDept[job.department] = [];
    }

    jobsByDept[job.department].push({
      job,
      isLocked,
      lockReason,
    });
  }

  for (const deptName in jobsByDept) {
    jobsByDept[deptName].sort((a, b) => a.job.display_order - b.job.display_order);
  }

  const departments = DEPARTMENT_ORDER.filter((dept) => (jobsByDept[dept] || []).length > 0);
  const columns = splitDepartmentsIntoColumns(departments, jobsByDept);

  const selectedLow = Object.values(job_preferences).filter((level) => level === JP_LOW).length;
  const selectedMedium = Object.values(job_preferences).filter((level) => level === JP_MEDIUM).length;
  const selectedHigh = Object.values(job_preferences).filter((level) => level === JP_HIGH).length;

  return (
    <Stack vertical fill>
      {/* MARK: Control Panel */}
      <Stack.Item>
        <Section title="Настройки должностей">
          <Stack vertical>
            <Stack.Item>
              <Box color="label" mb={0.5}>
                Если ни одна выбранная должность не доступна:
              </Box>
              <Stack>
                <Stack.Item>
                  <Button
                    selected={joblessrole === RETURNTOLOBBY}
                    content="Вернуться в лобби"
                    onClick={() => act('set_jobless_role', { role: RETURNTOLOBBY })}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    selected={joblessrole === BEOVERFLOW}
                    content={textOrFallback(overflow_role, 'Assistant')}
                    onClick={() => act('set_jobless_role', { role: BEOVERFLOW })}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    selected={joblessrole === BERANDOMJOB}
                    icon="dice"
                    content="Случайная работа"
                    onClick={() => act('set_jobless_role', { role: BERANDOMJOB })}
                  />
                </Stack.Item>
                <Stack.Item grow />
                <Stack.Item>
                  <Button
                    icon="undo"
                    content="Сбросить все приоритеты"
                    color="red"
                    onClick={() => act('reset_jobs')}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>

            <Stack.Item>
              <Stack>
                <Stack.Item grow>
                  <Input
                    fluid
                    placeholder="Поиск по должностям и альтернативным названиям"
                    value={search}
                    onInput={(e, value) => setSearch(String(value || ''))}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon={hideLocked ? 'eye' : 'eye-slash'}
                    content={hideLocked ? 'Показывать заблокированные' : 'Скрывать заблокированные'}
                    selected={hideLocked}
                    onClick={() => setHideLocked(!hideLocked)}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>

            <Stack.Item>
              <Stack align="center">
                <Stack.Item>
                  <Box color="label">Высокий: {selectedHigh}</Box>
                </Stack.Item>
                <Stack.Item>
                  <Box color="label">Средний: {selectedMedium}</Box>
                </Stack.Item>
                <Stack.Item>
                  <Box color="label">Низкий: {selectedLow}</Box>
                </Stack.Item>
                <Stack.Item grow />
                <Stack.Item>
                  <Box color="label">3 колонки, отделы сбалансированы по количеству должностей</Box>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* MARK: Departments Grid */}
      <Stack.Item grow>
        {!departments.length ? (
          <Section fill>
            <Box color="label" italic>
              Ничего не найдено по текущему фильтру.
            </Box>
          </Section>
        ) : (
          <Stack fill align="stretch">
            {columns.map((columnDepartments, columnIndex) => (
              <Stack.Item key={`jobs-column-${columnIndex}`} grow basis={0}>
                <Stack vertical>
                  {columnDepartments.map((department) => (
                    <Stack.Item key={department}>
                      <DepartmentSection
                        department={department}
                        jobs={jobsByDept[department] || []}
                        overflowRole={overflow_role}
                        jobPreferences={job_preferences}
                        altTitles={alt_titles_preferences}
                        onSetLevel={(jobTitle, level) =>
                          act('set_job_priority', {
                            job_title: jobTitle,
                            level,
                          })
                        }
                        onSetAltTitle={(jobTitle, altTitle) =>
                          act('set_alt_title', {
                            job_title: jobTitle,
                            alt_title: altTitle,
                          })
                        }
                      />
                    </Stack.Item>
                  ))}
                </Stack>
              </Stack.Item>
            ))}
          </Stack>
        )}
      </Stack.Item>
    </Stack>
  );
};

// MARK: Department Section
const DepartmentSection = (props: {
  department: string;
  jobs: JobCardData[];
  overflowRole: string;
  jobPreferences: Record<string, number>;
  altTitles: Record<string, string>;
  onSetLevel: (jobTitle: string, level: number) => void;
  onSetAltTitle: (jobTitle: string, altTitle: string) => void;
}) => {
  const {
    department,
    jobs,
    overflowRole,
    jobPreferences,
    altTitles,
    onSetLevel,
    onSetAltTitle,
  } = props;

  const deptColor = DEPARTMENT_COLORS[department] || '#6f6f6f';
  const deptLabel = DEPARTMENT_LABELS[department] || department;

  return (
    <Section
      title={
        <Box
          inline
          style={{
            borderBottom: `2px solid ${deptColor}`,
            paddingBottom: '2px',
          }}>
          {deptLabel} ({jobs.length})
        </Box>
      }>
      <Stack vertical>
        {jobs.map(({ job, isLocked, lockReason }) => (
          <Stack.Item key={job.title}>
            <JobCard
              job={job}
              level={jobPreferences[job.title] || 0}
              altTitle={altTitles[job.title]}
              isLocked={isLocked}
              lockReason={lockReason}
              isOverflow={job.title === overflowRole}
              deptColor={deptColor}
              onSetLevel={(level) => onSetLevel(job.title, level)}
              onSetAltTitle={(title) => onSetAltTitle(job.title, title)}
            />
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

// MARK: Job Card
const JobCard = (props: {
  job: JobInfo;
  level: number;
  altTitle?: string;
  isLocked: boolean;
  lockReason: string;
  isOverflow: boolean;
  deptColor: string;
  onSetLevel: (level: number) => void;
  onSetAltTitle: (title: string) => void;
}) => {
  const {
    job,
    level,
    altTitle,
    isLocked,
    lockReason,
    isOverflow,
    deptColor,
    onSetLevel,
    onSetAltTitle,
  } = props;

  const hasAltTitles = !!job.alt_titles?.length;
  const altTitleOptions = sanitizeStringOptions([job.title, ...(job.alt_titles || [])]);
  const selectedAltTitle = textOrFallback(altTitle, textOrFallback(job.title, 'Unknown Job'));

  return (
    <Box
      style={{
        padding: '6px',
        borderRadius: '4px',
        borderLeft: `3px solid ${job.is_head ? deptColor : 'rgba(255,255,255,0.08)'}`,
        background: getLevelAccent(level, isLocked),
      }}>
      <Stack vertical>
        <Stack.Item>
          <Stack align="center">
            <Stack.Item grow>
              <Box
                bold={job.is_head}
                color={isLocked ? 'label' : 'default'}
                style={job.is_head && !isLocked ? { color: deptColor } : undefined}>
                {selectedAltTitle}
              </Box>
              {altTitle && altTitle !== job.title && (
                <Box color="label" fontSize="11px">
                  Базовая должность: {job.title}
                </Box>
              )}
            </Stack.Item>

            <Stack.Item>
              {isLocked ? (
                <Tooltip content={lockReason || 'Недоступно'}>
                  <Button compact icon="lock" color="transparent" disabled />
                </Tooltip>
              ) : (
                <PrioritySelector
                  level={level}
                  isOverflow={isOverflow}
                  onSetLevel={onSetLevel}
                />
              )}
            </Stack.Item>
          </Stack>
        </Stack.Item>

        {isLocked && (
          <Stack.Item>
            <Box color="bad" fontSize="11px">
              {lockReason}
            </Box>
          </Stack.Item>
        )}

        {hasAltTitles && !isLocked && (
          <Stack.Item>
            <Dropdown
              width="100%"
              selected={selectedAltTitle}
              options={altTitleOptions}
              onSelected={(value) => onSetAltTitle(value)}
            />
          </Stack.Item>
        )}
      </Stack>
    </Box>
  );
};

// MARK: Priority Controls
const PrioritySelector = (props: {
  level: number;
  isOverflow: boolean;
  onSetLevel: (level: number) => void;
}) => {
  const { level, isOverflow, onSetLevel } = props;

  if (isOverflow) {
    const enabled = level === JP_LOW;
    return (
      <Stack>
        <Stack.Item>
          <Button
            compact
            selected={!enabled}
            content="Выкл"
            onClick={() => onSetLevel(0)}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            compact
            selected={enabled}
            color={enabled ? 'green' : undefined}
            content="Исп."
            onClick={() => onSetLevel(JP_LOW)}
          />
        </Stack.Item>
      </Stack>
    );
  }

  return (
    <Stack>
      <Stack.Item>
        <Button
          compact
          selected={level === 0}
          content="Выкл"
          onClick={() => onSetLevel(0)}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          compact
          selected={level === JP_LOW}
          color={level === JP_LOW ? 'red' : undefined}
          content="Низ"
          onClick={() => onSetLevel(JP_LOW)}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          compact
          selected={level === JP_MEDIUM}
          color={level === JP_MEDIUM ? 'yellow' : undefined}
          content="Сред"
          onClick={() => onSetLevel(JP_MEDIUM)}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          compact
          selected={level === JP_HIGH}
          color={level === JP_HIGH ? 'green' : undefined}
          content="Выс"
          onClick={() => onSetLevel(JP_HIGH)}
        />
      </Stack.Item>
    </Stack>
  );
};
