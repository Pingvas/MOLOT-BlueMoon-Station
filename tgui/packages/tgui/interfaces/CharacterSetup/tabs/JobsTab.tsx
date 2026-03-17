import { useBackend } from '../../../backend';
import {
  Box,
  Button,
  Dropdown,
  Section,
  Stack,
  Tooltip,
} from '../../../components';
import { CharacterSetupData, JobInfo } from '../types';

// Job priority levels matching DM defines
const JP_LOW = 1;
const JP_MEDIUM = 2;
const JP_HIGH = 3;

// Jobless role defines
const BEOVERFLOW = 1;
const BERANDOMJOB = 2;
const RETURNTOLOBBY = 3;

// Department display order and colors
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
  Command: '#4466cc',
  Security: '#cc4444',
  Engineering: '#cc8833',
  Science: '#9944cc',
  Medical: '#44aaaa',
  Supply: '#aa8844',
  Service: '#44aa44',
  Silicon: '#cc66aa',
  Law: '#888888',
  Other: '#666666',
};

const DEPARTMENT_LABELS: Record<string, string> = {
  Command: 'Командование',
  Security: 'Служба безопасности',
  Engineering: 'Инженерный отдел',
  Science: 'Научный отдел',
  Medical: 'Медицинский отдел',
  Supply: 'Отдел снабжения',
  Service: 'Сервисный отдел',
  Silicon: 'Силикон',
  Law: 'Юридический',
  Other: 'Прочее',
};

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

  const bannedSet = new Set(job_bans);
  const blockedSet = new Set(job_species_blocked);

  // Group jobs by department from jobs_info
  const jobsByDept: Record<string, JobInfo[]> = {};
  for (const job of jobs_info) {
    if (!jobsByDept[job.department]) {
      jobsByDept[job.department] = [];
    }
    jobsByDept[job.department].push(job);
  }

  // Filter and order departments
  const departments = DEPARTMENT_ORDER.filter(
    (dept) => jobsByDept[dept] && jobsByDept[dept].length > 0,
  );

  return (
    <Stack vertical>
      {/* Jobless role + reset */}
      <Stack.Item>
        <Section title="Общие настройки">
          <Stack align="center">
            <Stack.Item grow>
              <Box inline bold mr={1}>
                Если ни одна работа не доступна:
              </Box>
              <Button
                selected={joblessrole === RETURNTOLOBBY}
                content="Вернуться в лобби"
                onClick={() =>
                  act('set_jobless_role', { role: RETURNTOLOBBY })
                }
              />
              <Button
                selected={joblessrole === BEOVERFLOW}
                content={overflow_role}
                onClick={() =>
                  act('set_jobless_role', { role: BEOVERFLOW })
                }
              />
              <Button
                selected={joblessrole === BERANDOMJOB}
                content="Случайная работа"
                onClick={() =>
                  act('set_jobless_role', { role: BERANDOMJOB })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="undo"
                content="Сбросить всё"
                color="red"
                onClick={() => act('reset_jobs')}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* Department sections */}
      {departments.map((dept) => {
        const deptJobs = (jobsByDept[dept] || [])
          .sort((a, b) => a.display_order - b.display_order);

        if (deptJobs.length === 0) {
          return null;
        }

        return (
          <Stack.Item key={dept}>
            <Section
              title={
                <Box
                  inline
                  style={{
                    borderBottom: `2px solid ${DEPARTMENT_COLORS[dept] || '#666'}`,
                    paddingBottom: '2px',
                  }}>
                  {DEPARTMENT_LABELS[dept] || dept}
                </Box>
              }>
              <Stack vertical>
                {deptJobs.map((job) => {
                  const isBanned = bannedSet.has(job.title);
                  const isBlocked = blockedSet.has(job.title);
                  const daysLeft = job_days_left[job.title];
                  const expLeft = job_exp_left[job.title];
                  const isLocked = isBanned || isBlocked || !!daysLeft || !!expLeft;
                  const currentLevel = job_preferences[job.title] || 0;
                  const isOverflow = job.title === overflow_role;

                  let lockReason = '';
                  if (isBanned) {
                    lockReason = 'Забанено';
                  } else if (isBlocked) {
                    lockReason = 'Недоступно для вашего вида';
                  } else if (daysLeft) {
                    lockReason = `Нужно ${daysLeft} дн. на сервере`;
                  } else if (expLeft) {
                    lockReason = `Нужно ${expLeft} ч. наигранного`;
                  }

                  return (
                    <Stack.Item key={job.title}>
                      <JobRow
                        job={job}
                        level={currentLevel}
                        isLocked={isLocked}
                        lockReason={lockReason}
                        isOverflow={isOverflow}
                        deptColor={DEPARTMENT_COLORS[dept] || '#666'}
                        altTitle={alt_titles_preferences[job.title]}
                        onSetLevel={(level) =>
                          act('set_job_priority', {
                            job_title: job.title,
                            level,
                          })
                        }
                        onSetAltTitle={(title) =>
                          act('set_alt_title', {
                            job_title: job.title,
                            alt_title: title,
                          })
                        }
                      />
                    </Stack.Item>
                  );
                })}
              </Stack>
            </Section>
          </Stack.Item>
        );
      })}
    </Stack>
  );
};

