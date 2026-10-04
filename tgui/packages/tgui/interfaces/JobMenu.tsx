import { ReactNode, useEffect, useState } from 'react';

import { BooleanLike } from '../../common/react';
import { useBackend } from '../backend';
import { Box, Button, Divider, NoticeBox, Section, Stack } from '../components';
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

const priorityMeta = (level?: number) =>
  PRIORITY_LEVELS.find((entry) => entry.level === (level || 0)) ||
  PRIORITY_LEVELS[PRIORITY_LEVELS.length - 1];

const slotLabel = (job: JobEntry) =>
  `${job.current}/${job.total === -1 ? '∞' : job.total}`;

const JobRow = (props: {
  job: JobEntry;
  mode: string;
  selected: string | null;
  onSelect: (title: string) => void;
}) => {
  const { job, mode, selected, onSelect } = props;
  const displayTitle = job.displayTitle || job.title;
  const altTitle =
    job.displayTitle && job.displayTitle !== job.title ? job.displayTitle : null;
  const isSelected = selected === job.title;

  let rightSide: ReactNode = null;
  let rightColor: string | undefined;

  if (mode === 'latejoin') {
    rightSide = slotLabel(job);
    rightColor = job.pinned ? 'orange' : undefined;
  } else if (job.blocked) {
    rightSide = null;
  } else if (job.overflow) {
    rightSide = job.priority ? 'Да' : 'Нет';
    rightColor = job.priority ? 'green' : 'red';
  } else if (job.locked) {
    rightSide = '';
    rightColor = 'label';
  } else {
    const meta = priorityMeta(job.priority);
    rightSide = meta.label;
    rightColor = meta.color;
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
        margin: '0 0 6px',
        padding: '2px 8px 6px',
        minInlineSize: 0,
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

  return (
    <Window width={900} height={660}>
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
              {/* Левая колонка */}
              <Stack.Item width="255px" shrink={0}>
                <Box
                  height="100%"
                  style={{ overflowY: 'auto', overflowX: 'hidden' }}>
                  {departments.map((dept) => (
                    <Group key={dept.name} color={dept.color} title={dept.name}>
                      {dept.jobs.length === 0 && (
                        <Box color="label" fontSize="12px">
                          Нет доступных вакансий.
                        </Box>
                      )}
                      {dept.jobs.map((job) => (
                        <JobRow
                          key={job.title}
                          job={job}
                          mode={mode}
                          selected={selected}
                          onSelect={(title) => act('select', { job: title })}
                        />
                      ))}
                    </Group>
                  ))}

                  {isLatejoin &&
                    (ghostRoles.length === 0 ? (
                      <Box color="red" fontSize="12px">
                        В настоящее время нет гост-спавнеров.
                      </Box>
                    ) : (
                      <Group color="#ffffff" title="Гост-роли">
                        {ghostRoles.map((spawner) => (
                          <Button
                            key={spawner}
                            fluid
                            color="transparent"
                            selected={selectedGhost === spawner}
                            style={{ textAlign: 'left' }}
                            onClick={() => act('select_ghost', { spawner })}>
                            {spawner}
                          </Button>
                        ))}
                      </Group>
                    ))}
                </Box>
              </Stack.Item>

              {/* Средняя колонка: описание и действие */}
              <Stack.Item grow basis={0} style={{ minWidth: 0 }}>
                <Box
                  height="100%"
                  style={{ overflowY: 'auto', paddingRight: '6px' }}>
                  {!selectedJob && !ghostName && (
                    <Box color="label">
                      Выберите профессию в списке слева, чтобы увидеть описание,
                      обязанности и цепочку подчинения.
                    </Box>
                  )}

                  {!!ghostName && (
                    <>
                      <Box fontSize="18px" bold color="#ffffff">
                        {ghostName}
                      </Box>
                      <Box color="label">Гост-роль · вне штатных профессий</Box>
                      <Divider />
                      <Box>
                        Внеочередная роль вне штатного расписания станции. Вы
                        попадаете в неё как призрак, а не через набор экипажа.
                      </Box>
                      <Button
                        mt={1}
                        fluid
                        color="good"
                        icon="sign-in-alt"
                        content="Присоединиться"
                        onClick={() =>
                          act('join_ghost', { spawner: selectedGhost })
                        }
                      />
                    </>
                  )}

                  {!!selectedJob && (
                    <>
                      <Box fontSize="18px" bold color={selectedDept?.color}>
                        {selectedJob.displayTitle || selectedJob.title}
                      </Box>
                      <Box color="label">
                        Отдел: {selectedDept?.name}
                        {selectedJob.command ? ' · Командование' : ''}
                      </Box>
                      <Divider />
                      <Box>{info.summary}</Box>

                      {info.tasks && info.tasks.length > 0 && (
                        <>
                          <Box mt={1} bold>
                            Обязанности
                          </Box>
                          {info.tasks.map((task) => (
                            <Box key={task} ml={2}>
                              — {task}
                            </Box>
                          ))}
                        </>
                      )}

                      {info.reports && info.reports.length > 0 && (
                        <>
                          <Box mt={1} bold>
                            Кому подчиняется
                          </Box>
                          <Box ml={2} color="label">
                            {info.reports.join(' → ')}
                          </Box>
                        </>
                      )}

                      <Divider />

                      {isLatejoin && (
                        <>
                          <Box>
                            Свободные места:{' '}
                            <b>{slotLabel(selectedJob)}</b>
                          </Box>
                          {!!selectedJob.pinned && (
                            <Box color="orange">
                              Приоритетная вакансия
                            </Box>
                          )}
                          <Button
                            mt={1}
                            fluid
                            color="good"
                            icon="sign-in-alt"
                            content="Присоединиться"
                            onClick={() =>
                              act('join', { job: selectedJob.title })
                            }
                          />
                        </>
                      )}

                      {!isLatejoin && (
                        <PrefsControls job={selectedJob} act={act} />
                      )}
                    </>
                  )}
                </Box>
              </Stack.Item>

              {/* Правая колонка: превью персонажа в форме отдела */}
              <Stack.Item width="195px" shrink={0}>
                <Section
                  fill
                  title="Превью"
                  style={{ height: '100%' }}>
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
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          {!isLatejoin && (
            <Stack.Item shrink={0}>
              <Stack>
                <Stack.Item>
                  <Button
                    icon="shuffle"
                    tooltip="Что делать, если выбранные профессии не подойдут"
                    onClick={() => act('joblessrole')}>
                    {joblessrole || 'Что делать, если префы недоступны'}
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="undo"
                    onClick={() => act('reset')}>
                    Сбросить приоритеты
                  </Button>
                </Stack.Item>
                <Stack.Item grow basis={0} />
                <Stack.Item>
                  <Button
                    color="transparent"
                    icon="times"
                    onClick={() => act('close')}>
                    Закрыть
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Панелька приоритетов в правом смысле - в средней колонке режима приоритетов. */
const PrefsControls = (props: {
  job: JobEntry;
  act: (action: string, params?: Record<string, unknown>) => void;
}) => {
  const { job, act } = props;
  const currentLevel = job.priority || 0;

  if (job.blocked) {
    return <NoticeBox danger>{job.blocked}</NoticeBox>;
  }

  if (job.overflow) {
    return (
      <>
        <Box color="label">
          Резервная роль, если ни одна из приоритетных профессий не досталась.
        </Box>
        <Stack mt={1}>
          <Stack.Item grow>
            <Button
              fluid
              selected={currentLevel === 3}
              style={{ color: 'green' }}
              onClick={() => act('set_priority', { job: job.title, level: 3 })}>
              Да
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              selected={currentLevel === 0}
              style={{ color: 'red' }}
              onClick={() => act('set_priority', { job: job.title, level: 0 })}>
              Нет
            </Button>
          </Stack.Item>
        </Stack>
      </>
    );
  }

  return (
    <>
      <Box color="label">Приоритет в настройках персонажа:</Box>
      <Stack mt={1}>
        {PRIORITY_LEVELS.map((entry) => (
          <Stack.Item key={entry.level} grow basis={0}>
            <Button
              fluid
              disabled={!!job.locked}
              selected={currentLevel === entry.level}
              style={{ color: entry.color, fontSize: '11px' }}
              onClick={() =>
                act('set_priority', { job: job.title, level: entry.level })
              }>
              {entry.label}
            </Button>
          </Stack.Item>
        ))}
      </Stack>
      {!!job.locked && (
        <Box color="label" fontSize="12px">
          Выберите «Нет» у резервной роли, чтобы включить остальные профессии.
        </Box>
      )}
      {!!job.hasAltTitles && (
        <Button
          mt={1}
          icon="pen"
          content={`Название: ${job.displayTitle || job.title}`}
          onClick={() => act('alt_title', { job: job.title })}
        />
      )}
    </>
  );
};
