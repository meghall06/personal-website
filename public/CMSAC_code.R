# Prep----
# Install the betweenthepipes package 

devtools::install_github("meghall06/betweenthepipes")
library(betweenthepipes)

# Load the other necessary packages

library(tidyverse)
library(janitor)
library(lubridate)
library(padr)

# Load the data from betweenthepipes

bio <- bio_example
pbp <- pbp_example
tracking <- track_example

# Some basic data manipulation on our pbp data----

power <- pbp %>%
  # filter to only the power play strength states
  filter(game_strength_state %in% c("5v4", "4v5")) %>%
  # filter to only events that have time associated with them
  filter(event_length > 0) %>%
  # create a new variable that designates the PP team
  mutate(PP_team = ifelse(game_strength_state == "5v4", home_team, away_team)) %>%
  # create a new set of variables to determine who the PP players are
  mutate(PP_1 = ifelse(home_team == PP_team, home_on_1, away_on_1),
         PP_2 = ifelse(home_team == PP_team, home_on_2, away_on_2),
         PP_3 = ifelse(home_team == PP_team, home_on_3, away_on_3),
         PP_4 = ifelse(home_team == PP_team, home_on_4, away_on_4),
         PP_5 = ifelse(home_team == PP_team, home_on_5, away_on_5),
         PP_6 = ifelse(home_team == PP_team, home_on_6, away_on_6))

# Pivot the data

pivot <- power %>%
  # pick the variables that we want
  select(game_id, event_index, PP_team, game_seconds, event_length, home_goalie, away_goalie, PP_1:PP_6) %>%
  # pivot the six player variables
  pivot_longer(PP_1:PP_6, names_to = "on_ice", values_to = "player") %>%
  # filter out the goalies
  filter(player != home_goalie & player != away_goalie) %>%
  # remove the now-unnecessary goalie variables
  select(-c(home_goalie, away_goalie, on_ice))

# Clean up our bio data----

bio <- bio %>%
  # reformat the variable names
  clean_names() %>%
  # use two stringr functions to convert our player names to all uppercase
  # and replace the first space with a period
  mutate(player = str_to_upper(player),
         player = str_replace(player, " ", ".")) %>%
  # record our position variable into a 0/1 variable for forward
  mutate(forward = ifelse(position == "D", 0, 1)) %>%
  # select only these two variables
  select(player, forward)

# Test our join

pivot_position <- pivot %>%
  left_join(bio, by = "player")

fixes <- pivot_position %>%
  filter(is.na(forward)) %>%
  count(player) %>%
  arrange(player)

# Apply those fixes

bio <- bio %>%
  mutate(player = case_when(player == "ALEXANDER.EDLER" ~ "ALEX.EDLER",
                            player == "ALEXANDER.WENNBERG" ~ "ALEX.WENNBERG",
                            player == "CHRISTOPHER.TANEV" ~ "CHRIS.TANEV",
                            TRUE ~ player))

# Run the join again

pivot_position <- pivot %>%
  left_join(bio, by = "player")

# This shouldn't have any observations now

fixes <- pivot_position %>%
  filter(is.na(position)) %>%
  count(player) %>%
  arrange(player)
  
# And now we pivot_wider with our positions

data <- pivot_position %>%
  # first create a basic count variable for each player within a power play
  group_by(game_id, event_index) %>%
  mutate(on_ice = row_number()) %>%
  ungroup() %>%
  # pivot the players and positions
  pivot_wider(names_from = "on_ice", values_from = c("player", "forward")) %>%
  # create a variable to count the number of forwards
  mutate(PP_fwds = select(., forward_1:forward_5) %>% rowSums(na.rm = TRUE)) %>%
  # remove the now-unnecessary variables
  select(-c(player_1:forward_5))

# Clean up the tracking data----

tracking <- tracking %>%
  # create a new variable that converts to m:s
  mutate(time_new = str_sub(time, 1, 5),
         time_new = ms(time_new),
         # create a new variable for total seconds
         seconds = minute(time_new)*60 + second(time_new),
         # create a game_seconds variable to match what's in pbp data
         game_seconds = case_when(game_period == 1 ~ 1200 - seconds,
                                  game_period == 2 ~ 2400 - seconds,
                                  game_period == 3 ~ 3600 - seconds)) %>%
  # remove now-unnecessary variables
  select(-c(time, time_new, seconds, game_period))

# Padding the data----
# Before we can join in our tracking data to our pbp data, we need to 
# "pad" the pbp data so that we have a separate row for each second in the power play

# First, create an ID for each power play

data <- data %>%
  # create an 0/1 variable to identify a new power play
  # and a power_play_count variable
  mutate(new_power_play = ifelse(lag(game_seconds + event_length) == game_seconds & lag(PP_team) == PP_team, 0, 1),
         new_power_play = ifelse(is.na(new_power_play), 1, new_power_play),
         power_play_count = cumsum(new_power_play)) %>%
  select(power_play_count, everything())

# Our test with just one power play

