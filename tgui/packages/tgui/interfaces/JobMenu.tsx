import { ReactNode, useEffect, useState } from 'react';

import { BooleanLike } from '../../common/react';
import { useBackend } from '../backend';
import { Box, Button, Divider, Section, Stack } from '../components';
import { Window } from '../layouts';
import { JOB_INFO, JOB_INFO_DEFAULT } from './jobInfoData';

type JobEntry = {
  title: string;
  displayTitle?: string;
  command?: BooleanLike;
  current: number;
  total: number;
  /** Приоритет */
  pinned?: BooleanLike;
  /** Причина по которой недоступна строка */
  blocked?: string;
  priority?: number;
  overflow?: BooleanLike;
  locked?: BooleanLike;
  hasAltTitles?: BooleanLike;
};

type Department = {
  name: string;
  color: string;
  jobs: JobEntry[];
};

type RoundInfo = {
  duration?: string;
  alert?: string;
  alertColor?: string;
  shuttle?: string;
};

type JobMenuData = {
  mode?: string;
  selected?: string | null;
  selectedGhost?: string | null;
  preview?: string;
  previewJob?: string;
  departments?: Department[];
  ghostRoles?: string[];
  round?: RoundInfo;
  joblessrole?: string;
  overflowRole?: string;
};

const PRIORITY_LEVELS = [
  { level: 3, label: 'Высокий', color: 'slateblue' },
  { level: 2, label: 'Средний', color: 'green' },
  { level: 1, label: 'Низкий', color: 'orange' },
  { level: 0, label: 'Никогда', color: 'red' },
];

const slotLabel = (job: JobEntry) =>
  `${job.current}/${job.total === -1 ? '∞' : job.total}`;

const tinted = (hex: string, alpha = 0.16) => {
  const match = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex || '');
  if (!match) return 'rgba(255,255,255,0.04)';
  const [r, g, b] = [1, 2, 3].map((i) => parseInt(match[i], 16));
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
};

function splitColumns<T>(items: T[], columns: number, weight: (item: T) => number): T[][] {
  const result: T[][] = [];
  for (let i = 0; i < columns; i++) result.push([]);
  const sizes: number[] = [];
  for (let i = 0; i < columns; i++) sizes.push(0);
  for (const item of items) {
    let index = 0;
    for (let i = 1; i < columns; i++) if (sizes[i] < sizes[index]) index = i;
    result[index].push(item);
    sizes[index] += weight(item);
  }
  return result;
}

const PriorityDots = (props: {
  job: JobEntry;
  onPriority: (title: string, level: number) => void;
}) => {
  const { job, onPriority } = props;
  const locked = !!job.locked;

  const levels = job.overflow
    ? [
        { level: 3, label: 'Да', color: 'green' },
        { level: 0, label: 'Нет', color: 'red' },
      ]
    : PRIORITY_LEVELS;
  const current = job.overflow ? (job.priority ? 3 : 0) : job.priority || 0;

  return (
    <Box style={{ display: 'flex', gap: '3px', alignItems: 'center' }}>
      {levels.map((entry) => {
        const isCurrent = current === entry.level;
        const tooltip = locked
          ? 'Снимите «Да» у резервной роли, чтобы включить остальные профессии'
          : `${entry.label}${isCurrent ? ' · выбран' : ''}`;
        return (
          <Button
            key={entry.level}
            color="transparent"
            tooltip={tooltip}
            tooltipPosition="top"
            style={{
              width: '14px',
              minWidth: '14px',
              height: '14px',
              margin: 0,
              padding: 0,
              borderRadius: '50%',
              border: `2px solid ${entry.color}`,
              background: isCurrent ? entry.color : 'transparent',
              opacity: locked ? 0.5 : 1,
            }}
            onClick={(event) => {
              event.stopPropagation();
              if (locked) return;
              onPriority(job.title, entry.level);
            }}
          />
        );
      })}
    </Box>
  );
};

