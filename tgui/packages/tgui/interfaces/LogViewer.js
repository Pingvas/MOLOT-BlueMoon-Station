import { useCallback, useRef } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Dropdown, Flex, Icon, Input, Section } from '../components';
import { Window } from '../layouts';

const stripHtml = (str) => {
  if (!str) return str;
  return String(str).replace(/<[^>]*>/g, '').trim();
};

const LOG_COLORS = {
  Attack: '#ff6b6b',
  Say: '#4dd0e1',
  Emote: '#64b5f6',
  Comms: '#90a4ae',
  OOC: '#5b9bd5',
  Admin: '#ef5350',
  Game: '#66bb6a',
  Deadchat: '#ce93d8',
  Mecha: '#ffb74d',
  Virus: '#81c784',
  Shuttle: '#ffd54f',
  Whisper: '#b39ddb',
  Victim: '#ff8a65',
};

const getLogColor = (type) => LOG_COLORS[type] || 'gray';

export const LogViewer = (props) => {
  const { act, data } = useBackend();
  const {
    logs = [],
    log_count = 0,
    log_count_total = 0,
    target_name,
    target_ckey,
    source_type,
    filter_text,
    target_filter: targetFilter = '',
    viewing_type,
    log_types = [],
    source_options = [],
    ckeys_list = [],
  } = data;

  const debounceRef = useRef(null);
  const logsArray = Array.isArray(logs) ? logs : [];
  const safeLogCount = logsArray.length;
  const debouncedAct = useCallback((action, payload, delay = 120) => {
    if (debounceRef.current) clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(() => act(action, payload), delay);
  }, [act]);

  const handleCkeySelect = (ckey) => {
    act('select_ckey', { ckey });
  };

  const handleKeyDown = useCallback((e) => {
    if (e.key === 'Escape') {
      if (filter_text || targetFilter) {
        act('set_filter', { text: '' });
        act('set_target_filter', { text: '' });
      }
    }
  }, [filter_text, targetFilter, act]);

  const showAllFlag = log_types.find(
    (t) => t.name === 'Показать все' || t.name === 'Show All'
  )?.flag;
  const handleClearText = useCallback(() => act('set_filter', { text: '' }), [act]);
  const handleClearTarget = useCallback(() => act('set_target_filter', { text: '' }), [act]);
  const handleClearType = useCallback(() => {
    if (showAllFlag !== undefined) act('set_viewing_type', { type: showAllFlag });
  }, [act, showAllFlag]);
  const activeFilterType = showAllFlag !== undefined && viewing_type !== showAllFlag
    ? log_types.find((t) => t.flag === viewing_type)
    : null;

  return (
    <Window title="Log Viewer" width={1100} height={700} resizable>
      <Window.Content scrollable tabIndex={0} onKeyDown={handleKeyDown}>
        <Section>
          <Flex direction="column" gap={0.5}>
            <Flex.Item>
              <Flex align="center" gap={1}>
                <Flex.Item shrink={0}>
                  <Box inline bold mr={0.5}
                    style={{ color: '#aaa', fontSize: '13px' }}>
                    Игрок:
                  </Box>
                </Flex.Item>
                <Flex.Item grow={1}>
                  <Dropdown
                    width="100%"
                    placeholder="Выберите игрока..."
                    selected={target_ckey}
                    options={ckeys_list}
                    onSelected={handleCkeySelect}
                  />
                </Flex.Item>
                <Flex.Item shrink={0}>
                  <Button
                    icon="user"
                    color="transparent"
                    tooltip="Открыть панель игрока"
                    style={{
                      color: '#999',
                      border: '1px solid #444',
                      padding: '3px 8px',
                    }}
                    onClick={() => act('open_pp')}
                  >
                    {target_name || 'Нет'}
                  </Button>
                </Flex.Item>
              </Flex>
            </Flex.Item>

            <Flex.Item>
              <Flex align="center" gap={1}>
                <Flex.Item shrink={0}>
                  <Box inline bold mr={0.5}
                    style={{ color: '#aaa', fontSize: '13px' }}>
                    Источник:
                  </Box>
                  {source_options.map((src) => (
                    <Button
                      key={src}
                      selected={source_type === src}
                      content={src}
                      style={{
                        fontSize: '12px',
                        padding: '2px 8px',
                        minWidth: '0',
                      }}
                      onClick={() => act('set_source', { source: src })}
                    />
                  ))}
                </Flex.Item>
                <Flex.Item grow={1} />
                <Flex.Item width={150} shrink={0}>
                  <Input
                    fluid
                    placeholder="Поиск..."
                    value={filter_text}
                    onInput={(e, value) =>
                      debouncedAct('set_filter', { text: value })
                    }
                  />
                </Flex.Item>
                <Flex.Item width={180} shrink={0}>
                  <Input
                    fluid
                    placeholder="Цель (игрок 2)..."
                    value={targetFilter}
                    onInput={(e, value) =>
                      debouncedAct('set_target_filter', { text: value })
                    }
                  />
                </Flex.Item>
              </Flex>
            </Flex.Item>

            <Flex.Item>
              <Flex align="center" gap={0.5} wrap>
                <Box inline bold mr={0.5}
                  style={{ color: '#aaa', fontSize: '13px' }}>
                  Тип:
                </Box>
                {log_types.map((lt) => (
                  <Button
                    key={lt.flag}
                    selected={viewing_type === lt.flag}
                    style={{
                      fontSize: '12px',
                      padding: '2px 10px',
                      minWidth: '0',
                      borderColor: viewing_type === lt.flag ? lt.color : lt.color + '55',
                      backgroundColor:
                        viewing_type === lt.flag ? lt.color + '33' : 'transparent',
                      color:
                        viewing_type === lt.flag ? lt.color : lt.color + 'aa',
                      fontWeight: viewing_type === lt.flag ? 'bold' : 'normal',
                    }}
                    content={lt.name}
                    onClick={() =>
                      act('set_viewing_type', { type: lt.flag })
                    }
                  />
                ))}
              </Flex>
            </Flex.Item>

            {(filter_text || targetFilter || activeFilterType) && (
              <Flex.Item>
                <Flex align="center" gap={0.5}>
                  <Box style={{ color: '#666', fontSize: '11px' }}>
                    Фильтры:
                  </Box>
                  {filter_text && (
                    <Box
                      as="span"
                      ml={0.5}
                      px={0.5}
                      py={0.2}
                      fontSize="10px"
                      style={{
                        color: '#ffd54f',
                        backgroundColor: '#ffd54f22',
                        border: '1px solid #ffd54f44',
                        borderRadius: '3px',
                        cursor: 'pointer',
                      }}
                      onClick={handleClearText}
                    >
                      текст: {filter_text} ×
                    </Box>
                  )}
                  {targetFilter && (
                    <Box
                      as="span"
                      ml={0.5}
                      px={0.5}
                      py={0.2}
                      fontSize="10px"
                      style={{
                        color: '#ffd54f',
                        backgroundColor: '#ffd54f22',
                        border: '1px solid #ffd54f44',
                        borderRadius: '3px',
                        cursor: 'pointer',
                      }}
                      onClick={handleClearTarget}
                    >
                      цель: {targetFilter} ×
                    </Box>
                  )}
                  {activeFilterType && (
                    <Box
                      as="span"
                      ml={0.5}
                      px={0.5}
                      py={0.2}
                      fontSize="10px"
                      style={{
                        color: '#ffd54f',
                        backgroundColor: '#ffd54f22',
                        border: '1px solid #ffd54f44',
                        borderRadius: '3px',
                        cursor: 'pointer',
                      }}
                      onClick={handleClearType}
                    >
                      {activeFilterType.name} ×
                    </Box>
                  )}
                </Flex>
              </Flex.Item>
            )}
          </Flex>
        </Section>

        <Section
          title={"Лог (" + safeLogCount + " записей" + (safeLogCount < log_count_total ? ", показано " + safeLogCount + " из " + log_count_total : "") + ")"}
          buttons={
            <Button
              icon="sync"
              content="Обновить"
              onClick={() => act('refresh')}
            />
          }
        >
          {!target_ckey && (
            <Box style={{ color: '#555', textAlign: 'center', py: 6, fontSize: '14px' }}>
              <Icon name="chevron-circle-up" mr={1} />
              Выберите игрока из списка выше
            </Box>
          )}
          {target_ckey && safeLogCount === 0 && (
            <Box style={{ color: '#555', textAlign: 'center', py: 6, fontSize: '14px' }}>
              <Icon name="search" mr={1} />
              Логов не найдено
            </Box>
          )}
          {logsArray.slice().reverse().map((entry, i) => (
            <LogEntry key={entry.time + entry.who + entry.type + i} entry={entry} act={act} />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

const LogEntry = (props) => {
  const { entry, act } = props;
  const {
    time = '??:??:??',
    who = 'unknown',
    what = '',
    where = '',
    type = 'Misc',
    health = null,
    color = null,
    target_name = null,
    target_key = null,
  } = entry;

  const typeColor = getLogColor(type);
  const hasTarget = target_name || target_key;

  return (
    <Box
      mb={0.5}
      px={1.5}
      py={0.8}
      style={{
        borderLeft: `4px solid ${typeColor}`,
        borderBottom: '1px solid #1a1a1a',
        backgroundColor: '#0a0a0a',
        fontFamily: 'monospace',
        fontSize: '12px',
        lineHeight: '1.5',
        transition: 'background-color 0.1s',
      }}
    >
      <Flex align="flex-start" gap={0.5}>
        <Flex.Item shrink={0}
          style={{ color: '#555', minWidth: '58px', fontSize: '11px' }}>
          {time}
        </Flex.Item>
        <Flex.Item shrink={0}>
          <Box
            px={0.5}
            style={{
              color: typeColor,
              fontSize: '10px',
              fontWeight: 'bold',
              textTransform: 'uppercase',
              letterSpacing: '0.5px',
              opacity: 0.8,
            }}
          >
            {type}
          </Box>
        </Flex.Item>
        <Flex.Item grow={1}
          style={{
            color: color || '#ccc',
            textShadow: color ? '0 0 3px rgba(0,0,0,0.8)' : 'none',
            wordBreak: 'break-word',
          }}>
          {stripHtml(what)}
        </Flex.Item>
        <Flex.Item shrink={0}
          style={{
            color: '#666',
            minWidth: '100px',
            textAlign: 'right',
            fontSize: '11px',
          }}>
          {who}
        </Flex.Item>
      </Flex>
      <Flex mt={0.3} align="center" wrap>
        <Flex.Item style={{ color: '#444', fontSize: '11px' }}>
          {where}
          {health !== null && health !== undefined && (
            <Box as="span" ml={1.5}
              style={{ color: '#ff8c00', fontWeight: 'bold' }}>
              HP: {health}
            </Box>
          )}
        </Flex.Item>
        {hasTarget && (
          <Flex.Item grow={1} />
        )}
        {hasTarget && (
          <Flex.Item>
            <Box
              as="span"
              px={0.5}
              py={0.2}
              style={{
                fontSize: '10px',
                color: '#4fc3ff',
                backgroundColor: '#4fc3ff15',
                border: '1px solid #4fc3ff33',
                borderRadius: '3px',
                cursor: 'pointer',
              }}
              onClick={() => act('set_target_filter', { text: target_key || target_name })}
            >
              <Icon name="crosshairs" mr={0.3} />
              {target_key || target_name}
            </Box>
          </Flex.Item>
        )}
      </Flex>
    </Box>
  );
};