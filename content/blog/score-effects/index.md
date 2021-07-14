---
date: "2020-01-15"
diagram: true
image:
  caption: 
  placement: 
markup: mmark
categories: ["hockey analysis"]
math: true
title: Examining Score Effects on Special Teams
---

Score effects in hockey are well-known, whether you're watching the game or looking at numbers: teams that are losing tend to generate a greater share of the shot attempts. Micah Blake McCurdy developed <a href="https://www.hockeyviz.com/txt/senstats" target="_blank">an adjustment method</a> for 5v5 events that is currently used to create the score- and venue-adjusted shot attempt metrics available at hockey stats websites like <a href="http://www.naturalstattrick.com/" target="_blank">Natural Stat Trick</a>
and <a href="https://evolving-hockey.com/" target="_blank">Evolving Hockey</a>.

Since I spend a lot of time looking at special teams data, I have long been curious as to whether score effects might also be a factor for power plays. Here, I've modified Micah's method to investigate score effects at 5v4: I created the weights, compared them to the 5v5 weights, and examined the repeatability and predictivity of the adjusted values compared to the raw ones. Investigating this problem taught me a lot of new R skills, so I've included all code and will go through the process step-by-step. (So if you're only interested in the conclusion, just scroll past the code and look at the graphs!)

### Get and prepare the data

