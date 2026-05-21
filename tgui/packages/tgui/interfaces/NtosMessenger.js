import { createSearch } from '../../common/string';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Divider,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  TextArea,
  Tooltip,
} from '../components';
import { NtosWindow } from '../layouts';

export const NtosMessenger = (props, context) => {
  const { data } = useBackend(context);
  const {
    is_silicon,
    remote_silicon,
    saved_chats,
    open_chat,
    messengers,
    sending_virus,
  } = data;

  let content;
  if (remote_silicon) {
    content = <AccessDeniedScreen />;
  } else if (open_chat !== null) {
    const openChat = saved_chats[open_chat];
    const temporaryRecipient = messengers[open_chat];

    if (!openChat && !temporaryRecipient) {
      content = <ContactsScreen />;
    } else {
      content = (
        <ChatScreen
          isSilicon={is_silicon}
          sendingVirus={sending_virus}
          canReply={openChat ? openChat.can_reply : !!temporaryRecipient}
          messages={openChat ? openChat.messages : []}
          recipient={openChat ? openChat.recipient : temporaryRecipient}
          unreads={openChat ? openChat.unread_messages : 0}
          chatRef={openChat ? openChat.ref : null}
        />
      );
    }
  } else {
    content = <ContactsScreen />;
  }

  return (
    <NtosWindow width={600} height={850}>
      <NtosWindow.Content>
        {content}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const AccessDeniedScreen = (props, context) => {
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section>
          <Stack vertical textAlign="center">
            <Box bold>
              <Icon name="address-card" />
              {' SpaceMessenger V6.5.3'}
            </Box>
          </Stack>
        </Section>
      </Stack.Item>
      <NoticeBox
        color="white"
        position="relative"
        top="30%"
        fontSize="30px"
        textAlign="center">
        ERROR: CONNECTION REFUSED
      </NoticeBox>
      <Stack vertical position="relative" top="35%" textAlign="left">
        <Section>
          <Box>Message from host:</Box>
          <Box>- Remote access of this application has been restricted.</Box>
          <Box>- Contact your Administrator for further assistance.</Box>
        </Section>
      </Stack>
    </Stack>
  );
};

const ContactsScreen = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    owner,
    alert_silenced,
    alert_able,
    sending_and_receiving,
    saved_chats,
    messengers,
    sort_by_job,
    can_spam,
    is_silicon,
    virus_attach,
    sending_virus,
    ringtone_list = [],
    current_ringtone,
  } = data;

  const [searchUser, setSearchUser] = useLocalState(context, 'searchUser', '');
  const [showRingtone, setShowRingtone] = useLocalState(context, 'showRingtone', false);

  const sortByUnreads = (array) =>
    [...array].sort((a, b) => b.unread_messages - a.unread_messages);

  const searchChatByName = createSearch(
    searchUser,
    (chat) => chat.recipient.name + chat.recipient.job,
  );
  const searchMessengerByName = createSearch(
    searchUser,
    (messenger) => messenger.name + messenger.job,
  );

  const chatToButton = (chat) => (
    <ChatButton
      key={chat.ref}
      name={`${chat.recipient.name} (${chat.recipient.job})`}
      chatRef={chat.ref}
      unreads={chat.unread_messages}
    />
  );

  const messengerToButton = (messenger) => (
    <ChatButton
      key={messenger.ref}
      name={`${messenger.name} (${messenger.job})`}
      chatRef={messenger.ref}
      unreads={0}
    />
  );

  const openChatsArray = sortByUnreads(
    Object.values(saved_chats || {}),
  ).filter(searchChatByName);

  const filteredChatButtons = openChatsArray
    .filter((c) => c.visible)
    .map(chatToButton);

  const messengerButtons = Object.entries(messengers || {})
    .filter(
      ([ref, messenger]) =>
        openChatsArray.filter(c => c.visible).every((chat) => chat.recipient.ref !== ref)
        && searchMessengerByName(messenger),
    )
    .map(([_, messenger]) => messenger)
    .map(messengerToButton)
    .concat(
      openChatsArray.filter((chat) => !chat.visible).map(chatToButton),
    );

  return (
    <>
    <Stack fill vertical>
      <Stack.Item>
        <Section>
          <Stack vertical textAlign="center">
            <Box bold>
              <Icon name="address-card" mr={1} />
              SpaceMessenger V6.5.3
            </Box>
            <Box italic opacity={0.3} mt={1}>
              Bringing you spy-proof communications since 2467.
            </Box>
            <Divider hidden />
            <Box>
              <Button
                icon="bell"
                disabled={!alert_able}
                content={
                  alert_able && !alert_silenced ? 'Ringer: On' : 'Ringer: Off'
                }
                onClick={() => act('PDA_toggleAlerts')}
              />
              <Button
                icon="address-card"
                content={
                  sending_and_receiving
                    ? 'Send / Receive: On'
                    : 'Send / Receive: Off'
                }
                onClick={() => act('PDA_toggleSendingAndReceiving')}
              />
              <Button
                icon="bell"
                content={`Ringtone: ${current_ringtone || 'beep'}`}
                onClick={() => setShowRingtone(!showRingtone)}
              />
              <Button
                icon="sort"
                content={`Sort by: ${sort_by_job ? 'Job' : 'Name'}`}
                onClick={() => act('PDA_changeSortStyle')}
              />
              {!!virus_attach && (
                <Button
                  icon="bug"
                  color="bad"
                  content={`Attach Virus: ${sending_virus ? 'Yes' : 'No'}`}
                  onClick={() => act('PDA_toggleVirus')}
                />
              )}
            </Box>
          </Stack>
          <Divider hidden />
          <Stack justify="space-between">
            <Box m={0.5}>
              <Icon name="magnifying-glass" mr={1} />
              Search For User
            </Box>
            <Input
              width="220px"
              placeholder="Search by name or job..."
              value={searchUser}
              onInput={(e, val) => setSearchUser(val)}
            />
          </Stack>
        </Section>
      </Stack.Item>
      {filteredChatButtons.length > 0 && (
        <Stack.Item grow={1}>
          <Stack vertical fill>
            <Section>
              <Icon name="comments" mr={1} />
              Previous Messages
            </Section>
            <Section fill scrollable>
              <Stack vertical>{filteredChatButtons}</Stack>
            </Section>
          </Stack>
        </Stack.Item>
      )}
      <Stack.Item grow={2}>
        <Stack vertical fill>
          <Section>
            <Stack>
              <Box m={0.5}>
                <Icon name="address-card" mr={1} />
                Detected Messengers
              </Box>
            </Stack>
          </Section>
          <Section fill scrollable>
            <Stack vertical pb={1} fill>
              {messengerButtons.length === 0 && (
                <Stack align="center" justify="center" fill pl={4}>
                  <Icon color="gray" name="user-slash" size={2} />
                  <Stack.Item fontSize={1.5} ml={3}>
                    No users found.
                  </Stack.Item>
                </Stack>
              )}
              {messengerButtons}
            </Stack>
          </Section>
        </Stack>
      </Stack.Item>
      {!!can_spam && (
        <Stack.Item>
          <SendToAllSection />
        </Stack.Item>
      )}
      </Stack>
      {showRingtone && (
        <Box style={{
          position: 'fixed',
          top: '120px',
          left: '10px',
          zIndex: 9999,
          background: '#1a1a1a',
          border: '1px solid rgba(255,255,255,0.3)',
          borderRadius: '4px',
          padding: '4px',
          maxHeight: '200px',
          overflowY: 'auto',
          minWidth: '140px',
        }}>
          {ringtone_list.map((ringtone) => (
            <Button
              key={ringtone}
              fluid
              color="transparent"
              content={ringtone}
              selected={ringtone === current_ringtone}
              onClick={() => {
                act('PDA_ringSetPreset', { ringtone: ringtone });
                setShowRingtone(false);
              }}
            />
          ))}
          <Divider />
          <Button
            fluid
            color="transparent"
            icon="edit"
            content="Custom..."
            onClick={() => {
              act('PDA_ringSet');
              setShowRingtone(false);
            }}
          />
        </Box>
      )}
    </>
  );
};

