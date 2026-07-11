import { useRef, useState, useEffect } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dimmer,
  Divider,
  Icon,
  Input,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

const FOOD_CATEGORIES = new Set([
  'Foods', 'Breads', 'Burgers', 'Cakes', 'Donuts',
  'Egg-Based Food', 'Ice', 'Meats', 'Mexican',
  'Misc. Food', 'Pastries', 'Pies & Sweets', 'Pizzas',
  'Salads', 'Seafood', 'Sandwiches', 'Soups', 'Spaghettis',
  'East foods', 'Drinks',
]);

const CATEGORY_ICONS = {
  'Can Make': 'hammer',
  Weaponry: 'hand-fist',
  'Melee Weapons': 'hand-fist',
  'Ranged Weapons': 'gun',
  Ammunition: 'box',
  'Weapon Parts': 'gear',
  Robots: 'robot',
  Miscellaneous: 'shapes',
  'Tools & Storage': 'screwdriver-wrench',
  Furniture: 'chair',
  Tribal: 'campground',
  Clothing: 'shirt',
  Foods: 'utensils',
  Drinks: 'wine-bottle',
  Atmospherics: 'fan',
  'Gas Crystals': 'gem',
  'East foods': 'drumstick-bite',
  Breads: 'bread-slice',
  Burgers: 'burger',
  Cakes: 'cake-candles',
  Donuts: 'cookie',
  'Egg-Based Food': 'egg',
  Meats: 'bacon',
  Mexican: 'pepper-hot',
  'Misc. Food': 'shapes',
  Pastries: 'cookie',
  'Pies & Sweets': 'chart-pie',
  Pizzas: 'pizza-slice',
  Salads: 'leaf',
  Seafood: 'fish',
  Sandwiches: 'hotdog',
  Soups: 'mug-hot',
  Spaghettis: 'wheat-awn',
  Frozen: 'ice-cream',
  Structures: 'cube',
  Tiles: 'border-all',
  Windows: 'person-through-window',
  Doors: 'door-open',
  Equipment: 'calculator',
  Containers: 'briefcase',
  Tools: 'tools',
  Entertainment: 'masks-theater',
  Gardening: 'seedling',
  Decor: 'tree',
  Chemistry: 'microscope',
};

const PAGE_SIZE = 20;

function isCook(mode) {
  return mode === 1 || mode === true;
}

function getCategories(crafting_recipes, mode) {
  const cook = isCook(mode);
  const categories = [];
  for (const category of Object.keys(crafting_recipes)) {
    if (cook !== FOOD_CATEGORIES.has(category)) {
      continue;
    }
    const subcategories = crafting_recipes[category];
    if ('has_subcats' in subcategories) {
      for (const subcategory of Object.keys(subcategories)) {
        if (subcategory === 'has_subcats') {
          continue;
        }
        categories.push({
          id: category + '::' + subcategory,
          name: subcategory,
          category,
          subcategory,
        });
      }
    } else {
      categories.push({
        id: category + '::',
        name: category,
        category,
      });
    }
  }
  return categories;
}

function getRecipes(crafting_recipes, mode) {
  const cook = isCook(mode);
  const recipes = [];
  for (const category of Object.keys(crafting_recipes)) {
    if (cook !== FOOD_CATEGORIES.has(category)) {
      continue;
    }
    const subcategories = crafting_recipes[category];
    if ('has_subcats' in subcategories) {
      for (const subcategory of Object.keys(subcategories)) {
        if (subcategory === 'has_subcats') {
          continue;
        }
        const _recipes = subcategories[subcategory];
        for (const recipe of _recipes) {
          recipes.push({ ...recipe, tabId: category + '::' + subcategory });
        }
      }
    } else {
      const _recipes = crafting_recipes[category];
      for (const recipe of _recipes) {
        recipes.push({ ...recipe, tabId: category + '::' });
      }
    }
  }
  return recipes;
}

