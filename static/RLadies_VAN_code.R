# install the package from github
devtools::install_github("meghall06/betweenthepipes")

# load the libraries
library(betweenthepipes)
library(tidyverse)

# add the data from the package to the global environment
pbp <- pbp_example

# 1. goalie save percentage

pbp %>% 
  filter(event_type %in% c("GOAL","SHOT")) %>% 
  mutate(event_goalie = case_when(
    event_team == home_team ~ away_goalie,
    event_team == away_team ~ home_goalie),
    save = ifelse(event_type == "SHOT", 1, 0)) %>% 
  select(event_goalie, event_type, save) %>% 
  group_by(event_goalie) %>% 
  summarize(saves = sum(save),
            all_shots = n()) %>% 
  arrange(desc(all_shots)) %>% 
  mutate(save_perc = saves / all_shots)

# 2. team faceoff percentage

pbp %>% 
  filter(event_type == "FAC") %>% 
  mutate(loser = case_when(event_team == home_team ~ away_team,
                           event_team == away_team ~ home_team)) %>% 
  select(event_index, event_type, winner = event_team, loser) %>% 
  pivot_longer(winner:loser,
               names_to = "result", values_to = "team") %>% 
  mutate(win = ifelse(result == "winner", 1, 0)) %>%
  group_by(team) %>%
  summarize(wins = sum(win),
            faceoffs = n()) %>%
  mutate(fo_perc = wins / faceoffs)

# 3. invididual plus-minus

pbp %>% 
  filter(game_strength_state == "5v5" & event_type == "GOAL") %>% 
  select(event_index, event_type, event_team, home_team, 
         away_team, home_goalie, away_goalie, contains("_on_")) %>% 
  rename_at(vars(contains("_on_")), ~str_replace(., "on_", "")) %>% 
  pivot_longer(-c(starts_with("event")), names_to = c("home_away", ".value"), names_sep = "_") %>% 
  pivot_longer(`1`:`7`, names_to = NULL, values_to = "player", values_drop_na = TRUE) %>% 
  filter(player != goalie) %>% 
  mutate(plus_minus = ifelse(event_team == team, 1, -1)) %>% 
  group_by(player, team) %>% 
  summarize(plus_minus = sum(plus_minus)) %>% 
  arrange(desc(abs(plus_minus)))

# 4. player points

pbp %>% 
  filter(event_type == "GOAL") %>% 
  select(event_type, starts_with("event_player")) %>% 
  pivot_longer(starts_with("event_player"), names_to = NULL, values_to = "player", values_drop_na = TRUE) %>% 
  group_by(player) %>% 
  summarize(points = n()) %>% 
  arrange(desc(points))

# 5. standings points per team per game
# a win is two points, a loss in overtime or shootout (which are indicated
# with game_period of 4 and 5, respectively) is one point, a regulation loss is zero points

pbp %>% 
  select(game_id, game_period, home_team, away_team, home_score, away_score) %>% 
  group_by(game_id, home_team, away_team) %>% 
  summarize(period = max(game_period),
            home_score = max(home_score),
            away_score = max(away_score)) %>% 
  mutate(home_winner = ifelse(home_score > away_score, "yes", "no"),
         away_winner = ifelse(away_score > home_score, "yes", "no")) %>% 
  pivot_longer(-c(game_id, period), names_to = c("home_away", ".value"), names_sep = "_") %>% 
  mutate(standings_points = case_when(winner == "yes" ~ 2,
                                      winner == "no" & period > 3 ~ 1,
                                      TRUE ~ 0))

# 6. average TOI

pbp %>% 
  select(game_id, event_length, home_goalie, away_goalie, contains("_on_")) %>% 
  pivot_longer(contains("_on_"), names_to = NULL, values_to = "player", values_drop_na = TRUE) %>% 
  filter(player != home_goalie & player != away_goalie) %>% 
  group_by(player) %>% 
  summarize(games = n_distinct(game_id),
            TOI = sum(event_length) / 60) %>% 
  mutate(avg_TOI = TOI / games) %>% 
  arrange(desc(avg_TOI))


