import { useBackend } from '../backend';
import { Button, Section, Stack } from '../components';
import { NtosWindow } from '../layouts';

export const NtosMain = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    device_theme,
    programs = [],
    has_light,
    light_on,
    removable_media = [],
    cardholder,
    login = [],
    has_cartridge,
    cartridge_name,
    battery_percent,
  } = data;

  return (
    <NtosWindow
      title={device_theme === 'syndicate' ? 'Syndix OS' : 'NtOS'}
      theme={device_theme}
      width={420}
      height={560}>
      <NtosWindow.Content>
        <Stack vertical fill>
          {/* ID card */}
          {!!cardholder && login.IDName && (
            <Stack.Item>
              <div style={{
                margin: '8px 10px 0 10px',
                padding: '8px 12px',
                background: 'rgba(255,255,255,0.04)',
                border: '1px solid rgba(255,255,255,0.08)',
                borderRadius: '6px',
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
              }}>
                <span style={{ fontSize: '13px' }}>
                  <span style={{ color: 'rgba(255,255,255,0.5)' }}>ID </span>
                  <b>{login.IDName}</b>
                  {login.IDJob && (
                    <span style={{
                      color: 'rgba(255,255,255,0.35)',
                      marginLeft: '6px',
                    }}>
                      {login.IDJob}
                    </span>
                  )}
                </span>
                <Button
                  icon="eject"
                  color="transparent"
                  onClick={() => act('PC_Eject_Disk', { name: 'ID' })}>
                  Eject
                </Button>
              </div>
            </Stack.Item>
          )}

          {/* Cartridge */}
          {!!has_cartridge && (
            <Stack.Item>
              <div style={{
                margin: '4px 10px 0 10px',
                padding: '8px 12px',
                background: 'rgba(255,255,255,0.04)',
                border: '1px solid rgba(255,255,255,0.08)',
                borderRadius: '6px',
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
              }}>
                <span style={{ fontSize: '13px' }}>
                  <span style={{ color: 'rgba(255,255,255,0.5)' }}>
                    Cartridge{' '}
                  </span>
                  <b>{cartridge_name}</b>
                </span>
                <Button
                  icon="eject"
                  color="transparent"
                  onClick={() => act('PDA_ejectDisk')}>
                  Eject
                </Button>
              </div>
            </Stack.Item>
          )}

          {/* Removable media */}
          {!!removable_media.length && (
            <Stack.Item>
              <div style={{ margin: '4px 10px 0 10px' }}>
                {removable_media.map(device => (
                  <Button
                    key={device}
                    fluid
                    color="transparent"
                    icon="eject"
                    content={device}
                    onClick={() =>
                      act('PC_Eject_Disk', { name: device })}
                  />
                ))}
              </div>
            </Stack.Item>
          )}

          {/* Applications */}
          <Stack.Item grow>
            <Section
              title="Applications"
              fill
              style={{ margin: '8px 10px' }}>
              <Stack vertical>
                {programs.map(program => (
                  <Stack.Item key={program.name}>
                    <Button
                      fluid
                      color={program.alert ? 'yellow' : 'transparent'}
                      icon={program.icon}
                      onClick={() =>
                        act('PC_runprogram', { name: program.name })}>
                      {program.desc}
                      {!!program.running && (
                        <span style={{
                          marginLeft: '8px',
                          fontSize: '10px',
                          color: 'rgba(255,255,255,0.4)',
                        }}>
                          (running)
                        </span>
                      )}
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>

          {/* Bottom bar */}
          {!!has_light && (
            <Stack.Item>
              <div style={{
                borderTop: '1px solid rgba(255,255,255,0.08)',
                padding: '8px 14px',
              }}>
                <Button
                  icon="lightbulb"
                  selected={light_on}
                  color="transparent"
                  onClick={() => act('PC_toggle_light')}>
                  Flashlight: {light_on ? 'ON' : 'OFF'}
                </Button>
              </div>
            </Stack.Item>
          )}
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