const ChatButton = (props, context) => {
  const { act } = useBackend(context);
  const { unreads, chatRef, name } = props;
  const hasUnreads = unreads > 0;
  return (
    <Button
      icon={hasUnreads && 'envelope'}
      key={chatRef}
      fluid
      onClick={() => act('PDA_viewMessages', { ref: chatRef })}>
      {hasUnreads
        && `[${unreads <= 9 ? unreads : '9+'} unread message${
          unreads !== 1 ? 's' : ''
        }]`}{' '}
      {name}
    </Button>
  );
};

const SendToAllSection = (props, context) => {
  const { data, act } = useBackend(context);
  const { on_spam_cooldown } = data;

  const [message, setMessage] = useLocalState(context, 'spamMessage', '');

  return (
    <>
      <Section>
        <Stack justify="space-between">
          <Stack.Item align="center">
            <Icon name="satellite-dish" mr={1} ml={0.5} />
            Send To All
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="arrow-right"
              disabled={on_spam_cooldown || message === ''}
              tooltip={on_spam_cooldown && 'Wait before sending more messages!'}
              onClick={() => {
                act('PDA_sendEveryone', { message: message });
                setMessage('');
              }}>
              Send
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
      <Section>
        <TextArea
          height={6}
          value={message}
          placeholder="Send message to everyone..."
          onInput={(e, val) => setMessage(val)}
        />
      </Section>
    </>
  );
};

