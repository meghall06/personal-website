---
title: "Exploring tidymodels With Hockey Data"
diagram: yes
date: '2020-03-09'
markup: mmark
math: yes
categories: ["tutorials"]
image:
  caption: null
  placement: null
---

Before we start, an important disclaimer: this is *not* a tutorial on how to thoughtfully build and thoroughly evaluate models. This is a gentle introduction to the `tidymodels` package (which, like the `tidyverse`, is actually a collection of packages), and in order to examine various functions and capabilities of those packages, we'll build two very simple models, using easily available NHL data, and go over a few ways to evaluate them.

The `tidymodels` package, which is fairly new, was designed to make it easier to create your model framework in a tidy way and consists of, among others, `recipes` (prepping models), `parsnip` (executing models), and `yardstick` (evaluating models). Here, we'll build two simple models to predict whether an NHL player is a forward or a defenseman.

### Find and prepare the data

First, let's get our data prepped—we're using 2018-19 data so we can have a full season. We'll get the position data by downloading from <a href="http://www.naturalstattrick.com/playerteams.php?fromseason=20182019&thruseason=20182019&stype=2&sit=5v5&score=all&stdoi=bio&rate=n&team=ALL&pos=S&loc=B&toi=0&gpfilt=none&fd=&td=&tgp=410&lines=single&draftteam=ALL" target="_blank">Natural Stat Trick</a>, and we'll create our statistics from the raw play-by-play data, available via the <a href="https://twitter.com/EvolvingWild/status/1163503829993828353" target="_blank">Evolving Wild scraper</a>. (Could you download all these summary statistics from NST instead? Definitely. But this is about learning, and it's great R practice [pRactice?] to generate them yourself from the play-by-play data.)

{{% alert note %}}
One of the `tidymodels` packages called `dials` has a `margin()` function that will mask the `margin()` function in `ggplot2`. If you use the `margin()` function in your `ggplot2` custom theme like I do, just load `tidymodels` before `tidyverse` and you should be fine.
{{% /alert %}}

```r

library(tidymodels)
library(tidyverse)

# Read in files (pbp from Evolving Hockey, bios from Natural Stat Trick)

pbp <- read_csv("pbp_20182019_all.csv")
bios <- read_csv("bios_1819.csv")

# Find player TOI and games played
# To do so, you must pivot the data so there is one row per player
# (instead of one row per event)
# We don't care about the ice time for the goalies (sorry, goalies)
# so they will be filtered out
# We also do some name changes to make things easier later

player_TOI <- pbp %>%
  filter(event_length > 0) %>%
  select(game_id, event_length, home_on_1:away_goalie) %>%
  pivot_longer(home_on_1:away_on_6, names_to = "variable", values_to = "player") %>%
  filter(!(is.na(player)) & player != home_goalie & player != away_goalie) %>%
  mutate(player = case_when(
    player == "COLIN.WHITE2" ~ "COLIN.WHITE",
    player == "ERIK.GUSTAFSSON2" ~ "ERIK.GUSTAFSSON",
    player == "PATRICK.MAROON" ~ "PAT.MAROON",
    TRUE ~ player
  )) %>%
  group_by(player) %>%
  summarize(games = n_distinct(game_id),
            TOI = sum(event_length) / 60)

# Find basic player stats
# To find individual stats, we again need to pivot the data to one row per player
# but we're using the event_players only (not the on ice players)
# You'll notice we're filtering out the shootout (which is game_period 5) because
# those goals don't count
# We'll sum up blocked shots (event_player_2 is the player who blocked the shot,
# event_player_1 is the one who generated it), total points, shots, unblocked shots,
# hits (both give nand received)

player_stats <- pbp %>%
  filter(event_type %in% c("HIT", "BLOCK", "SHOT", "MISS", "GOAL") & game_period < 5) %>%
  select(game_id, event_type, event_player_1:event_player_3) %>%
  pivot_longer(event_player_1:event_player_3, names_to = "number", values_to = "player") %>%
  filter(!(is.na(player))) %>%
  mutate(block = ifelse(event_type == "BLOCK" & number == "event_player_2", 1, 0),
         point = ifelse(event_type == "GOAL", 1, 0),
         shot = ifelse(number == "event_player_1" & event_type %in% c("SHOT", "GOAL"), 1, 0),
         fenwick = ifelse(number == "event_player_1" & event_type %in% c("SHOT", "GOAL", "MISS"), 1, 0),
         hit = ifelse(number == "event_player_1" & event_type == "HIT", 1, 0),
         hit_rec = ifelse(number == "event_player_2" & event_type == "HIT", 1, 0),
         player = case_when(
           player == "COLIN.WHITE2" ~ "COLIN.WHITE",
           player == "ERIK.GUSTAFSSON2" ~ "ERIK.GUSTAFSSON",
           player == "PATRICK.MAROON" ~ "PAT.MAROON",
           TRUE ~ player
         )) %>%
  group_by(player) %>%
  summarize(blocks = sum(block),
            points = sum(point),
            shots = sum(shot),
            fenwick = sum(fenwick),
            hits = sum(hit),
            hits_rec = sum(hit_rec))

# Join stats into TOI data frame and create rates

player_TOI_stats <- player_TOI %>%
  left_join(player_stats, by = "player") %>%
  mutate(points_60 = points * 60 / TOI,
         shots_60 = shots * 60 / TOI,
         fenwick_60 = fenwick * 60 / TOI,
         hits_60 = hits * 60 / TOI,
         hits_rec_60 = hits_rec * 60 / TOI,
         blocks_60 = blocks * 60 / TOI,
         TOI_game = TOI / games) %>%
  select(-c(blocks:hits_rec))

# Clean up the biographical data

bios <- bios %>%
  mutate(player = str_to_upper(Player),
         player = str_replace(player, " ", "."),
         defense = ifelse(Position == "D", "D", "F")) %>%
  rename(height = `Height (in)`,
         weight = `Weight (lbs)`) %>%
  select(player, defense, height, weight) %>%
  mutate(player = str_replace_all(player, "ALEXANDER", "ALEX"),
         player = str_replace_all(player, "ALEXANDRE", "ALEX"),
         player = case_when(
           player == "CHRISTOPHER.TANEV" ~ "CHRIS.TANEV",
           player == "DANNY.O'REGAN" ~ "DANIEL.O'REGAN",
           player == "EVGENII.DADONOV" ~ "EVGENY.DADONOV",
           player == "MATTHEW.BENNING" ~ "MATT.BENNING",
           player == "MITCHELL.MARNER" ~ "MITCH.MARNER",
           TRUE ~ player
         ))

# Join biographical data into stats data
# Filter to only keep players who played at least 20 games

final_data <- player_TOI_stats %>%
  left_join(bios, by = "player") %>%
  filter(games > 19)

```

These stats are the ones that we're going to use in our model to predict whether a given player is a forward or a defenseman. Let's create at a few graphs, just to see how some of these data look. 

```r

# The code for these four graphs is nearly the same, just change the x
# and the title/labels

final_data %>%
  ggplot(aes(x = weight, fill = defense)) +
  geom_density(alpha = 0.7, color = NA) +
  scale_fill_manual(values = c("#0d324d", "#a188a6")) +
  labs(
    y = "Density",
    x = "Weight (lbs)",
    fill = NULL,
    title = "Weight by Position",
    subtitle = "2018-19 NHL Season, 20+ Games Played Only",
    caption = "Source: Natural Stat Trick"
  ) +
  meg_theme() + 
  theme(legend.position = c(0.9, 0.9))

```

{{< figure src="weight_by_position.png" lightbox="true" >}}

{{< figure src="scoring_rate.png" lightbox="true" >}}

{{< figure src="TOI_by_position.png" lightbox="true" >}}

{{< figure src="blocked_shots.png" lightbox="true" >}}

We can spot some differences here by position: defensemen tend to score at a lower rate and block shots at a higher rate than forwards do. They also tend to spend more time on the ice (by necessity, since there are generally half the number of defensemen as forwards on a dressed roster), which is one of the most well-known differences in the positions. In order to try to predict whether a given player is a forward or a defenseman, we're going to build two logistic regression models. One will have the average time on ice as its sole predictor variable, while the other will have all of these variables (average time on ice, height, weight, points per 60, shots per 60, unblocked shots per 60, hits per 60, hits received per 60, and blocked shots per 60) as predictor variables.

### Get data ready for modeling

Our `final_data` data frame from above will be the base of our `model_data` (we're just removing two unnecessary variables), and we'll use `set.seed()` to create reproducible samples.

```r

# Rearrange our model data

model_data <- final_data %>%
  select(player, defense, everything(), -c(games, TOI))

# Set the seed (very useful for reproducible samples!)

set.seed(1234)

# Split into training and testing data

split_data <- initial_split(model_data, prop = 0.6, strata = defense)

```

The last line of code above, which created a list called `split_data`, uses the helpful `initial_split` function from the `rsample` package. This allows us to create a training data set and a testing data set, an essential step when modeling. We will *train* the data on one data set and then *test* the models on a separate data set. You can set the proportion on your own, of how many observations will go to the training data, but it will default to 0.75 without a different specification. And why did I include `defense` as an optional strata argument?

{{< figure src="count.png" lightbox="true" >}}

As you can see above, our data set has nearly twice the amount of forwards as defensemen. By using the `strata` option, we can ensure that there's a similar proportion of forwards to defensemen in both our training and our testing data sets.

```r

# Create our testing and training data sets

training_data <- training(split_data)
testing_data <- testing(split_data)

# Write the recipe for our small TOI_only model

recipe_TOI_only <- training_data %>%
  recipe(defense ~ TOI_game) %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors()) %>%
  prep()

recipe_TOI_only

```

In the code above, we can create our basic training and test data sets and then move onto the useful functions of the `recipes` package. This package allows you to create a *recipe* in order to organize all of your processing steps for your model(s). You specify the arguments with the `recipe()` function and then specify processing steps with the various functions that begin with step_. <a href="https://cran.r-project.org/web/packages/recipes/vignettes/Simple_Example.html" target="_blank">There are dozens of these</a> that will perform all sorts of functions (e.g., create dummy variables, input various values, take the log), but here we're just using `step_center()` and `step_scale()` to show you how to normalize variables. In order to specify variables for these step_ functions, you can use standard `dplyr::select` variables (e.g., `starts_with()`, `ends_with()`) or select by role (e.g., `all_predictors()`, `all_outcomes()`) or select by data type (e.g., `all_numeric()`). And you can of course select by variable name, as well. 

We now have a recipe called `recipe_TOI_only` that looks like this.

{{< figure src="recipe_TOI.png" lightbox="true" >}}

### Run our models

```r

# Extract our prepped training data 
# and "bake" our testing data

training_baked_TOI <- juice(recipe_TOI_only)

testing_baked_TOI <- recipe_TOI_only %>%
  bake(testing_data) 

# Run the model with our training data

logistic_glm_TOI <-
  logistic_reg(mode = "classification") %>%
  set_engine("glm") %>%
  fit(defense ~ ., data = training_baked_TOI)

```

Now that we have our recipe, we can apply it to our training and testing data. Since the training data was the base of the recipe, we can use the `juice()` function to extract it. And the `bake()` function will prep the test data. Then, we can actually run the model with functions from the `parsnip` package. The package handles many different kind of models, but here we're running a simple logistic regression and training it on our baked data.

```r

# Find the class predictions from our testing data
# And add back in the true values from testing data

predictions_class_TOI <- logistic_glm_TOI %>%
  predict(new_data = testing_baked_TOI) %>%
  bind_cols(testing_baked_TOI %>% select(defense))

# Find the probability predictions
# And add all together

predictions_TOI <- logistic_glm_TOI %>%
  predict(testing_baked_TOI, type = "prob") %>%
  bind_cols(predictions_class_TOI)

```

Now that the model has been trained, we can apply it to the testing data. The data frame we just created, `predictions_TOI`, looks like this. For each observation in our test data set, we have the predicted position and the probability that drove that prediction. We also brought in the `defense` variable from the test data set.

{{< figure src="TOI_example.png" lightbox="true" >}}

Just for fun, we can bring the `player` variable back from the original test data set and look at who was predicted the *most* incorrectly.

```r

# Look at who was predicted the most incorrectly
# (Just for fun)

most_wrong_TOI <- predictions_TOI %>%
  bind_cols(select(testing_data, player, TOI_game)) %>%
  mutate(incorrect = .pred_class != defense) %>%
  filter(incorrect == TRUE) %>%
  mutate(prob_actual = ifelse(defense == "D", .pred_D, .pred_F)) %>%
  arrange(prob_actual)

```

{{< figure src="incorrect_TOI.png" lightbox="true" >}}

As to be expected with such a simple model that's based solely on TOI, the predictions aren't so good for defensemen who don't play a lot of minutes or forwards who do. Let's move on to our kitchen sink model that includes all the variables. 
```r

# Do the same process for our kitchen sink model

recipe_kitchen_sink <- training_data %>%
  recipe(defense ~ weight + height + points_60 + shots_60 + fenwick_60 + hits_60 + hits_rec_60 + blocks_60 + TOI_game) %>%
  step_corr(all_predictors(), threshold = 0.8) %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors()) %>%
  prep()

recipe_kitchen_sink

training_baked_KS <- juice(recipe_kitchen_sink)

testing_baked_KS <- recipe_kitchen_sink %>%
  bake(testing_data) 

# Run the model with our training data

logistic_glm_KS <-
  logistic_reg(mode = "classification") %>%
  set_engine("glm") %>%
  fit(defense ~ ., data = training_baked_KS)

# Find the class predictions from our testing data
# And add back in the true values from testing data

predictions_class_KS <- logistic_glm_KS %>%
  predict(new_data = testing_baked_KS) %>%
  bind_cols(testing_baked_KS %>% select(defense))

# Find the probability predictions
# And add all together

predictions_KS <- logistic_glm_KS %>%
  predict(testing_baked_KS, type = "prob") %>%
  bind_cols(predictions_class_KS)

```

The code above looks very similar to the code from before, except we added an extra step in our recipe. The `step_corr()` function will study all the correlations among variables you specify and remove offenders, as it often isn't a good idea to have variables in your model that are highly correlated with each other. The default threshold for exclusion is 0.9, but you can specify whatever value you want. As you can see in the recipe below, our recipe automatically removed the `shots_60` variable, which is (obviously) very highly correlated to the unblocked shot attempt variable, `fenwick_60`.

{{< figure src="recipe_KS.png" lightbox="true" >}}

### Evaluate our models

In this section, I'm only going to show the code for one model (though we're evaluating two), but of course you would use the same code for both. (And if you were working with multiple models that you want to compare, it'd be a good idea to create functions to do these steps so that you aren't copying and pasting.)

First we can create a confusion matrix, which simply plots the predicted values against the actual values.

```r

# Create a confusion matrix

predictions_TOI %>%
  conf_mat(defense, .pred_class) %>%
  pluck(1) %>%
  as_tibble() %>%
  ggplot(aes(Prediction, Truth, alpha = n)) +
  geom_tile(show.legend = FALSE) +
  geom_text(aes(label = n), colour = "white", alpha = 1, size = 8) +
  meg_theme() +
  theme(panel.grid.major = element_blank()) +
  labs(
    y = "Actual Position",
    x = "Predicted Position",
    fill = NULL,
    title = "Confusion Matrix",
    subtitle = "TOI Only Model"
  )

```

{{< figure src="conf_matrix_TOI.png" lightbox="true" >}}

{{< figure src="conf_mat_KS.png" lightbox="true" >}}

Just from a brief look at this, the kitchen sink model clearly has higher accuracy (calculated as the number of correct predictions divided by the number of total predictions) than the TOI only model.

```r

# Find the accuracy

predictions_TOI %>%
  accuracy(defense, .pred_class) 

# Find the logloss

predictions_TOI %>%
  mn_log_loss(defense, .pred_D)

# Find the area under the ROC curve (AUC)

predictions_TOI %>%
  roc_auc(defense, .pred_D)

# Create a tibble that holds all the evaluation metrics

TOI_metrics <- tibble(
  "log_loss" = 
    mn_log_loss(predictions_TOI, defense, .pred_D) %>%
    select(.estimate),
  "accuracy" = 
    accuracy(predictions_TOI, defense, .pred_class) %>%
    select(.estimate),
  "auc" = 
    roc_auc(predictions_TOI, defense, .pred_D) %>%
    select(.estimate)
) %>%
  unnest(everything()) %>%
  pivot_longer(everything(), names_to = "metric", values_to = "value") %>%
  mutate(model = "TOI_only")

```

The `yardstick` package is what holds a lot of these functions that are useful for model evaulation. We just defined accuracy, which you can calculate on your own from the confusion matrix and is also available via the `accuracy()` function. That's useful for determining how good the model is in a binary sense, while log loss (from the `mn_log_loss()` function) uses the probabilities to quantify how correct the predictions are. As an example, let's go back to our TOI only model and see that Aleksander Barkov (a forward) was given a 0.75 probability of being a defenseman. That's obviously incorrect. It's counted as an incorrect prediction for the accuracy metric, but log loss also takes into account that the prediction was *quite* wrong. If the prediction had instead given him a 0.51 probability of being a defenseman, the penalty would be less. 

We can also create a tibble (a type of data frame) to hold all of these metrics. We'll use it to compare both models in a minute. The last metric included is the area under the ROC curve, known as AUC. The ROC curve graphs the false positive rate against the true positive rate and in a nutshell, quantifies how good the model is at distinguishing the groups.

The `yardstick` package also makes it really easy to graph the curve itself.

```r

# Look at the ROC curve

predictions_TOI %>%
  roc_curve(defense, .pred_D) %>%
  ggplot(aes(x = 1 - specificity, y = sensitivity)) +
  geom_path() +
  geom_abline(lty = 3) +
  coord_equal() +
  meg_theme() +
  labs(
    y = "True Positive Rate (Sensitivity)",
    x = "False Positive Rate",
    fill = NULL,
    title = "ROC Curve",
    subtitle = "TOI Only Model"
  )

```

{{< figure src="ROC_TOi.png" lightbox="true" >}}

{{< figure src="ROC_KS.png" lightbox="true" >}}

The ideal ROC curve is one that goes high up into the top left corner (as to maximize the area underneath it), so again, it appears that our kitchen sink model is performing better here. Lastly, let's use the tibbles we created to hold the evaulation metrics and graph to compare.

```r

metrics_compare <- TOI_metrics %>%
  bind_rows(KS_metrics)
  
metrics_compare %>%
  ggplot(aes(fill = model, y = value, x = metric)) + 
  geom_bar(position = "dodge", stat = "identity") +
  scale_fill_manual(values = c("#7A8B99", "#A9DDD6")) +
  meg_theme() +
  labs(
    y = "Value",
    x = "Metric",
    fill = NULL,
    title = "Comparing Our Models",
    subtitle = "Higher is Better: Accuracy and AUC\nLower is Better: Log Loss"
  ) + 
  geom_text(aes(label = round(value, 3)), vjust = -0.5, size = 3, position = position_dodge(width= 0.9)) +
  theme(legend.position = c(0.86, 0.9))

```

{{< figure src="compare.png" lightbox="true" >}}

We saw previously from the confusion matrices that the accuracy for the kitchen sink model is higher, and this tells us that the AUC is higher, as well, while the log loss is lower (which is good). Thanks to the evaluation metrics of the `yardstick` package (and there are many more than the few we viewed!), we have evidence that compared to the TOI only model, the kitchen sink model makes more accurate predictions and is better at distinguishing between the groups.

`tidymodels` is a pretty neat set of packages, and I hope this little tutorial was useful in introducing some of the many features. Here are a handful of other resources I have found helpful as I continue to learn more about this package:

* https://juliasilge.com/blog/intro-tidymodels/
* https://towardsdatascience.com/modelling-with-tidymodels-and-parsnip-bae2c01c131c
* https://www.benjaminsorensen.me/post/modeling-with-parsnip-and-tidymodels/
* https://rviews.rstudio.com/2019/06/19/a-gentle-intro-to-tidymodels/