import { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Flex, Icon, Input, Section } from '../components';
import { Window } from '../layouts';

export const PlayerList = (props) => {
  const { act, data } = useBackend();
  const { players = [], total = 0 } = data;

  const [search, setSearch] = useState('');

  const lowerSearch = search.toLowerCase();
  const filtered = players.filter((p) => {
    if (!lowerSearch) return true;
    return (
      (p.name && p.name.toLowerCase().includes(lowerSearch))
      || (p.real_name && p.real_name.toLowerCase().includes(lowerSearch))
      || (p.key && p.key.toLowerCase().includes(lowerSearch))
      || (p.job && p.job.toLowerCase().includes(lowerSearch))
    );
  });

  return (
    <Window title="Player Panel" width={950} height={700} resizable>
      <Window.Content scrollable>
        <Section>
          <Box
            textAlign="center"
            fontSize="24px"
            bold
            m={1.5}
            style={{ color: '#98B0C3', textShadow: '1px 1px 3px #000' }}
          >
            <Icon name="users" mr={1} />
            Панель игроков
          </Box>

          <Flex align="center" justify="center" wrap mb={2}>
            <Box fontSize="13px" style={{ color: '#8a9bae' }}>
              <Button
                icon="user-secret"
                color="transparent"
                tooltip="Открыть список антагонистов"
                style={{
                  color: '#b0bec5',
                  padding: '4px 8px',
                  margin: 0,
                  border: '1px solid #546e7a',
                  borderRadius: '4px',
                  cursor: 'pointer',
                }}
                onClick={() => act('check_antagonists')}
              >
                Проверить антагонистов
              </Button>
              {' '}
              <Button
                icon="sign-out-alt"
                color="transparent"
                tooltip="Выгнать всех из лобби"
                style={{
                  color: '#b0bec5',
                  padding: '4px 8px',
                  margin: 0,
                  border: '1px solid #546e7a',
                  borderRadius: '4px',
                  cursor: 'pointer',
                }}
                onClick={() => act('kick_all_from_lobby',
                  { afkonly: 0 })}
              >
                Выгнать всех
              </Button>
              {' '}
              <Button
                icon="clock"
                color="transparent"
                tooltip="Выгнать только AFK из лобби"
                style={{
                  color: '#b0bec5',
                  padding: '4px 8px',
                  margin: 0,
                  border: '1px solid #546e7a',
                  borderRadius: '4px',
                  cursor: 'pointer',
                }}
                onClick={() => act('kick_all_from_lobby',
                  { afkonly: 1 })}
              >
                Выгнать AFK
              </Button>
            </Box>
          </Flex>

          <Flex align="center" gap={1} mb={2}>
            <Flex.Item>
              <b style={{ fontSize: '14px' }}>
                <Icon name="search" mr={0.5} />
                Поиск:
              </b>
            </Flex.Item>
            <Flex.Item width="50%">
              <Input
                width="100%"
                placeholder="Введите имя, ckey или должность..."
                value={search}
                onInput={(e, value) => setSearch(value)}
              />
            </Flex.Item>
            <Flex.Item grow={1} />
            <Flex.Item>
              <Box
                px={1.5}
                py={0.5}
                style={{
                  backgroundColor: '#222',
                  borderRadius: '4px',
                  color: '#888',
                  fontSize: '13px',
                }}
              >
                <Icon name="user" mr={0.5} />
                {filtered.length}/{total}
              </Box>
            </Flex.Item>
          </Flex>
        </Section>

        {filtered.length === 0 && (
          <Box
            textAlign="center"
            py={8}
            style={{ color: '#555', fontSize: '16px' }}
          >
            <Icon name="ghost" size={2.5} mb={1.5} />
            <Box>Нет игроков по вашему запросу.</Box>
          </Box>
        )}

        {filtered.map((p) => (
          <PlayerCard key={p.ref} player={p} act={act} />
        ))}
      </Window.Content>
    </Window>
  );
};