// Individual job row
type JobRowProps = {
  job: JobInfo;
  level: number;
  isLocked: boolean;
  lockReason: string;
  isOverflow: boolean;
  deptColor: string;
  altTitle?: string;
  onSetLevel: (level: number) => void;
  onSetAltTitle: (title: string) => void;
};

const JobRow = (props: JobRowProps) => {
  const {
    job,
    level,
    isLocked,
    lockReason,
    isOverflow,
    deptColor,
    altTitle,
    onSetLevel,
    onSetAltTitle,
  } = props;

  const displayTitle = altTitle || job.title;
  const hasAltTitles = job.alt_titles && job.alt_titles.length > 0;

  return (
    <Box
      style={{
        padding: '4px 6px',
        marginBottom: '2px',
        background: level > 0 ? 'rgba(255,255,255,0.05)' : 'transparent',
        borderLeft: `3px solid ${job.is_head ? deptColor : 'transparent'}`,
        borderRadius: '2px',
      }}>
      <Stack align="center">
        {/* Job title */}
        <Stack.Item grow>
          <Box
            inline
            bold={job.is_head}
            color={isLocked ? 'label' : 'default'}
            style={job.is_head ? { color: deptColor } : undefined}>
            {displayTitle}
            {altTitle && (
              <Box inline color="label" ml={1} fontSize="11px">
                ({job.title})
              </Box>
            )}
          </Box>
          {isLocked && (
            <Box color="bad" fontSize="11px">
              {lockReason}
            </Box>
          )}
        </Stack.Item>

        {/* Alt title selector */}
        {hasAltTitles && !isLocked && (
          <Stack.Item>
            <Dropdown
              width="140px"
              selected={altTitle || job.title}
              options={[job.title, ...job.alt_titles]}
              onSelected={(val) => onSetAltTitle(val)}
            />
          </Stack.Item>
        )}

        {/* Priority buttons */}
        <Stack.Item>
          {isLocked ? (
            <Box inline color="label" fontSize="12px">
              <Tooltip content={lockReason}>
                <Button
                  icon="lock"
                  color="transparent"
                  disabled
                />
              </Tooltip>
            </Box>
          ) : isOverflow ? (
            // Overflow role: only toggle on/off
            <Button
              selected={level === JP_LOW}
              content={level === JP_LOW ? 'Да' : 'Нет'}
              color={level === JP_LOW ? 'green' : undefined}
              onClick={() => onSetLevel(level === JP_LOW ? 0 : JP_LOW)}
            />
          ) : (
            // Normal job: Off / Low / Medium / High
            <Stack>
              <Stack.Item>
                <PriorityButton
                  label="Выкл"
                  active={level === 0}
                  color={undefined}
                  onClick={() => onSetLevel(0)}
                />
              </Stack.Item>
              <Stack.Item>
                <PriorityButton
                  label="Низ"
                  active={level === JP_LOW}
                  color="red"
                  onClick={() => onSetLevel(JP_LOW)}
                />
              </Stack.Item>
              <Stack.Item>
                <PriorityButton
                  label="Сред"
                  active={level === JP_MEDIUM}
                  color="yellow"
                  onClick={() => onSetLevel(JP_MEDIUM)}
                />
              </Stack.Item>
              <Stack.Item>
                <PriorityButton
                  label="Выс"
                  active={level === JP_HIGH}
                  color="green"
                  onClick={() => onSetLevel(JP_HIGH)}
                />
              </Stack.Item>
            </Stack>
          )}
        </Stack.Item>
      </Stack>
    </Box>
  );
};

// Priority button — small circle/pill style
type PriorityButtonProps = {
  label: string;
  active: boolean;
  color?: string;
  onClick: () => void;
};

const PriorityButton = (props: PriorityButtonProps) => {
  const { label, active, color, onClick } = props;

  return (
    <Button
      compact
      selected={active}
      color={active ? color : undefined}
      content={label}
      onClick={onClick}
      style={{
        minWidth: '40px',
        textAlign: 'center',
      }}
    />
  );
};