To start, I used the play-by-play query tool available at <a href="https://evolving-hockey.com/" target="_blank">Evolving Hockey</a> to collect all power play events from the past 10 seasons. (This was much quicker than scraping full seasons of data, and if you'd like access to the tool, support them on <a href="https://www.patreon.com/evolvinghockey/" target="_blank">Patreon</a>.) With all of the files in the same folder, instead of reading them in one-by-one, some functions from the plyr package make it easier to read them all in and combine them into one file.

```r

library(plyr)
library(readr)
library(tidyverse)
library(infer)

# All 10 of my csv files (one for each season) are in a folder in my wd called "score_adj"
# This will ID all the files and read them in as one file (score_adj_5v4_raw)

mydir = "score_adj"
myfiles = list.files(path=mydir, pattern="*.csv", full.names=TRUE)
myfiles

score_adj_5v4_raw = ldply(myfiles, read_csv)

```

I filtered down to only the events that I want (all unblocked shot attempts as well as any events with time, so I can create rates) and created some new variables. Per Micah's method, all leads over 2 and below -2 were grouped.

```r

# We'll filter down to only unblocked shot attempts and time events (to get fenwick & rates)
# And also create variables to get the home lead and an indicator whether the event is home or away
# For home lead, everything above 2 and below -2 will be grouped together

score_adj_5v4 <- score_adj_5v4_raw %>%
  filter(event_type %in% c("SHOT", "GOAL", "MISS") | event_length > 0) %>%
  mutate(home_lead = home_score - away_score,
         home_lead = ifelse(home_lead <= -3, -3,
                            ifelse(home_lead >= 3, 3, home_lead)),
         home_away = ifelse(event_team == home_team, "home", "away"),
         fenwick = ifelse(event_type %in% c("SHOT", "GOAL", "MISS"), 1, 0),
         goal = ifelse(event_type == "GOAL", 1, 0),
         PP_team = ifelse(game_strength_state == "5v4", home_team, away_team),
         type = ifelse(fenwick == 1 & PP_team == event_team, "PP", 
                       ifelse(fenwick == 1, "PK", NA)),
         PP_fenwick = ifelse(type == "PP" & fenwick == 1, 1, 0),
         f = ifelse(PP_fenwick == 1, "Y", NA)) %>%
  select(type, PP_fenwick, f, game_strength_state, home_team, away_team, PP_team, event_team, everything())
  
```  

### Create the weights

The first step is to determine what the weights should be. In our raw data, all unblocked shot attempts count the same: as one. But they are not all truly equal since we know that trailing teams generate more shot attempts. If the team that is currently winning by two goals generates a shot attempt, for example, that should count as *more than one* shot attempt because it's more difficult. And vice versa for the team that is currently losing. We can calculate how much these shot attempts should be boosted or penalized by comparing the actual values to the average values (i.e., if there was no difference). 

The first data frame below, `score_adj_f`, just sums the unblocked shot attempts for each state to give us the raw values. (You'll see that the lockout-shortened season is filtered out, we'll discuss why later.) The second data frame `score_adj_f_avg` sums unblocked shot attempts for each *score state* only. Those average values get joined back into the first data frame, and then we can create a weight by dividing the true value by the average. `score_adj_f_reshape` just uses the `pivot_wider` function to reshape the values to make them more readable.

```r

# We filter by power play fenwick events only, then
# group by home_away and home_lead

score_adj_f <- score_adj_5v4 %>%
  filter(PP_fenwick == 1) %>%
  filter(season != 20122013) %>%
  group_by(home_lead, home_away, f) %>%
  summarize(fenwick = sum(PP_fenwick))

# Group by home_lead to get the average fenwicks

score_adj_f_avg <- score_adj_f %>%
  group_by(home_lead) %>%
  summarize(avg = mean(fenwick))

# Join the average back into the previous data frame
# and create the adjusted score by dividing the average by the raw fenwick

score_adj_f <- score_adj_f %>%
  left_join(score_adj_f_avg, by = "home_lead") %>%
  mutate(fenwick_adj = avg / fenwick)

# Reshape to get the numbers in a more readable format

score_adj_f_reshape <- score_adj_f %>%
  select(-c(avg, fenwick)) %>%
  pivot_wider(names_from = home_away, values_from = fenwick_adj) %>%
  select(home_lead, home, away)
  
```

This is what the `score_adj_f` data frame looks like before we reshape it for easier analysis. `fenwick` has the raw values, `avg` has the average values, and `fenwick_adj` has the weights (found by dividing `avg` by `fenwick`).

{{< figure src="adj_avg.png" lightbox="true" >}}

And this is what it looks like after.

{{< figure src="adj.png" lightbox="true" >}}

### Compare to 5v5 weights

Now that we have our weights (shown above), we can compare to Micah's established weights for 5v5 events.

```r

# Read in Micah's 5v5 values
# And join to compare

score_adj_5v5 <- read_csv("score_adj_5v5_MBM.csv")

score_adj_f_reshape_compare <- score_adj_f_reshape %>%
  left_join(score_adj_5v5, by = "home_lead") %>%
  mutate(diff_home = home - home_5v5,
         diff_away = away - away_5v5)

# Create simple bar graphs to compare

ggplot(data = score_adj_f_reshape_compare, 
       aes(x = as.factor(home_lead), y = diff_home)) +
  geom_bar(stat = "identity") +
  labs(title = "Home Event Weights, 5v4 vs 5v5", x = "Home Lead", y = "Difference From 5v5 Weight") +
  theme_linedraw() +
  theme(axis.ticks = element_blank())

ggplot(data = score_adj_f_reshape_compare, 
       aes(x = as.factor(home_lead), y = diff_away)) +
  geom_bar(stat = "identity") +
  labs(title = "Away Event Weights, 5v4 vs 5v5", x = "Home Lead", y = "Difference From 5v5 Weight") +
  theme_linedraw() +
  theme(axis.ticks = element_blank())
  
for_comparison <- score_adj_f_reshape_compare %>%
  select(-c(diff_home:diff_away)) %>%
  rename(home_5v4 = home,
         away_5v4 = away) %>%
  pivot_longer(home_5v4:away_5v5, names_to = "type", values_to = "value") %>%
  mutate(home_away = substr(type, 1, 4),
         state = substr(type, 6, 8))

for_comparison %>%
  filter(home_away == "home") %>%
  ggplot(aes(fill = state, x = as.character(home_lead), y = value)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Home Event Weights, 5v4 vs 5v5", x = "Home Lead", 
       y = "Weight", fill = "State?") +
  theme_linedraw() +
  theme(axis.ticks = element_blank()) +
  geom_hline(yintercept = 1) +
  scale_fill_manual(values = c("#CF8BA8", "#DDDDDD"))

for_comparison %>%
  filter(home_away == "away") %>%
  ggplot(aes(fill = state, x = as.character(home_lead), y = value)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Away Event Weights, 5v4 vs 5v5", x = "Home Lead", 
       y = "Weight", fill = "State?") +
  theme_linedraw() +
  theme(axis.ticks = element_blank()) +
  geom_hline(yintercept = 1) +
  scale_fill_manual(values = c("#CF8BA8", "#DDDDDD"))
  
```

{{< figure src="score_adj_compare_away.png" lightbox="true" >}}

{{< figure src="score_adj_compare_home.png" lightbox="true" >}}

{{< figure src="compare_home.png" lightbox="true" >}}

{{< figure src="compare_away.png" lightbox="true" >}}

We can see from these comparisons that overall, the magnitude of these 5v4 weights is not too different from those at 5v5. The largest difference is when the home team is trailing by one: the 5v5 weight for the away team is 1.103. At 5v4, the weight for the away team is 1.221. (Interestingly, when the home team is *leading* by one, the weights are nearly identical.) This difference fits the overall pattern that you can see in the graphs: the weights for the away team at 5v4 are consistently higher than they are at 5v5, regardless of the score state, and vice versa for the home team. This could suggest that events for the home team are slightly easier to generate at 5v4, regardless of score state, and therefore the away team gets more "credit" (i.e., a higher weight) for their events. 

Our last step, before we can test the repeatability and prediction of the weights, is to join these adjusted values back into the raw event data so we can use them for comparison. 

```r

# Join the adjusted values back into the raw data

score_adj_5v4_w_values <- score_adj_5v4 %>%
  left_join(select(score_adj_f, home_lead, home_away, fenwick_adj, f), by = c("home_lead", "home_away", "f"))

```

### Testing repeatability and prediction

To examine these adjusted values in comparison to the raw ones, we'll look at both *repeatability* and *prediction*. Repeatability is measured by how well the unblocked shot attempts in one sample of a season correlate to those in another sample, and prediction looks at how well the unblocked shot attempts in one sample correlate to *goals* in another.  Our metric of interest in both cases will be R<sup>2</sup>, and we're curious to see whether those R<sup>2</sup> values are *higher* for the adjusted values.

The first step is to create the data set, `sampling_team`, that we'll use for sampling purposes. (Again, we'll filter out the lockout-shortened season.) We'll group by `game_id` as well as `PP_team` and summarize the raw fenwick values, adjusted fenwick values, goals, and total TOI. We'll also create a unique identifier of `team_season` that will be important for sampling purposes. 