const JobRow = (props: {
  job: JobEntry;
  mode: string;
  selected: string | null;
  onSelect: (title: string) => void;
  onPriority: (title: string, level: number) => void;
}) => {
  const { job, mode, selected, onSelect, onPriority } = props;
  const displayTitle = job.displayTitle || job.title;
  const altTitle =
    job.displayTitle && job.displayTitle !== job.title ? job.displayTitle : null;
  const isSelected = selected === job.title;

  let rightSide: ReactNode = null;
  let rightColor: string | undefined;

  if (mode === 'latejoin') {
    rightSide = slotLabel(job);
    rightColor = job.pinned ? 'orange' : undefined;
  } else if (!job.blocked) {
    rightSide = <PriorityDots job={job} onPriority={onPriority} />;
  }

  return (
    <Button
      fluid
      color="transparent"
      selected={isSelected}
      style={{
        display: 'block',
        textAlign: 'left',
        fontWeight: job.command ? 700 : 400,
        opacity: job.locked ? 0.6 : 1,
      }}
      onClick={() => onSelect(job.title)}>
      <Box
        style={{
          display: 'flex',
          alignItems: 'baseline',
          gap: '4px',
        }}>
        <Box
          style={{
            flex: '1 1 auto',
            minWidth: 0,
            overflow: 'hidden',
            textOverflow: 'ellipsis',
            whiteSpace: 'nowrap',
          }}>
          {displayTitle}
        </Box>
        <Box style={{ flex: '0 0 auto' }} color={rightColor}>
          {rightSide}
        </Box>
      </Box>
      {altTitle && (
        <Box fontSize="11px" color="#BBBBBB" italic>
          как {altTitle}
        </Box>
      )}
      {job.blocked && (
        <Box fontSize="11px" color="bad" bold>
          {job.blocked}
        </Box>
      )}
    </Button>
  );
};

const Group = (props: { color: string; title: string; children?: ReactNode }) => {
  const { color, title, children } = props;
  return (
    <Box
      as="fieldset"
      style={{
        border: `2px solid ${color}`,
        background: tinted(color),
        margin: '0 0 6px',
        padding: '2px 8px 6px',
        minInlineSize: 0,
        borderRadius: '4px',
      }}>
      <Box
        as="legend"
        px={1}
        style={{ color, fontSize: '12px', fontWeight: 700 }}>
        {title}
      </Box>
      {children}
    </Box>
  );
};