sample <- data %>%
  filter(power_play_count == 1) %>%
  pad_int('game_seconds',
          start_val = 234,
          end_val = 283) %>%
  fill(power_play_count, game_id, PP_team, PP_fwds, .direction = "down")

# Write a function to pad each power play separately

padding_function <- function(count) {
  
  each_power_play <- data %>%
    filter(power_play_count == count)
  
  minimum <- min(each_power_play$game_seconds)
  maximum <- max(each_power_play$game_seconds + each_power_play$event_length - 1)
  
  padded <- each_power_play %>%
    pad_int('game_seconds',
            start_val = minimum,
            end_val = maximum) %>%
    fill(power_play_count, game_id, PP_team, PP_fwds, .direction = "down")
}

# Use map to run the function

data_padded <- map_df(unique(data$power_play_count), padding_function)

# Add in a new variable for the second of each power play
# (counting up from 1)

data_final <- data_padded %>%
  group_by(power_play_count) %>%
  # add in a new variable for the second of 
  # each power play, counting up from 1
  mutate(power_play_second = row_number()) %>%
  ungroup()

# Join in our tracking data----

data_final <- data_final %>%
  left_join(tracking, by = c("game_id", "game_seconds"))

# Question 1:----
# Summarize our data to find the exit rates
# by the number of power play forwards

summary <- data_final %>%
  group_by(PP_fwds) %>%
  summarize(time_on_ice = sum(event_length, na.rm = TRUE) / 60,
            exits = sum(!is.na(event_type))) %>%
  mutate(exit_rate = exits * 60 / time_on_ice)

# Our most basic graph

summary %>%
  ggplot(aes(x = as.character(PP_fwds), y = exit_rate)) +
  geom_bar(stat="identity")

# A graph with added labels

summary %>%
  ggplot(aes(x = as.character(PP_fwds), y = exit_rate)) +
  geom_bar(stat="identity") +
  labs(title = "Rate of zone exits on the power play",
       subtitle = "5v4 only, 4 NHL games November 2019",
       x = "Number of forwards on the power play", 
       y = "Zone exits per 60 minutes") +
  geom_text(aes(label = round(exit_rate, 2)), vjust = 1.6, color = "white", size = 4)

# A graph with added color

summary %>%
  ggplot(aes(x = as.character(PP_fwds), y = exit_rate, fill = as.character(PP_fwds))) +
  geom_bar(stat="identity") +
  labs(title = "Rate of zone exits on the power play",
       subtitle = "5v4 only, 4 NHL games November 2019",
       x = "Number of forwards on the power play", 
       y = "Zone exits per 60 minutes") +
  geom_text(aes(label = round(exit_rate, 2)), vjust = 1.6, color = "white", size = 4) +
  scale_fill_manual(values = c("#808080", "#5C164E")) +
  theme(legend.position = "none")

# Creating a custom theme----

library(showtext)
font_add_google("Open Sans", "opensans")
showtext_auto()

CMSAC_theme <- function () { 
  theme_linedraw(base_size=11, base_family="opensans") %+replace% 
    theme(
      axis.ticks = element_blank(),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_blank(),
      plot.title = element_text(size = 15, hjust = 0, vjust = 0.5, margin = margin(b = 0.2, unit = "cm")),
      plot.subtitle = element_text(size = 9, face = "italic", hjust = 0, vjust = 0.5, margin = margin(b = 0.2, unit = "cm")),
      axis.title = element_text(face = "bold"))
}

# A graph with our theme

summary %>%
  ggplot(aes(x = as.character(PP_fwds), y = exit_rate, fill = as.character(PP_fwds))) +
  geom_bar(stat="identity") +
  labs(title = "Rate of zone exits on the power play",
       subtitle = "5v4 only, 4 NHL games November 2019",
       x = "Number of forwards on the power play", 
       y = "Zone exits per 60 minutes") +
  geom_text(aes(label = round(exit_rate, 2)), vjust = 1.6, color = "white", size = 4) +
  scale_fill_manual(values = c("#808080", "#912919")) +
  CMSAC_theme()
  
# Question 2: 
# How does the power play composition change over the time of the power play?

# Summarize our data

time <- data_final %>%
  group_by(power_play_second, PP_fwds) %>%
  summarize(n = n()) %>%
  add_tally(n, name = "total") %>%
  mutate(percent = n / total)

# Create a graph

time %>%
  mutate(PP_fwds = ifelse(PP_fwds == 3, "3 forwards", "4 forwards")) %>%
  ggplot(aes(x = power_play_second, y = percent, fill = PP_fwds)) + 
  geom_area() +
  labs(title = "Composition of the power play",
       subtitle = "5v4 only, 4 NHL games November 2019",
       x = "Second of the power play") +
  scale_fill_manual(values = c("#808080", "#912919")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     expand = c(0, 0)) +
  scale_x_continuous(limits = c(1, 120),
                     breaks = seq(0, 120, 20),
                     expand = c(0, 0)) +
  CMSAC_theme() +
  theme(legend.position = c(0.87, 1.106),
        legend.title = element_blank(),
        axis.title.y = element_blank())
