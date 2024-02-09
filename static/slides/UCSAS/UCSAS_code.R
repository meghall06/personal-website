library(tidyverse)
library(janitor)
library(hockeyR)
library(sportyR)
library(gt)
library(gtExtras)
library(ggtext)

# Reading in the necessary data: uncomment your desired option
# You can get the sample files directly from my Github (option 1)
# Or scrape using the hockeyR package (option 2)

# Option 1
# pbp <- read_csv("https://raw.githubusercontent.com/meghall06/personal-website/master/static/slides/UCSAS/pbp.csv")
# roster <- read_csv("https://raw.githubusercontent.com/meghall06/personal-website/master/static/slides/UCSAS/roster.csv")

# Option 2:
# pbp <- scrape_day(day = "2021-02-27")
# roster <- get_rosters(team = "all", season = 2021)

# 1. Data manipulation----

powerplay <- pbp %>% 
  # create a variable to determine the length of the event and a variable to specify the PP team
  mutate(length = lead(period_seconds) - period_seconds,
         PP_team = case_when((event_team_type == "home" & strength_state == "5v4") |
                             (event_team_type == "away" & strength_state == "4v5") ~ home_abbreviation,
                             TRUE ~ away_abbreviation)) %>% 
  filter(strength_state %in% c("5v4","4v5") & (length > 0 | event_type %in% c("GOAL","SHOT"))) %>% 
  select(event_type, event_team_abbr, event_team_type, home_abbreviation, away_abbreviation, PP_team,
         length, strength_state, x:y_fixed, home_on_1:away_on_7, event_idx, game_id, period) %>% 
  remove_empty("cols")

# Pivot to change level of observation: one row per event to one row per player

player <- powerplay %>% 
  mutate(PP_1 = ifelse(PP_team == home_abbreviation, home_on_1, away_on_1),
         PP_2 = ifelse(PP_team == home_abbreviation, home_on_2, away_on_2),
         PP_3 = ifelse(PP_team == home_abbreviation, home_on_3, away_on_3),
         PP_4 = ifelse(PP_team == home_abbreviation, home_on_4, away_on_4),
         PP_5 = ifelse(PP_team == home_abbreviation, home_on_5, away_on_5)) %>% 
  select(game_id, event_idx, contains("PP"), length) %>% 
  pivot_longer(PP_1:PP_5, values_to = "player")
  
# Data manipulation for position data

position <- roster %>% 
  select(player, position) %>% 
  unique()

position %>% 
  get_dupes(player)

position <- position %>% 
  filter(!(player == "Sebastian Aho" & position == "D"))

position <- position %>% 
  mutate(player = str_replace_all(player, " ", "."),
         player = str_replace_all(player, "-", "."),
         player = str_replace_all(player, "'", "."))

# See who the mismatches are and fix

player %>% 
  left_join(position, by = "player") %>% 
  filter(is.na(position)) %>% 
  select(player) %>% 
  unique()

position <- position %>% 
  mutate(player = case_when(player == "Joshua.Norris" ~ "Josh.Norris",
                            player == "Mitch.Marner" ~ "Mitchell.Marner",
                            player == "Callan.Foote" ~ "Cal.Foote",
                            player == "Nicholas.Caamano" ~ "Nick.Caamano",
                            player == "Alexander.Wennberg" ~ "Alex.Wennberg",
                            player == "Dominik.Kubalík" ~ "Dominik.Kubalik",
                            player == "Mathew.Dumba" ~ "Matt.Dumba",
                            TRUE ~ player))

# Join in the position data to the player-level data and create a 0/1 variable for forwards

player <- player %>% 
  left_join(position, by = "player") %>% 
  mutate(forward = ifelse(str_detect(position, "D"), 0, 1))

# Aggregate data to find the position structure breakdown for each team

fwd <- player %>% 
  # group the data by event
  group_by(game_id, event_idx, PP_team) %>% 
  summarize(fwds = sum(forward),
            length = mean(length)) %>% 
  # group again by position structure and team
  group_by(PP_team, fwds) %>% 
  summarize(time = sum(length)) %>% 
  # add the total time to serve as denominator
  add_tally(time, n = "total_time") %>% 
  # calculate the percentage
  mutate(perc = time / total_time) %>% 
  # filter to our group of interest
  filter(fwds == 4)

# 2. Visualizations----

# Get the team logo data from hockeyR and join in the team logo and main team color

logos <- team_logos_colors

fwd <- fwd %>% 
  left_join(select(logos, team_abbr, team_logo_espn, team_color1), by = c("PP_team" = "team_abbr"))

# Creating a table with gt

fwd %>% 
  ungroup() %>% 
  select(team_logo_espn, perc) %>% 
  arrange(desc(perc)) %>% 
  gt() %>% 
  tab_header(title = "Percentage of 5v4 Power Play Time With Four Forwards",
             subtitle = "Draw no conclusions, this is one night of games!") %>%
  gt_img_rows(columns = team_logo_espn, height = 25) %>% 
  fmt_percent(perc, decimals = 0) %>% 
  gt_color_rows(perc,
                palette = "ggsci::blue_grey_material") %>% 
  opt_table_font(font = google_font(name = "Ubuntu")) %>% 
  tab_options(table.font.size = 12,
              heading.title.font.size = 14,
              table.width = px(250),
              column_labels.hidden = TRUE,
              data_row.padding = px(1),
              table_body.hlines.width = 0,
              table.border.top.color = 'black',
              table.border.top.width = 2,
              heading.border.bottom.color = 'black',
              heading.border.bottom.width = 2,
              table_body.border.bottom.color = 'black',
              table_body.border.bottom.width = 2)

# Creating a bar graph with ggplot2

fwd %>% 
  ggplot(aes(x = perc, y = reorder(PP_team, perc))) +
  geom_bar(stat = "identity", fill = fwd$team_color1) +
  scale_x_continuous(label = scales::percent,
                     expand = expansion(mult = c(0, 0.05))) +
  labs(x = NULL, y = NULL,
       title = "Percentage of 5v4 power play time with four forwards",
       subtitle = "Games on Feb. 27, 2021") +
  theme_linedraw() +
  theme(plot.title.position = "plot")

# Filtering to power play goals and shots on goal only

PP_shots <- powerplay %>% 
  filter(event_type %in% c("SHOT","GOAL") & event_team_abbr == PP_team) %>% 
  mutate(x_rotate = ifelse(x > 0, x * -1, x),
         y_rotate = ifelse(x > 0, y * -1, y)) %>% 
  arrange(desc(event_type))

# Using sportyR to create a shot plot

geom_hockey("nhl", full_surf = FALSE) +
  geom_point(data = PP_shots, aes(x = x_rotate, y = y_rotate),
             size = 6,
             color = ifelse(PP_shots$event_type == "GOAL", "#661414", "#A9A9A9"),
             alpha = ifelse(PP_shots$event_type == "GOAL", 1, 0.5)) +
  labs(title = "Shots and <span style = 'color:#661414;'>**goals**</span> on the 5v4 power play",
    subtitle = "On the night of February 27, 2021",
    caption = "Data from hockeyR & plot made with sportyR by @MeghanMHall") +
  theme(plot.title = element_markdown(hjust = 0.5, vjust = 0.5, size = 16),
        plot.subtitle = element_text(hjust = 0.5, face = "italic"),
        plot.caption = element_text(hjust = 0.5))