const PLAYER_ACTIONS = [
  { key: 'open_pp', icon: 'user', label: 'PP',
    tooltip: 'Player Panel', color: '#5695d6' },
  { key: 'open_notes', icon: 'sticky-note', label: 'N',
    tooltip: 'Заметки', color: '#8bc34a' },
  { key: 'open_vv', icon: 'eye', label: 'VV',
    tooltip: 'View Variables', color: '#ff9800' },
  { key: 'open_tp', icon: 'user-secret', label: 'TP',
    tooltip: 'Traitor Panel', color: '#9c27b0' },
  { key: 'open_pm', icon: 'comment', label: 'PM',
    tooltip: 'Приватное сообщение', color: '#00bcd4' },
  { key: 'open_sm', icon: 'volume-up', label: 'SM',
    tooltip: 'Subtle Message', color: '#e91e63' },
  { key: 'open_flw', icon: 'arrow-right', label: 'FLW',
    tooltip: 'Следовать', color: '#4caf50' },
  { key: 'open_logs', icon: 'book', label: 'LOGS',
    tooltip: 'Логи', color: '#795548' },
  { key: 'open_kick', icon: 'ban', label: 'KICK',
    tooltip: 'Выгнать', color: '#ff7043' },
  { key: 'open_ban', icon: 'gavel', label: 'BAN',
    tooltip: 'Забанить', color: '#f44336' },
];

const PlayerCard = (props) => {
  const { player: p, act } = props;

  const buttons = [...PLAYER_ACTIONS];
  if (p.is_cyborg) {
    const bp = { key: 'open_bp', icon: 'robot', label: 'BP',
      tooltip: 'Borg Panel', color: '#607d8b' };
    buttons.splice(4, 0, bp);
  }

  const isAntag = !!p.antag;

  return (
    <Section>
      <Flex direction="column" gap={1}>
        <Flex.Item>
          <Flex align="center" wrap>
            <Box
              fontSize="18px"
              bold
              style={{
                color: isAntag ? '#ff6b6b' : '#e0e0e0',
                textShadow: isAntag ? '0 0 5px rgba(255,0,0,0.35)' : 'none',
              }}
            >
              {isAntag && (
                <Icon name="skull" mr={0.5} style={{ color: '#ff4444' }} />
              )}
              {p.key}
            </Box>
            {isAntag && (
              <Box
                as="span"
                ml={1.5}
                px={1}
                py={0.3}
                fontSize="12px"
                bold
                style={{
                  color: '#fff',
                  backgroundColor: '#ff4444',
                  borderRadius: '3px',
                  textTransform: 'uppercase',
                }}
              >
                АНТАГОНИСТ
              </Box>
            )}
          </Flex>
        </Flex.Item>

        <Flex.Item ml={1}>
          <Flex direction="column" gap={0.6}>
            <Flex.Item>
              <Box fontSize="13px" style={{ color: '#aaa' }}>
                <Icon name="briefcase" mr={0.8} color="#78909c" />
                Должность: <b>{p.job || 'Неизвестно'}</b>
                {' | '}
                <Icon name="tag" mr={0.5} color="#78909c" />
                Имя: <b>{p.name}</b>
                {' | '}
                <Icon name="user-circle" mr={0.5} color="#78909c" />
                <b>{p.real_name}</b>
              </Box>
            </Flex.Item>
            <Flex.Item>
              <Box fontSize="12px" style={{ color: '#777' }}>
                <Icon name="globe" mr={0.8} color="#78909c" />
                {p.ip || '0.0.0.0'} / CID: {p.cid || '?'}
              </Box>
            </Flex.Item>
          </Flex>
        </Flex.Item>

        <Flex.Item>
          <Flex
            align="center"
            gap={0.5}
            wrap
            px={1}
            py={0.7}
            style={{
              backgroundColor: '#1a1a1a',
              borderRadius: '4px',
            }}
          >
            {buttons.map((btn) => (
              <Button
                key={btn.key}
                icon={btn.icon}
                tooltip={btn.tooltip}
                style={{
                  color: btn.color,
                  border: `1px solid ${btn.color}44`,
                  backgroundColor: `${btn.color}18`,
                  padding: '3px 8px',
                  fontSize: '12px',
                  fontWeight: 'bold',
                }}
                onClick={() => act(btn.key, { ref: p.ref })}
              >
                {btn.label}
              </Button>
            ))}
          </Flex>
        </Flex.Item>
      </Flex>
    </Section>
  );
};