```r

# Testing repeatability and prediction----
# We'll test repeatability of the adjusted values, compared to the raw ones
# But we'll be removing the shortened season

# Group by game, season, and team; sum values

sampling_team <- score_adj_5v4_w_values %>%
  select(game_id, season, PP_team, PP_fenwick, fenwick_adj, event_length, goal) %>%
  filter(season != 20122013) %>%
  group_by(season, game_id, PP_team) %>%
  summarize(fenwick = sum(PP_fenwick, na.rm = TRUE),
            fen_adj = sum(fenwick_adj, na.rm = TRUE),
            goals = sum(goal),
            TOI = sum(event_length) / 60) %>%
  unite(team_season, season, PP_team, sep = "-", remove = FALSE)

```

That `sampling_team` data frame will be the starting point for the sampling function I wrote that's based on the `rep_sample_n` function in the `infer` package. In a nutshell, the function below will do the following: filter the `sampling_team` data frame to a specific `team_season`; take a sample of `x` number of games; split that sample into two groups; sum the unblocked shot attempts (both raw and adjusted), goals, and TOI in each group; and repeat 1000 times. The `pivot_wider` function at the end will just reshape the data into a format that's easier to use later.

```r

# The function below will filter by teamseason, sample a specified amount of games, 
# split into two groups, sum fenwick and fen_adj, repeat 1000 times per season

sampling_fn <- function(value, samplesize) {
  
  sampling_team_done <- sampling_team %>%
    filter(team_season == value) %>%
    rep_sample_n(size = samplesize, replace = FALSE, reps = 1000) %>%
    group_by(replicate, team_season) %>%
    mutate(game_no = row_number()) %>%
    mutate(group = game_no %% 2) %>%
    mutate(samplesize = samplesize) %>%
    group_by(replicate, group, team_season, samplesize) %>%
    summarize(fenwick = sum(fenwick, na.rm = TRUE),
              fen_adj = sum(fen_adj, na.rm = TRUE),
              TOI = sum(TOI),
              goals = sum(goals)) %>%
    mutate(f_60 = fenwick * 60 / TOI,
           f_adj_60 = fen_adj * 60 / TOI,
           goal_60 = goals * 60 / TOI) %>%
    pivot_wider(names_from = group, values_from = c(fenwick, fen_adj, TOI, f_60, f_adj_60,
                                                    goals, goal_60))
  
}

```

