import { useBackend } from '../../../backend';
import { Box, Button, LabeledList, Section, Stack } from '../../../components';
import { CharacterSetupData } from '../types';

export const BackgroundTab = (_props, context) => {
  const { act, data } = useBackend<CharacterSetupData>(context);

  return (
    <Stack vertical>
      {/* Описание */}
      <Stack.Item>
        <Section title="Описание персонажа">
          <Stack vertical>
            <Stack.Item>
              <Button
                fluid
                icon="pen"
                content="Редактировать описание"
                onClick={() => act('set_flavor_text')}
              />
              {!!data.flavor_text && (
                <Box mt={1} style={{ 'white-space': 'pre-line' }} color="label">
                  {data.flavor_text.length > 200
                    ? data.flavor_text.substring(0, 200) + '...'
                    : data.flavor_text}
                </Box>
              )}
            </Stack.Item>
            <Stack.Item>
              <Button
                fluid
                icon="pen"
                content="Описание без одежды"
                onClick={() => act('set_naked_flavor_text')}
              />
              {!!data.naked_flavor_text && (
                <Box mt={1} style={{ 'white-space': 'pre-line' }} color="label">
                  {data.naked_flavor_text.length > 200
                    ? data.naked_flavor_text.substring(0, 200) + '...'
                    : data.naked_flavor_text}
                </Box>
              )}
            </Stack.Item>
            <Stack.Item>
              <Button
                fluid
                icon="pen"
                content="Описание силикона"
                onClick={() => act('set_silicon_flavor_text')}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* Лор расы */}
      <Stack.Item>
        <Section title="Лор расы">
          <Button
            fluid
            icon="pen"
            content="Редактировать лор расы"
            onClick={() => act('set_custom_species_lore')}
          />
          {!!data.custom_species_lore && (
            <Box mt={1} style={{ 'white-space': 'pre-line' }} color="label">
              {data.custom_species_lore.length > 200
                ? data.custom_species_lore.substring(0, 200) + '...'
                : data.custom_species_lore}
            </Box>
          )}
        </Section>
      </Stack.Item>

      {/* Записи */}
      <Stack.Item>
        <Section title="Записи">
          <Stack>
            <Stack.Item grow basis={0}>
              <Button
                fluid
                icon="shield-alt"
                content="Записи СБ"
                onClick={() => act('set_security_records')}
              />
              {!!data.security_records && (
                <Box mt={1} style={{ 'white-space': 'pre-line' }} color="label">
                  {data.security_records.length > 150
                    ? data.security_records.substring(0, 150) + '...'
                    : data.security_records}
                </Box>
              )}
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <Button
                fluid
                icon="medkit"
                content="Мед. записи"
                onClick={() => act('set_medical_records')}
              />
              {!!data.medical_records && (
                <Box mt={1} style={{ 'white-space': 'pre-line' }} color="label">
                  {data.medical_records.length > 150
                    ? data.medical_records.substring(0, 150) + '...'
                    : data.medical_records}
                </Box>
              )}
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {/* OOC заметки */}
      <Stack.Item>
        <Section title="OOC заметки">
          <Button
            fluid
            icon="comment"
            content="Редактировать OOC заметки"
            onClick={() => act('set_ooc_notes')}
          />
          {!!data.ooc_notes && (
            <Box mt={1} style={{ 'white-space': 'pre-line' }} color="label">
              {data.ooc_notes.length > 200
                ? data.ooc_notes.substring(0, 200) + '...'
                : data.ooc_notes}
            </Box>
          )}
        </Section>
      </Stack.Item>

      {/* Смерть */}
      <Stack.Item>
        <Section title="Смерть">
          <LabeledList>
            <LabeledList.Item label="Предсмертный хрип">
              <Button
                content={data.custom_deathgasp || 'По умолч.'}
                icon="pen"
                onClick={() => act('set_custom_deathgasp')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Звук смерти">
              <Button
                content={data.custom_deathsound || 'По умолч.'}
                icon="music"
                onClick={() => act('set_custom_deathsound')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

      {/* Портреты */}
      <Stack.Item>
        <Section title="Портреты">
          <Stack>
            <Stack.Item grow basis={0}>
              <Section title="В одежде" level={2}>
                <LabeledList>
                  <LabeledList.Item label="Main">
                    <HeadshotButton
                      link={data.headshot_link}
                      onClick={() => act('set_headshot', { slot: '' })}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Alt 1">
                    <HeadshotButton
                      link={data.headshot_link1}
                      onClick={() => act('set_headshot', { slot: '1' })}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Alt 2">
                    <HeadshotButton
                      link={data.headshot_link2}
                      onClick={() => act('set_headshot', { slot: '2' })}
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <Section title="Без одежды" level={2}>
                <LabeledList>
                  <LabeledList.Item label="Main">
                    <HeadshotButton
                      link={data.headshot_naked_link}
                      onClick={() => act('set_naked_headshot', { slot: '' })}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Alt 1">
                    <HeadshotButton
                      link={data.headshot_naked_link1}
                      onClick={() => act('set_naked_headshot', { slot: '1' })}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Alt 2">
                    <HeadshotButton
                      link={data.headshot_naked_link2}
                      onClick={() => act('set_naked_headshot', { slot: '2' })}
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const HeadshotButton = (props: { link?: string; onClick: () => void }) => {
  return (
    <Button
      icon={props.link ? 'image' : 'plus'}
      content={props.link ? 'Изменить' : 'Задать'}
      color={props.link ? undefined : 'transparent'}
      onClick={props.onClick}
    />
  );
};