const ChatScreen = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    canReply,
    messages,
    recipient,
    chatRef,
    sendingVirus,
    unreads,
  } = props;

  const { emoji_list, emoji_base64 } = data;
  const rawList = Array.isArray(emoji_list) ? emoji_list : Object.values(emoji_list || {});
  const uniqueEmojis = [...new Set(rawList)].slice(0, 100);
  const base64Map = emoji_base64 || {};

  const [message, setMessage] = useLocalState(context, 'chatMessage', '');
  const [canSend, setCanSend] = useLocalState(context, 'canSend', true);
  const [showEmoji, setShowEmoji] = useLocalState(context, 'showEmoji', false);

  const handleSendMessage = () => {
    if (message === '') {
      return;
    }
    const ref = chatRef || recipient.ref;
    act('PDA_sendMessage', {
      ref: ref,
      message: message,
    });
    setMessage('');
    setCanSend(false);
    setTimeout(() => setCanSend(true), 1000);
  };

  const handleEmojiClick = (emoji) => {
    setMessage(message + ' :' + emoji + ': ');
    setShowEmoji(false);
  };

  const filteredMessages = [];
  for (let index = 0; index < messages.length; index++) {
    const msg = messages[index];
    const isSwitch = !(
      index === 0 || messages[index - 1].outgoing === msg.outgoing
    );

    if (index === messages.length - unreads) {
      filteredMessages.push(
        <Box className="UnreadDivider" m={0} mt={isSwitch ? 3 : 1}>
          <div />
          <span>Unread Messages</span>
          <div />
        </Box>,
      );
    }

    filteredMessages.push(
      <Stack.Item key={index} mt={isSwitch ? 3 : 1}>
        <ChatMessage
          outgoing={msg.outgoing}
          message={msg.message}
          everyone={msg.everyone}
          timestamp={msg.timestamp}
        />
      </Stack.Item>,
    );
  }

  let sendingBar;

  if (!canReply) {
    sendingBar = (
      <Section fill>
        <Box width="100%" italic color="gray" ml={1}>
          You cannot reply to this user.
        </Box>
      </Section>
    );
  } else {
    const buttons = (
      <>
        {!!sendingVirus && (
          <Stack.Item>
            <Button
              tooltip="ERROR: File signature is unverified."
              icon="triangle-exclamation"
              color="red"
            />
          </Stack.Item>
        )}
        <Stack.Item>
          <Button
            tooltip="Emoji"
            icon="smile"
            onClick={() => setShowEmoji(!showEmoji)}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            tooltip="Send"
            icon="arrow-right"
            onClick={handleSendMessage}
            disabled={!canSend}
          />
        </Stack.Item>
      </>
    );

    sendingBar = (
      <Section fill>
        <Stack fill align="center">
          <Stack.Item grow>
            <Input
              placeholder={`Send message to ${recipient.name}...`}
              fluid
              autoFocus
              value={message}
              maxLength={1024}
              onInput={(e, val) => setMessage(val)}
              onEnter={handleSendMessage}
              selfClear
            />
          </Stack.Item>
          {buttons}
        </Stack>
      </Section>
    );
  }

  return (
    <>
    <Stack vertical fill>
      <Section>
        <Button
          icon="arrow-left"
          content="Back"
          onClick={() => act('PDA_viewMessages', { ref: null })}
        />
        {chatRef && (
          <>
            <Button
              icon="box-archive"
              content="Close chat"
              onClick={() => act('PDA_closeMessages', { ref: chatRef })}
            />
            <Button.Confirm
              icon="trash-can"
              content="Delete chat"
              onClick={() => act('PDA_clearMessages', { ref: chatRef })}
            />
          </>
        )}
      </Section>

      <Stack.Item grow={1}>
        <Section
          scrollable
          fill
          fitted
          title={`${recipient.name} (${recipient.job})`}>
          <Stack vertical className="NtosChatLog">
            {!!(messages.length > 0 && canReply) && (
              <>
                <Stack.Item textAlign="center" fontSize={1}>
                  This is the beginning of your chat with {recipient.name}.
                </Stack.Item>
                <Stack.Divider />
              </>
            )}
            {filteredMessages}
          </Stack>
        </Section>
      </Stack.Item>

      <Stack.Item>{sendingBar}</Stack.Item>
    </Stack>
    {showEmoji && (() => {
        const EMOJIS_PER_ROW = 15;
        const rows = [];
        for (let i = 0; i < uniqueEmojis.length; i += EMOJIS_PER_ROW) {
          rows.push(uniqueEmojis.slice(i, i + EMOJIS_PER_ROW));
        }
        return (
          <Box style={{
            position: 'fixed',
            bottom: '50px',
            left: '10px',
            zIndex: 9999,
            background: '#1a1a1a',
            border: '1px solid rgba(255,255,255,0.3)',
            borderRadius: '4px',
            padding: '4px',
            maxHeight: '180px',
            overflowY: 'auto',
          }}>
            {rows.map((row, rowIdx) => (
              <Stack key={rowIdx} mb={0.5}>
                {row.map((emoji) => {
                  const b64 = base64Map[emoji];
                  return (
                    <Stack.Item key={emoji}>
                      <Button
                        color="transparent"
                        tooltip={emoji}
                        style={{
                          padding: '1px 3px',
                          fontSize: '11px',
                          minWidth: '28px',
                          width: '28px',
                          height: '28px',
                          textAlign: 'center',
                        }}
                        onClick={() => handleEmojiClick(emoji)}>
                        {b64 ? (
                          <img
                            src={'data:image/png;base64,' + b64}
                            alt={':' + emoji + ':'}
                            style={{ width: '16px', height: '16px', verticalAlign: 'middle' }}
                          />
                        ) : (
                          ':' + emoji + ':'
                        )}
                      </Button>
                    </Stack.Item>
                  );
                })}
              </Stack>
            ))}
          </Box>
        );
      })()}
    </>
  );
};

const ChatMessage = (props) => {
  const { message, everyone, outgoing, timestamp } = props;

  return (
    <Box className={`NtosChatMessage${outgoing ? '_outgoing' : ''}`}>
      <Box className="NtosChatMessage__content">
        <Box as="span" dangerouslySetInnerHTML={{ __html: message }} />
        <Tooltip content={timestamp} position={outgoing ? 'left' : 'right'}>
          <Icon
            className="NtosChatMessage__timestamp"
            name="clock-o"
            size={0.8}
          />
        </Tooltip>
      </Box>
      {!!everyone && (
        <Box className="NtosChatMessage__everyone">Sent to everyone</Box>
      )}
    </Box>
  );
};