Once the function is written, we need to apply it! You can see that our `sampling_fn` function requires two arguments to be supplied: `value` and `samplesize`. The `value` is each individual team season, since we want the function to run over each one separately. And I was curious to see how the results vary by the sample size chosen, so the code below will run separately for sample sizes of 40, 50, 60, and 70 games. Micah's 5v5 method was tested with sample sizes of 40 games, but since 5v4 time is comparatively much more rare, I wanted to test larger sample sizes as well. (This is why we eliminated the lockout-shortened season, which only had 48 games.)

`lapply` is a very useful function that will perform the `sampling_fn`, with the selected `samplesize`, over each unique value of `team_season` from the `sampling_team` data frame. And the `bind_rows` function will collect all of the function results into one data frame.

```r

# Run the function for the various sample sizes

summary_team <- lapply(unique(sampling_team$team_season), sampling_fn, samplesize = 40)
sampling_team_40 <- bind_rows(summary_team, .id = "column_label")

summary_team <- lapply(unique(sampling_team$team_season), sampling_fn, samplesize = 50)
sampling_team_50 <- bind_rows(summary_team, .id = "column_label")

summary_team <- lapply(unique(sampling_team$team_season), sampling_fn, samplesize = 60)
sampling_team_60 <- bind_rows(summary_team, .id = "column_label")

summary_team <- lapply(unique(sampling_team$team_season), sampling_fn, samplesize = 70)
sampling_team_70 <- bind_rows(summary_team, .id = "column_label")

```

I will end up with four data frames, `sampling_team_40` through `sampling_team_70` that are all the same size. Here is a sample:

{{< figure src="sampling_team.png" lightbox="true" >}}

`replicate` indicates which sample it is (each individual `team_season` has 1000) and the `_0` and `_1` appended to each metric show the two separate groups. For example, the first row here is one sample of 40 games from the Bruins' 2009-10 season. Those 40 games were divided into two groups: the first group had 111 total unblocked shot attempts, and the second group had 132. Having the data structured this way will allow us to easily calculate the correlations.

We'll create another function to do so, called `correlations`, and use the `lapply` function again to apply that function over our four data frames. 