export function PersonalCrafting() {
  const { act, data } = useBackend();
  const {
    busy,
    mode,
    display_craftable_only,
    display_compact,
    crafting_recipes = {},
    craftability = {},
  } = data;

  const [searchQuery, setSearchQuery] = useState('');
  const [tab, setTab] = useState('');
  const [page, setPage] = useState(1);
  const searchTimer = useRef(null);

  const categories = getCategories(crafting_recipes, mode);
  const allRecipes = getRecipes(crafting_recipes, mode);
  const query = searchQuery.trim().toLowerCase();
  const isSearching = query.length > 0;

  useEffect(() => {
    if (categories.length > 0 && !tab) {
      const firstCat = categories[0];
      setTab(firstCat.id);
      act('set_category', {
        category: firstCat.category,
        subcategory: firstCat.subcategory,
      });
    }
    act('search', { query: '' });
  }, []);

  useEffect(() => {
    return () => {
      if (searchTimer.current) {
        clearTimeout(searchTimer.current);
      }
    };
  }, []);

  const handleSearch = (value) => {
    setSearchQuery(value);
    setPage(1);
    if (searchTimer.current) {
      clearTimeout(searchTimer.current);
    }
    const trimmed = value.trim();
    searchTimer.current = setTimeout(() => {
      act('search', { query: trimmed });
    }, 200);
  };

  const clearSearch = () => {
    setSearchQuery('');
    setPage(1);
    if (searchTimer.current) {
      clearTimeout(searchTimer.current);
    }
    act('search', { query: '' });
  };

  const handleTabClick = (cat) => {
    setTab(cat.id);
    setPage(1);
    act('set_category', {
      category: cat.category,
      subcategory: cat.subcategory,
    });
  };

  let nameMatches = [];
  let ingredientMatches = [];
  let shownRecipes = [];

  if (isSearching) {
    nameMatches = allRecipes.filter(
      (r) => r.name?.toLowerCase().includes(query),
    );
    ingredientMatches = allRecipes.filter(
      (r) => r.req_text?.toLowerCase().includes(query),
    );
  } else {
    shownRecipes = allRecipes.filter((r) => r.tabId === tab);
  }

  return (
    <Window title="Crafting Menu" width={700} height={800}>
      <Window.Content>
        <Stack fill vertical>
          {!!busy && (
            <Dimmer fontSize="32px">
              <Icon color="blue" name="cog" spin={1} />
              {' Crafting...'}
            </Dimmer>
          )}
          <Stack.Item grow={1}>
            <Stack fill>
              <Stack.Item width="180px">
                <Section fill scrollable>
                  <Stack fill vertical>
                    <Stack.Item>
                      <Stack>
                        <Stack.Item grow>
                          <Input
                            fluid
                            placeholder="Search recipes..."
                            value={searchQuery}
                            onInput={(e, value) => handleSearch(value)}
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="times"
                            disabled={!searchQuery}
                            color="transparent"
                            onClick={clearSearch}
                            tooltip="Clear search"
                          />
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Tabs vertical>
                        {categories.map((cat) => (
                          <Tabs.Tab
                            key={cat.id}
                            selected={cat.id === tab && !isSearching}
                            onClick={() => handleTabClick(cat)}
                          >
                            <Stack align="center">
                              <Stack.Item width="16px" textAlign="center">
                                <Icon
                                  name={
                                    CATEGORY_ICONS[cat.name]
                                    || CATEGORY_ICONS[cat.category]
                                    || 'circle'
                                  }
                                />
                              </Stack.Item>
                              <Stack.Item grow ml={1}>
                                {cat.name}
                              </Stack.Item>
                            </Stack>
                          </Tabs.Tab>
                        ))}
                      </Tabs>
                    </Stack.Item>
                    <Stack.Item>
                      <Divider />
                      <Button.Checkbox
                        fluid
                        checked={display_craftable_only}
                        onClick={() => act('toggle_recipes')}
                      >
                        Can make
                      </Button.Checkbox>
                      <Button.Checkbox
                        fluid
                        checked={display_compact}
                        onClick={() => act('toggle_compact')}
                      >
                        Compact
                      </Button.Checkbox>
                      <Divider />
                      <Stack textAlign="center">
                        <Stack.Item grow>
                          <Button.Checkbox
                            fluid
                            lineHeight={2}
                            checked={!isCook(mode)}
                            icon="hammer"
                            style={{
                              border: '2px solid ' + (!isCook(mode) ? '#20b142' : '#333'),
                            }}
                            onClick={() => isCook(mode) && act('toggle_mode')}
                          >
                            Craft
                          </Button.Checkbox>
                        </Stack.Item>
                        <Stack.Item grow>
                          <Button.Checkbox
                            fluid
                            lineHeight={2}
                            checked={isCook(mode)}
                            icon="utensils"
                            style={{
                              border: '2px solid ' + (isCook(mode) ? '#20b142' : '#333'),
                            }}
                            onClick={() => !isCook(mode) && act('toggle_mode')}
                          >
                            Cook
                          </Button.Checkbox>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item grow ml={0.5}>
                {isSearching ? (
                  <Section fill scrollable>
                    <SearchResults
                      nameMatches={nameMatches}
                      ingredientMatches={ingredientMatches}
                      craftability={craftability}
                      display_craftable_only={display_craftable_only}
                      display_compact={display_compact}
                    />
                  </Section>
                ) : (
                  <Section fill scrollable>
                    <RecipeList
                      recipes={shownRecipes}
                      craftability={craftability}
                      display_craftable_only={display_craftable_only}
                      display_compact={display_compact}
                      page={page}
                      onLoadMore={() => setPage(page + 1)}
                    />
                  </Section>
                )}
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

function SearchResults(props) {
  const {
    nameMatches,
    ingredientMatches,
    craftability,
    display_craftable_only,
    display_compact,
  } = props;

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section title={'Name matches (' + nameMatches.length + ')'}>
          <RecipeList
            recipes={nameMatches}
            craftability={craftability}
            display_craftable_only={display_craftable_only}
            display_compact={display_compact}
          />
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section
          title={'Ingredient matches (' + ingredientMatches.length + ')'}
        >
          <RecipeList
            recipes={ingredientMatches}
            craftability={craftability}
            display_craftable_only={display_craftable_only}
            display_compact={display_compact}
          />
        </Section>
      </Stack.Item>
    </Stack>
  );
}

function RecipeList(props) {
  const {
    recipes = [],
    craftability = {},
    display_craftable_only,
    display_compact,
    page,
    onLoadMore,
  } = props;
  const { act } = useBackend();

  let visible = recipes;
  if (display_craftable_only) {
    visible = visible.filter((r) => craftability[r.ref]);
  }

  const displayLimit = page ? page * PAGE_SIZE : visible.length;
  const paged = visible.slice(0, displayLimit);

  return (
    <Box>
      {paged.length === 0 && (
        <Box color="gray" textAlign="center" py={2}>
          No recipes found.
        </Box>
      )}
      {paged.map((recipe) =>
        display_compact ? (
          <CompactRecipe
            key={recipe.ref}
            recipe={recipe}
            canCraft={craftability[recipe.ref]}
          />
        ) : (
          <FullRecipe
            key={recipe.ref}
            recipe={recipe}
            canCraft={craftability[recipe.ref]}
          />
        ),
      )}
      {onLoadMore && visible.length > displayLimit && (
        <Section textAlign="center">
          <Button
            onClick={onLoadMore}
            icon="chevron-down"
            tooltip={
              'Show ' + Math.min(PAGE_SIZE, visible.length - displayLimit) + ' more'
            }
          >
            Load more ({visible.length - displayLimit} left)
          </Button>
        </Section>
      )}
    </Box>
  );
}

function GroupTitle(props) {
  return (
    <Stack my={0.5}>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
      <Stack.Item color="gray">{props.title}</Stack.Item>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
    </Stack>
  );
}

function FullRecipe(props) {
  const { recipe, canCraft } = props;
  const { act } = useBackend();

  return (
    <Section>
      <Stack>
        {!!recipe.icon_data && (
          <Stack.Item>
            <Box textAlign="center" minWidth="48px" minHeight="48px" mr={1}>
              <img
                src={"data:image/png;base64," + recipe.icon_data}
                style={{
                  width: '48px',
                  height: '48px',
                  imageRendering: 'pixelated',
                }}
              />
            </Box>
          </Stack.Item>
        )}
        <Stack.Item grow>
          <Stack>
            <Stack.Item grow>
              <Box bold mb={0.5}>
                {recipe.name}
              </Box>
              {!!recipe.desc && (
                <Box color="gray" mb={0.5}>
                  {recipe.desc}
                </Box>
              )}
              {recipe.reqs_detail?.length > 0 && (
                <>
                  <GroupTitle title="Materials" />
                  {recipe.reqs_detail.map((req, i) => (
                    <Stack key={i} align="center" my={0.25}>
                      {!!req.icon_data && (
                        <Stack.Item mr={0.5}>
                          <img
                            src={"data:image/png;base64," + req.icon_data}
                            loading="lazy"
                            style={{
                              width: '24px',
                              height: '24px',
                              verticalAlign: 'middle',
                              imageRendering: 'pixelated',
                            }}
                          />
                        </Stack.Item>
                      )}
                      <Stack.Item>
                        {req.name}
                        {req.amount > 1
                          ? '\u00a0' + req.amount + 'x'
                          : ''}
                      </Stack.Item>
                    </Stack>
                  ))}
                </>
              )}
              {recipe.catalysts_detail?.length > 0 && (
                <>
                  <GroupTitle title="Catalysts" />
                  {recipe.catalysts_detail.map((cat, i) => (
                    <Stack key={i} align="center" my={0.25}>
                      {!!cat.icon_data && (
                        <Stack.Item mr={0.5}>
                          <img
                            src={"data:image/png;base64," + cat.icon_data}
                            loading="lazy"
                            style={{
                              width: '24px',
                              height: '24px',
                              verticalAlign: 'middle',
                              imageRendering: 'pixelated',
                            }}
                          />
                        </Stack.Item>
                      )}
                      <Stack.Item>
                        {cat.name}
                        {cat.amount > 1
                          ? '\u00a0' + cat.amount + 'x'
                          : ''}
                      </Stack.Item>
                    </Stack>
                  ))}
                </>
              )}
              {recipe.tools_detail?.length > 0 && (
                <>
                  <GroupTitle title="Tools" />
                  {recipe.tools_detail.map((tool, i) => (
                    <Stack key={i} align="center" my={0.25}>
                      {!!tool.icon_data && (
                        <Stack.Item mr={0.5}>
                          <img
                            src={"data:image/png;base64," + tool.icon_data}
                            loading="lazy"
                            style={{
                              width: '24px',
                              height: '24px',
                              verticalAlign: 'middle',
                              imageRendering: 'pixelated',
                            }}
                          />
                        </Stack.Item>
                      )}
                      <Stack.Item>{tool.name}</Stack.Item>
                    </Stack>
                  ))}
                </>
              )}
            </Stack.Item>
            <Stack.Item pl={1}>
              <Stack vertical>
                <Stack.Item>
                  <Button
                    lineHeight={2.5}
                    align="center"
                    fluid
                    disabled={!canCraft}
                    icon="cog"
                    color={canCraft ? 'green' : 'default'}
                    onClick={() => act('make', { recipe: recipe.ref })}
                  >
                    Craft
                  </Button>
                </Stack.Item>
                {!!recipe.complexity && (
                  <Stack.Item>
                    <Box color="gray" mt={0.5}>
                      Complexity: {recipe.complexity}
                    </Box>
                  </Stack.Item>
                )}
              </Stack>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function CompactRecipe(props) {
  const { recipe, canCraft } = props;
  const { act } = useBackend();

  return (
    <LabeledList.Item
      className="candystripe"
      label={
        <Stack align="center" inline>
          {!!recipe.icon_data && (
            <Stack.Item mr={1}>
              <img
                src={"data:image/png;base64," + recipe.icon_data}
                style={{
                  width: '32px',
                  height: '32px',
                  verticalAlign: 'middle',
                  imageRendering: 'pixelated',
                }}
              />
            </Stack.Item>
          )}
          <Stack.Item>
            <Box
              color={canCraft ? 'good' : 'bad'}
              inline
            >
              {recipe.name}
            </Box>
          </Stack.Item>
        </Stack>
      }
      buttons={
        <Button
          icon="cog"
          content="Craft"
          disabled={!canCraft}
          color={canCraft ? 'green' : 'default'}
          tooltip={
            recipe.tool_text
              ? 'Tools: ' + recipe.tool_text
              : undefined
          }
          tooltipPosition="left"
          onClick={() => act('make', { recipe: recipe.ref })}
        />
      }
    >
      <Box color="gray" inline>
        {recipe.req_text}
      </Box>
    </LabeledList.Item>
  );
}
