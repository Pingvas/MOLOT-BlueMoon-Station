import { useBackend, useLocalState } from '../../backend';
import { Button, Stack } from '../../components';
import { Window } from '../../layouts';
import { SettingsTab } from './SettingsTab';
import { KeybindingsTab } from './KeybindingsTab';

export const GamePreferences = (props, context) => {
  const { act } = useBackend(context);
  const [currentPage, setCurrentPage] = useLocalState(context, 'currentPage', 0);

  let pageContents;
  switch (currentPage) {
    case 0:
      pageContents = <SettingsTab />;
      break;
    case 1:
      pageContents = <KeybindingsTab />;
      break;
  }

  return (
    <Window width={860} height={720} resizable>
      <Window.Content className="GamePreferences">
        <Stack vertical fill>
          <Stack.Item>
            <Stack fill className="GamePreferences__tabs">
              <Stack.Item grow>
                <Button
                  align="center"
                  fontSize="1.1em"
                  fluid
                  selected={currentPage === 0}
                  onClick={() => {
                    if (currentPage === 1) {
                      act('keybinding_cancel');
                    }
                    setCurrentPage(0);
                  }}
                >
                  Настройки
                </Button>
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  align="center"
                  fontSize="1.1em"
                  fluid
                  selected={currentPage === 1}
                  onClick={() => setCurrentPage(1)}
                >
                  Горячие клавиши
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item grow shrink basis="1px">
            {pageContents}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