```r

correlations <- function(df) {
  
  correlation <- df %>%
  group_by(samplesize) %>%
  summarize(raw_f = cor(fenwick_0, fenwick_1) ^ 2,
            adj_f = cor(fen_adj_0, fen_adj_1) ^ 2,
            raw_rate = cor(f_60_0, f_60_1) ^ 2,
            adj_rate = cor(f_adj_60_0, f_adj_60_1) ^ 2,
            raw_f_pred = cor(fenwick_0, goals_1) ^ 2,
            adj_f_pred = cor(fen_adj_0, goals_1) ^ 2,
            raw_rate_pred = cor(f_60_0, goal_60_1) ^ 2,
            adj_rate_pred = cor(f_adj_60_0, goal_60_1) ^ 2)
  
}

cor_all <- lapply(list(sampling_team_40, sampling_team_50, sampling_team_60, sampling_team_70), correlations)
cor <- bind_rows(cor_all)

```

That will result in a very simple data frame that looks like this:

{{< figure src="correlations.png" lightbox="true" >}}

And we can reshape that data to more easily create some graphs.

```r


# Create graphs to compare----
# Reshape data to make it easier

cor_reshape <- cor %>%
  pivot_longer(raw_f:adj_rate_pred, names_to = "metric", values_to = "R2") %>%
  mutate(type = substr(metric, 1, 3)) %>%
  arrange(type) %>%
  mutate(type = factor(type, levels=c("raw", "adj")))

cor_reshape %>%
  filter(metric %in% c("raw_f", "adj_f")) %>%
  ggplot(aes(fill = type, x = samplesize, y = R2)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Repeatability: Unblocked Shot Attempts", x = "Sample Size", 
       y = "R-Squared", fill = "Adjusted?") +
  theme_linedraw() +
  theme(axis.ticks = element_blank()) +
  geom_text(aes(label = round(R2, 3)), position = position_dodge(10),  vjust = -0.5, size = 3) +
  scale_fill_manual(values = c("#DDDDDD", "#CF8BA8"))

cor_reshape %>%
  filter(metric %in% c("raw_rate", "adj_rate")) %>%
  ggplot(aes(fill = type, x = samplesize, y = R2)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Repeatability: Unblocked Shot Attempt Rate", x = "Sample Size", 
       y = "R-Squared", fill = "Adjusted?") +
  theme_linedraw() +
  theme(axis.ticks = element_blank()) +
  geom_text(aes(label = round(R2, 3)), position = position_dodge(10),  vjust = -0.5, size = 3) +
  scale_fill_manual(values = c("#DDDDDD", "#CF8BA8"))

cor_reshape %>%
  filter(metric %in% c("raw_rate_pred", "adj_rate_pred")) %>%
  ggplot(aes(fill = type, x = samplesize, y = R2)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Predictivity: Unblocked Shot Attempt Rate", x = "Sample Size", 
       y = "R-Squared", fill = "Adjusted?") +
  theme_linedraw() +
  theme(axis.ticks = element_blank()) +
  geom_text(aes(label = round(R2, 3)), position = position_dodge(10),  vjust = -0.5, size = 3) +
  scale_fill_manual(values = c("#DDDDDD", "#CF8BA8"))

```

The two figures below show the R<sup>2</sup> values for raw and adjusted values, by sample size, for the unblocked shot attempts and the unblocked shot attempt *rate*, respectively. As expected, the correlation increases along with the sample size. And although none of the R<sup>2</sup> values are particularly large, they are consistently higher for the adjusted values. (As a comparison, Micah found a R<sup>2</sup> value of 0.530 for a similar test with 5v5 adjusted values.)

{{< figure src="repeat_raw.png" lightbox="true" >}}

{{< figure src="repeat_rate.png" lightbox="true" >}}

Also as expected, the R<sup>2</sup> value is much smaller when we look at prediction: how the unblocked shot attempt rate in one group predicts the goal rate in another group. Again as comparison: Micah used goal percentage instead for his prediction test and found a R<sup>2</sup> value of 0.113. 

{{< figure src="pred_rate.png" lightbox="true" >}}

My personal conclusion is that there appears to be some value from adjusting for score effects at 5v4, but I'm not sure it's enough to recommend score adjustment as common practice. For context, I'd also like to explore further into how score effects might affect the rate of drawing or taking penalties.