export const JobMenu = () => {
  const { act, data } = useBackend<JobMenuData>();

  const mode = data?.mode || 'latejoin';
  const selected = data?.selected || null;
  const selectedGhost = data?.selectedGhost || null;
  const departments = data?.departments || [];
  const ghostRoles = data?.ghostRoles || [];
  const round = data?.round || {};
  const joblessrole = data?.joblessrole;
  const isLatejoin = mode === 'latejoin';

  const [tab, setTab] = useState<'jobs' | 'ghosts'>('jobs');

  // БЕЙС 64 МОЙ ЛЮБИМЫЙ БОЖЕ
  const [previewCache, setPreviewCache] = useState<Record<string, string>>({});
  useEffect(() => {
    if (data?.preview && data?.previewJob) {
      const job = data.previewJob;
      const image = data.preview;
      setPreviewCache((prev) => ({ ...prev, [job]: image }));
    }
  }, [data?.preview, data?.previewJob]);

  const selectedDept = departments.find((dept) =>
    dept.jobs.some((job) => job.title === selected),
  );
  const selectedJob = selectedDept?.jobs.find(
    (job) => job.title === selected,
  );
  const ghostName = !selected && selectedGhost ? selectedGhost : null;
  const info = (selectedJob && JOB_INFO[selectedJob.title]) || JOB_INFO_DEFAULT;

  const previewImage = selected ? previewCache[selected] : null;

  // Гост-роли уходят в свою вкладку, чтобы не забивать список профессий
  const visibleGroups = isLatejoin
    ? departments.filter((dept) => dept.jobs.length > 0)
    : departments;
  const jobColumns = splitColumns(visibleGroups, 3, (dept) => dept.jobs.length + 1);
  const ghostColumns = splitColumns(ghostRoles, 3, () => 1);

  return (
    <Window width={1000} height={700}>
      <Window.Content>
        <Stack vertical fill>
          {isLatejoin && (
            <Stack.Item shrink={0}>
              <Box
                px={1}
                py={0.5}
                style={{
                  border: '1px solid rgba(255,255,255,0.2)',
                  background: 'rgba(0,0,0,0.25)',
                }}>
                <Stack>
                  <Stack.Item grow basis={0}>
                    Длительность раунда: <b>{round.duration || '—'}</b>
                    {' · '}Уровень тревоги:{' '}
                    <b style={{ color: round.alertColor || undefined }}>
                      {round.alert || '—'}
                    </b>
                    {!!round.shuttle && (
                      <Box color="red" bold>
                        {round.shuttle}
                      </Box>
                    )}
                  </Stack.Item>
                  <Stack.Item shrink={0}>
                    <Button
                      color="transparent"
                      icon="sync"
                      tooltip="Обновить список вакансий"
                      tooltipPosition="bottom-end"
                      onClick={() => act('refresh', {})} />
                  </Stack.Item>
                </Stack>
              </Box>
            </Stack.Item>
          )}

          <Stack.Item grow basis={0} style={{ minHeight: 0 }}>
            <Stack fill>
              {/* Левая колонка вся текстовая информация */}
              <InfoColumn
                selected={selected}
                selectedGhost={selectedGhost}
                selectedJob={selectedJob}
                selectedDept={selectedDept}
                ghostName={ghostName}
                info={info}
                previewImage={previewImage}
                isLatejoin={isLatejoin}
                act={act}
              />

              {/* Правая колонка выбор профессий и приоритетов */}
              <SelectColumn
                mode={mode}
                selected={selected}
                selectedGhost={selectedGhost}
                isLatejoin={isLatejoin}
                tab={tab}
                onTabChange={setTab}
                jobColumns={jobColumns}
                ghostColumns={ghostColumns}
                visibleGroups={visibleGroups}
                ghostRoles={ghostRoles}
                act={act}
              />
            </Stack>
          </Stack.Item>

          {!isLatejoin && (
            <Stack.Item shrink={0}>
              <Section fitted>
                <Stack fill align="center" px={1} py={0.5}>
                  <Stack.Item grow basis={0}>
                    <Button
                      fluid
                      align="center"
                      color="transparent"
                      icon="door-open"
                      style={{ fontWeight: 600 }}
                      tooltip="Что делать, если выбранные профессии не подойдут"
                      tooltipPosition="top"
                      onClick={() => act('joblessrole')}>
                      {joblessrole || 'Что делать, если префы недоступны'}
                    </Button>
                  </Stack.Item>
                  <Stack.Item grow basis={0}>
                    <Button
                      fluid
                      align="center"
                      color="transparent"
                      icon="undo"
                      style={{ fontWeight: 600 }}
                      tooltip="Сбросить все выставленные приоритеты"
                      tooltipPosition="top"
                      onClick={() => act('reset')}>
                      Сбросить приоритеты
                    </Button>
                  </Stack.Item>
                  <Stack.Item shrink={0}>
                    <Button
                      color="transparent"
                      icon="times"
                      tooltip="Закрыть окно"
                      tooltipPosition="top-end"
                      onClick={() => act('close')}>
                      Закрыть
                    </Button>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Левая колонка превью, название, подчинение, описание, кнопки. */
const InfoColumn = (props: {
  selected: string | null;
  selectedGhost: string | null;
  selectedJob?: JobEntry;
  selectedDept?: Department;
  ghostName: string | null;
  info: { summary: string; tasks?: string[]; reports?: string[] };
  previewImage: string | null;
  isLatejoin: boolean;
  act: (action: string, params?: Record<string, unknown>) => void;
}) => {
  const {
    selected,
    selectedGhost,
    selectedJob,
    selectedDept,
    ghostName,
    info,
    previewImage,
    isLatejoin,
    act,
  } = props;

  return (
    <Stack.Item width="300px" shrink={0}>
      <Box
        height="100%"
        style={{ overflowY: 'auto', overflowX: 'hidden', paddingRight: '6px' }}>
        <Box
          px={1}
          py={1}
          style={{
            border: '1px solid rgba(255,255,255,0.2)',
            background: 'rgba(0,0,0,0.25)',
            textAlign: 'center',
          }}>
          {previewImage ? (
            <Box
              as="img"
              width="100%"
              src={`data:image/png;base64,${previewImage}`}
              style={{ imageRendering: 'pixelated' }}
            />
          ) : (
            <Box color="label">
              {ghostName
                ? 'Для гост-роли превью не отображается.'
                : selected
                  ? 'Превью грузится…'
                  : 'Профессия не выбрана.'}
            </Box>
          )}
        </Box>

        {!!selectedJob && (
          <>
            <JobTitle job={selectedJob} dept={selectedDept} act={act} />

            <Box fontSize="11px" color="label">
              Отдел: {selectedDept?.name}
              {selectedJob.command ? ' · Командование' : ''}
            </Box>

            {!!info.reports?.length && (
              <Box fontSize="12px" mt={0.5}>
                Кому подчиняется: <b>{info.reports.join(' → ')}</b>
              </Box>
            )}

            <Divider />

            <Box>{info.summary}</Box>

            {!!info.tasks?.length && (
              <>
                <Box mt={1} bold fontSize="12px">
                  Обязанности
                </Box>
                {info.tasks.map((task) => (
                  <Box key={task} ml={1} fontSize="12px">
                    — {task}
                  </Box>
                ))}
              </>
            )}

            <Divider />

            {isLatejoin && (
              <>
                <Box>
                  Свободные места: <b>{slotLabel(selectedJob)}</b>
                </Box>
                {!!selectedJob.pinned && (
                  <Box color="orange">Приоритетная вакансия</Box>
                )}
                <Button
                  mt={1}
                  fluid
                  color="good"
                  icon="sign-in-alt"
                  content="Присоединиться"
                  onClick={() => act('join', { job: selectedJob.title })}
                />
              </>
            )}
          </>
        )}

        {!!ghostName && (
          <>
            <Box mt={1} fontSize="16px" bold color="#ffffff">
              {ghostName}
            </Box>
            <Box fontSize="11px" color="label">
              Гост-роль · вне штатных профессий
            </Box>
            <Divider />
            <Box fontSize="12px">
              Внеочередная роль вне штатного расписания станции. Вы попадаете в
              неё как призрак, а не через набор экипажа.
            </Box>
            <Button
              mt={1}
              fluid
              color="good"
              icon="sign-in-alt"
              content="Присоединиться"
              onClick={() => act('join_ghost', { spawner: selectedGhost })}
            />
          </>
        )}

        {!selectedJob && !ghostName && (
          <Box color="label" fontSize="12px">
            Выберите профессию в списке справа, чтобы увидеть описание,
            обязанности и цепочку подчинения.
          </Box>
        )}
      </Box>
    </Stack.Item>
  );
};

/** Название профессии динамическое, по клику открывает выбор названия. */
const JobTitle = (props: {
  job: JobEntry;
  dept?: Department;
  act: (action: string, params?: Record<string, unknown>) => void;
}) => {
  const { job, dept, act } = props;
  const title = job.displayTitle || job.title;

  if (!job.hasAltTitles) {
    return (
      <Box mt={1} fontSize="16px" bold color={dept?.color}>
        {title}
      </Box>
    );
  }

  return (
    <Button
      mt={1}
      fluid
      color="transparent"
      icon="pen"
      tooltip="Изменить название должности"
      tooltipPosition="bottom-end"
      style={{
        textAlign: 'left',
        fontSize: '16px',
        fontWeight: 700,
        color: dept?.color,
        padding: '2px 0',
      }}
      onClick={() => act('alt_title', { job: job.title })}>
      {title}
    </Button>
  );
};

/** Правая колонка вкладки и сам список. */
const SelectColumn = (props: {
  mode: string;
  selected: string | null;
  selectedGhost: string | null;
  isLatejoin: boolean;
  tab: 'jobs' | 'ghosts';
  onTabChange: (tab: 'jobs' | 'ghosts') => void;
  jobColumns: Department[][];
  ghostColumns: string[][];
  visibleGroups: Department[];
  ghostRoles: string[];
  act: (action: string, params?: Record<string, unknown>) => void;
}) => {
  const {
    mode,
    selected,
    selectedGhost,
    isLatejoin,
    tab,
    onTabChange,
    jobColumns,
    ghostColumns,
    visibleGroups,
    ghostRoles,
    act,
  } = props;

  const jobCount = visibleGroups.reduce(
    (sum, dept) => sum + dept.jobs.length,
    0,
  );

  return (
    <Stack.Item grow basis={0} style={{ minWidth: 0 }}>
      <Box height="100%" style={{ display: 'flex', flexDirection: 'column' }}>
        {isLatejoin && (
          <Stack shrink={0}>
            <Stack.Item>
              <Button
                icon="briefcase"
                selected={tab === 'jobs'}
                content={`Профессии (${jobCount})`}
                onClick={() => onTabChange('jobs')} />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="user-astronaut"
                selected={tab === 'ghosts'}
                content={`Гост-роли (${ghostRoles.length})`}
                onClick={() => onTabChange('ghosts')} />
            </Stack.Item>
          </Stack>
        )}
        <Box
          mt={isLatejoin ? 1 : 0}
          style={{
            flex: '1 1 auto',
            minHeight: 0,
            overflowY: 'auto',
            overflowX: 'hidden',
          }}>
          {tab === 'jobs' && (
            <JobColumns
              columns={jobColumns}
              empty={visibleGroups.length === 0}
              mode={mode}
              selected={selected}
              act={act}
            />
          )}

          {tab === 'ghosts' &&
            (ghostRoles.length === 0 ? (
              <Box color="red" fontSize="12px">
                В настоящее время нет гост-спавнеров.
              </Box>
            ) : (
              <GhostColumns
                columns={ghostColumns}
                selected={selectedGhost}
                act={act}
              />
            ))}
        </Box>
      </Box>
    </Stack.Item>
  );
};

/** Три колонки со списком профессий. */
const JobColumns = (props: {
  columns: Department[][];
  empty: boolean;
  mode: string;
  selected: string | null;
  act: (action: string, params?: Record<string, unknown>) => void;
}) => {
  const { columns, empty, mode, selected, act } = props;

  if (empty) {
    return (
      <Box color="label" fontSize="12px">
        Нет доступных вакансий.
      </Box>
    );
  }

  return (
    <Stack align="flex-start">
      {columns.map((column, index) => (
        <Stack.Item key={index} grow basis={0} style={{ minWidth: 0 }}>
          {column.map((dept) => (
            <Group key={dept.name} color={dept.color} title={dept.name}>
              {dept.jobs.map((job) => (
                <JobRow
                  key={job.title}
                  job={job}
                  mode={mode}
                  selected={selected}
                  onSelect={(title) => act('select', { job: title })}
                  onPriority={(title, level) =>
                    act('set_priority', { job: title, level })
                  }
                />
              ))}
            </Group>
          ))}
        </Stack.Item>
      ))}
    </Stack>
  );
};

/** Три колонки со списком гост ролей */
const GhostColumns = (props: {
  columns: string[][];
  selected: string | null;
  act: (action: string, params?: Record<string, unknown>) => void;
}) => {
  const { columns, selected, act } = props;

  return (
    <Stack align="flex-start">
      {columns.map((column, index) => (
        <Stack.Item key={index} grow basis={0} style={{ minWidth: 0 }}>
          {column.map((spawner) => (
            <Button
              key={spawner}
              fluid
              color="transparent"
              selected={selected === spawner}
              style={{ textAlign: 'left' }}
              onClick={() => act('select_ghost', { spawner })}>
              {spawner}
            </Button>
          ))}
        </Stack.Item>
      ))}
    </Stack>
  );
};
