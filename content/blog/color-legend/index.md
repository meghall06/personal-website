---
date: "2021-07-20"
diagram: true
image:
  caption: 
  placement: 
  preview_only: yes
markup: mmark
featured: yes 
categories: ["R", "ggplot2", "data viz"]
summary: 'Fun and custom-looking alternatives to simple color legends in ggplot2.'
math: true
title: Alternatives to Simple Color Legends in ggplot2
---

The beauty of visualizing data with R (`ggplot2`, specifically) is that nearly every single thing about your plot is customizable. However, that blessing can also be a curse because with so many options to make your plots look exactly how you want, it can be difficult to even know what all the options are! But learning to customize different parts of the plot is how you can begin to take your data visualizations to the next level and move beyond the standard, out-of-the-box ggplots. Legends, or the way aesthetic values are mapped to data, are an essential part of plots, and this post introduces a few different options for labeling colors effectively. 

### Today's data

The data set used in today's example comes from this week's edition of [#TidyTuesday](https://github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-07-20/readme.md) and contains variables of interest on drought conditions in the US from the US Drought Monitor.

I can read in the data directly from the Tidy Tuesday Github repo as follows:

```r
drought <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-07-20/drought.csv')
```

And also load the libraries and the theme I'll need for today's plots:

```r
library(tidyverse)
library(gghighlight)
library(scales)
library(ggtext)
library(ggrepel)

meg_theme <- function () { 
  theme_linedraw(base_size=11, base_family="Avenir") %+replace% 
    theme(
      panel.background  = element_blank(),
      plot.background = element_rect(fill = "transparent", color = NA), 
      legend.background = element_rect(fill = "transparent", color = NA),
      legend.key = element_rect(fill = "transparent", color = NA),
      axis.ticks = element_blank(),
      panel.grid.major = element_line(color = "grey90", size = 0.3), 
      panel.grid.minor = element_blank(),
      plot.title.position = "plot",
      plot.title = element_text(size = 18, hjust = 0, vjust = 0.5, 
                                margin = margin(b = 0.2, unit = "cm")),
      plot.subtitle = element_text(size = 10, hjust = 0, vjust = 0.5, 
                                   margin = margin(b = 0.4, unit = "cm")),
      plot.caption = element_text(size = 7, hjust = 1, face = "italic", 
                                  margin = margin(t = 0.1, unit = "cm")),
      axis.text.x = element_text(size = 13),
      axis.text.y = element_text(size = 13)
    )
}
```

I recommend using custom themes whenever possible as it saves lots of typing and requires you to learn about different parts of the plot and the options available to customize! 

### `gghighlight`

{{< figure src="gghighlight.png" lightbox="true" >}}

The [`gghighlight`](https://cran.r-project.org/web/packages/gghighlight/vignettes/gghighlight.html) package provides useful functionality for highlighting (and labeling) certain elements of a plot. This is particularly nice for line graphs, when there are often too many lines to apply color to each one (such as in the example above, with one line per state). 

For the plot above, I've used the `gghighlight` function to highlight only certain states—specifically, those that have a maximum value above 40. Other possible arguments of that function allow you to specify the aesthetics for the labels (here I've adjusted the label size to be 4.5) as well as the aesthetics of the *un*highlighted lines. I used the `size` and `alpha` aesthetics to make those lines smaller and more transparent, respectively. The `scale_color_viridis` function sets the color palette for the highlighted lines.

```r
drought %>% 
  filter(drought_lvl == "D4" & lubridate::year(valid_start) >= 2010) %>% 
  group_by(year = lubridate::year(valid_start), state_abb) %>% 
  summarize(avg = mean(area_pct)) %>% 
  ggplot(aes(x = year, y = avg, group = state_abb, color = state_abb)) +
  geom_line(size = 2) +
  gghighlight(max(avg) > 40,
            label_params = list(size = 4.5),
            unhighlighted_params = list(size = 0.5, alpha = 0.5)) +
  scale_color_viridis_d(option = "D") +
  scale_x_continuous(breaks = seq(2010, 2021, 1),
                     expand = expansion(mult = c(0.01, 0.07))) +
  scale_y_continuous(labels = label_number(suffix = "%")) +
  labs(x = NULL,
       y = "Percent of state (by area) in exceptional drought",
       title = "Three states currently have over 40% of their area in\nexceptional drought (the highest level)",
       subtitle = "Data source: The U.S. Drought Monitor is jointly produced by the National Drought Mitigation Center at the\nUniversity of Nebraska-Lincoln, the United States Department of Agriculture, and the National Oceanic and\nAtmospheric Administration.",
       caption = "@MeghanMHall") +
  meg_theme() +
  theme(panel.grid.major.x = element_blank())
```

### `ggtext`

{{< figure src="highlight.png" lightbox="true" >}}

If you only have one or two items that you'd like to highlight, the [`ggtext`](https://wilkelab.org/ggtext/articles/introduction.html) package allows you to specify those colors in the *title* of your plot instead of using a legend on the plot. This technique is appropriate for many types of graphs, but the example above is the same line graph as in the first example, just with two states highlighted. That highlighting is done in a different way than in the first example, just to show another option.

In the code below I've created a new variable called `highlight` to specify which lines I want highlighted, and that variable is mapped to the `color`, `size`, and `alpha` aesthetics within the `ggplot` function. The values of those aesthetics can be specified with the various `scale_aesthetic_manual` functions.

(The `arrange` and `fct_inorder` functions were necessary to control the ordering of the lines so that the California and Utah lines were on top in the final plot.)

To adjust the colors within the title, you'll notice that the `title` argument within the `labs` function has `<span style = 'color:#3B528BFF;'>California</span>` and `<span style = 'color:#FDE725FF;'>Utah</span>` to specify the color of those words. For that `ggtext` functionality to work appropriately, the following is necessary within the `theme` function: `plot.title = element_markdown())`.

> **Useful tip**: I wanted the colors for these states to be the same as they were in the first plot, which used a palette via `scale_color_viridis`. To extract hex codes from a plot you made with a palette, assign that plot to an object (say, `plot`) and then run `ggplot_build(plot)$data`.

```r
drought %>% 
  filter(drought_lvl == "D4" & lubridate::year(valid_start) >= 2010) %>% 
  group_by(year = lubridate::year(valid_start), state_abb) %>% 
  summarize(avg = mean(area_pct)) %>% 
  arrange(state_abb %in% c("CA","UT")) %>% 
  mutate(state_abb = fct_inorder(state_abb), #
         highlight = ifelse(state_abb %in% c("CA","UT"), state_abb, "base")) %>% 
  ggplot(aes(x = year, y = avg, group = state_abb, color = highlight,
             size = highlight, alpha = highlight)) +
  geom_line(show.legend = FALSE) +
  scale_color_manual(values = c("#3B528BFF","#FDE725FF","grey")) +
  scale_size_manual(values = c(2, 2, 0.5)) +
  scale_alpha_manual(values = c(1, 1, 0.5)) +
  scale_x_continuous(breaks = seq(2010, 2021, 1),
                     expand = expansion(mult = c(0.01, 0.02))) +
  scale_y_continuous(labels = label_number(suffix = "%")) +
  labs(x = NULL,
       y = "Percent of state (by area) in exceptional drought",
       title = "Percent of <span style = 'color:#3B528BFF;'>California</span> and <span style = 'color:#FDE725FF;'>Utah</span>, by area, in exceptional drought",
       subtitle = "Data source: The U.S. Drought Monitor is jointly produced by the National Drought Mitigation Center at the\nUniversity of Nebraska-Lincoln, the United States Department of Agriculture, and the National Oceanic and\nAtmospheric Administration.",
       caption = "@MeghanMHall") +
  meg_theme()+
  theme(panel.grid.major.x = element_blank(),
        plot.title = element_markdown())
```

### `ggrepel`

{{< figure src="ggrepel.png" lightbox="true" >}}

[`ggrepel`](https://ggrepel.slowkow.com/articles/examples.html) automatically moves and removes text labels to avoid overlapping. The plot above shows similar data as in the earlier plots but in scatter plot form, with the percent of state by population along the x-axis and a point for each state and year. The California and Utah points are highlighted like above. 

I created a `label` variable using `paste` to concatenate the state abbreviation as well as the year, and added that variable to the aesthetics of the `geom_label_repel` function.

```r
drought %>% 
  filter(drought_lvl == "D4" & lubridate::year(valid_start) >= 2010) %>% 
  group_by(year = lubridate::year(valid_start), state_abb) %>% 
  summarize(avg_area = mean(area_pct),
            avg_pop = mean(pop_pct)) %>% 
  mutate(highlight = ifelse(state_abb %in% c("CA","UT"), state_abb, "base"),
         label = if_else(highlight != "base",
                         paste(state_abb, year), NA_character_)) %>% 
  ggplot(aes(x = avg_pop, y = avg_area, color = highlight,
             size = highlight)) +
  geom_point() +
  geom_label_repel(aes(label = label), size = 4) +
  scale_color_manual(values = c("grey","#3B528BFF","#FDE725FF")) +
  scale_size_manual(values = c(1, 2, 2)) +
  scale_y_continuous(labels = label_number(suffix = "%")) +
  scale_x_continuous(labels = label_number(suffix = "%")) +
  labs(x = "Percent of state (by population) in exceptional drought",
       y = "Percent of state (by area) in exceptional drought",
       title = "Percent of state in exceptional drought\nAnnual averages over the past 10 years",
       subtitle = "Data source: The U.S. Drought Monitor is jointly produced by the National Drought Mitigation Center at the\nUniversity of Nebraska-Lincoln, the United States Department of Agriculture, and the National Oceanic and\nAtmospheric Administration.",
       caption = "@MeghanMHall") +
  meg_theme() +
  theme(legend.position = "none")
```

---

{{< figure src="ggrepel2.png" lightbox="true" >}}

Or, if you aren't interested in labeling points with the year and instead want to just label one point each for the highlighted states like in the plot above, simply adjust the conditions for the `label` variable to label just two points.

```r
drought %>% 
  filter(drought_lvl == "D4" & lubridate::year(valid_start) >= 2010) %>% 
  group_by(year = lubridate::year(valid_start), state_abb) %>% 
  summarize(avg_area = mean(area_pct),
            avg_pop = mean(pop_pct)) %>% 
  mutate(highlight = ifelse(state_abb %in% c("CA","UT"), state_abb, "base"),
         label = case_when(avg_area < 40 | highlight == "base" ~ NA_character_,
                           state_abb == "CA" ~ "California",
                           state_abb == "UT" ~ "Utah")) %>% 
  ggplot(aes(x = avg_pop, y = avg_area, color = highlight,
             size = highlight)) +
  geom_point() +
  geom_label_repel(aes(label = label), size = 4) +
  scale_color_manual(values = c("grey","#3B528BFF","#FDE725FF")) +
  scale_size_manual(values = c(1, 2, 2)) +
  scale_y_continuous(labels = label_number(suffix = "%")) +
  scale_x_continuous(labels = label_number(suffix = "%")) +
  labs(x = "Percent of state (by population) in exceptional drought",
       y = "Percent of state (by area) in exceptional drought",
       title = "Percent of state in exceptional drought\nAnnual averages over the past 10 years",
       subtitle = "Data source: The U.S. Drought Monitor is jointly produced by the National Drought Mitigation Center at the\nUniversity of Nebraska-Lincoln, the United States Department of Agriculture, and the National Oceanic and\nAtmospheric Administration.",
       caption = "@MeghanMHall") +
  meg_theme() +
  theme(legend.position = "none")
```

### Overriding aesthetics of standard legends

{{< figure src="scatter_legend.png" lightbox="true" >}}

There are also tweaks you can make to the standard color legends in ggplot to make them look a little nicer. The plot above shows the same data as in the previous example, but perhaps in this case you want a more standard legend instead of the option to label a specific point. 

The `highlight` variable is still being used to identify which points should be colored, but if we were to simply add a color legend for that variable, you'd have three elements in that legend: blue, yellow, and gray (for the unhighlighted points). If you *don't* want the gray element to show up in the legend, simply add a `breaks` argument to the `scale_color_manual` function with the elements you want to keep.  Here, that's `breaks = c("CA","UT")`.

In this example I also moved the legend onto the plot itself, which often saves space, with `legend.position = c(0.9, 0.2)` and added a border to the legend. Using the `guides` function, I removed the automatic size legend with `size = FALSE` and overrode the overall point size aesthetic with `color = guide_legend(override.aes = list(size = 5))` to make the points bigger in the legend than they are in the plot.

```r
drought %>% 
  filter(drought_lvl == "D4" & lubridate::year(valid_start) >= 2010) %>% 
  group_by(year = lubridate::year(valid_start), state_abb) %>% 
  summarize(avg_area = mean(area_pct),
            avg_pop = mean(pop_pct)) %>% 
  mutate(highlight = ifelse(state_abb %in% c("CA","UT"), state_abb, "base")) %>% 
  ggplot(aes(x = avg_pop, y = avg_area, color = highlight,
             size = highlight)) +
  geom_point() +
  scale_color_manual(values = c("grey","#3B528BFF","#FDE725FF"),
                     breaks = c("CA","UT")) +
  scale_size_manual(values = c(1, 2, 2)) +
  scale_y_continuous(labels = label_number(suffix = "%")) +
  scale_x_continuous(labels = label_number(suffix = "%")) +
  labs(x = "Percent of state (by population) in exceptional drought",
       y = "Percent of state (by area) in exceptional drought",
       title = "Percent of state in exceptional drought\nAnnual averages over the past 10 years",
       subtitle = "Data source: The U.S. Drought Monitor is jointly produced by the National Drought Mitigation Center at the\nUniversity of Nebraska-Lincoln, the United States Department of Agriculture, and the National Oceanic and\nAtmospheric Administration.",
       caption = "@MeghanMHall") +
  guides(color = guide_legend(override.aes = list(size = 5)),
         size = FALSE) +
  meg_theme() +
  theme(legend.position = c(0.9, 0.2),
        legend.title = element_blank(),
        legend.text = element_text(size = 14),
        legend.background = element_rect(linetype = "solid", 
                                         size = 0.5, color = "black"))
```

---

{{< figure src="legend_top.png" lightbox="true" >}}

The next several plots focus on 2021 data from California only, showing the percent of the state by land area that is in each drought category for each week of data collection. (You'll notice some extra data manipulation is necessary to get correct values for the other drought levels, this is because [the `area_pct` variable in this data set is sometimes a cumulative variable](https://twitter.com/MeghanMHall/status/1417249625648648197).)

This first example above has almost your standard color legend. The only changes I've made are to move the legend to the top of the plot, with `legend.position = "top"` within `theme`, and to specify that the legend items stay in one row instead of the standard two, with `guides(fill = guide_legend(nrow = 1))`.

> If you were going to pursue this option, you'd need to relabel the factor levels of the `drought_lvl` variable so that it was clear what the levels mean. To get that "legend is unclear" label, I used one of my favorite fun functions: `cowplot::stamp(plot, color = "orange", label = "legend is unclear", vjust = 6)`.

```r
drought %>% 
  filter(state_abb == "CA" & lubridate::year(valid_start) == 2021) %>% 
  mutate(drought_lvl = fct_relevel(drought_lvl, 
                                   levels = c("D4","D3","D2","D1","D0","None"))) %>% 
  arrange(map_date, drought_lvl) %>% 
  mutate(prev = lag(area_pct),
         value = ifelse(drought_lvl %in% c("D4","None"), 
                        area_pct, area_pct - prev)) %>% 
  ggplot(aes(x = valid_start, y = value, fill = drought_lvl)) +
  geom_area(color = "white") +
  scale_fill_viridis_d(option = "A") +
  scale_y_continuous(labels = label_number(suffix = "%"),
                     expand = expansion(mult = c(0, 0))) +
  scale_x_date(date_labels = '%b',
               breaks = as.Date(c('2021/1/10','2021/2/10','2021/3/10',
                                  '2021/4/10','2021/5/10','2021/6/10','2021/7/10')),
               expand = expansion(mult = c(0, 0))) +
  guides(fill = guide_legend(nrow = 1)) +
  labs(x = NULL,
       y = "Percent of state (by area)",
       title = "Drought status in California in 2021",
       subtitle = "Data source: The U.S. Drought Monitor is jointly produced by the National Drought Mitigation Center at the\nUniversity of Nebraska-Lincoln, the United States Department of Agriculture, and the National Oceanic and\nAtmospheric Administration.",
       caption = "@MeghanMHall") +
  meg_theme()+
  theme(panel.grid.major = element_blank(),
        legend.position = "top",
        legend.title = element_blank(),
        plot.subtitle = element_text(margin = margin(b = 0, unit = "cm")))
```

---

{{< figure src="legend_within.png" lightbox="true" >}}

If you wished to move the legend onto the plot instead, you can change the background with `legend.background = element_rect(fill = "white")` and also adjust the margins with `legend.margin`, both within the `theme` layer.

This plot suffers from the same unclear legend problem as the one above.

Also note that in these plots for the x-axis, I'm using `scale_x_date` to get a little more functionality in how the dates are shown. I'm using `breaks` to fully specify at which dates I want my labels to be, but you could instead use `date_breaks = '1 month'` to show a label every month. `date_labels` specifies how the dates in the labels should be formatted: `%b` is the syntax for the abbreviated month name (i.e., Jan instead of January or 1), but all of the possible options are available at `?strftime`.

```r
drought %>% 
  filter(state_abb == "CA" & lubridate::year(valid_start) == 2021) %>% 
  mutate(drought_lvl = fct_relevel(drought_lvl, 
                                   levels = c("D4","D3","D2","D1","D0","None"))) %>% 
  arrange(map_date, drought_lvl) %>% 
  mutate(test = lag(area_pct),
         value = ifelse(drought_lvl %in% c("D4","None"),
                        area_pct, area_pct - test)) %>% 
  ggplot(aes(x = valid_start, y = value, fill = drought_lvl)) +
  geom_area(color = "white") +
  scale_fill_viridis_d(option = "A") +
  scale_y_continuous(labels = label_number(suffix = "%"),
                     expand = expansion(mult = c(0, 0))) +
  scale_x_date(date_labels = '%b',
               breaks = as.Date(c('2021/1/10','2021/2/10','2021/3/10',
                                  '2021/4/10','2021/5/10','2021/6/10','2021/7/10')),
               expand = expansion(mult = c(0, 0))) +
  guides(fill = guide_legend(nrow = 1)) +
  labs(x = NULL,
       y = "Percent of state (by area)",
       title = "Drought status in California in 2021",
       subtitle = "Data source: The U.S. Drought Monitor is jointly produced by the National Drought Mitigation Center at the\nUniversity of Nebraska-Lincoln, the United States Department of Agriculture, and the National Oceanic and\nAtmospheric Administration.",
       caption = "@MeghanMHall") +
  meg_theme()+
  theme(panel.grid.major.x = element_blank(),
        legend.position = c(0.35, 0.8),
        legend.background = element_rect(fill = "white"),
        legend.title = element_blank(),
        legend.margin = margin(-4, 2.5, 2.5, 1.5))
```

### Annotations

{{< figure src="featured.png" lightbox="true" >}}

Becoming familiar with various ways to annotate plots in `ggplot2` is a great way to start making your plots look more custom. In the plot above, I've used several `annotate` functions to manually label each area with the label of that category.

These functions start with a `"text"` argument, and I can specify with `x` and `y` where the annotations should be. I also specify `color`, `size`, and font `family`, since annotations do not pick up the specified fonts from the selected theme.

```r
drought %>% 
  filter(state_abb == "CA" & lubridate::year(valid_start) == 2021) %>% 
  mutate(drought_lvl = fct_relevel(drought_lvl, 
                                   levels = c("D4","D3","D2","D1","D0","None"))) %>% 
  arrange(map_date, drought_lvl) %>% 
  mutate(test = lag(area_pct),
         value = ifelse(drought_lvl %in% c("D4","None"), 
                        area_pct, area_pct - test)) %>% 
  ggplot(aes(x = valid_start, y = value, fill = drought_lvl)) +
  geom_area(color = "white") +
  scale_fill_viridis_d(option = "A") +
  scale_y_continuous(labels = label_number(suffix = "%"),
                     expand = expansion(mult = c(0, 0))) +
  scale_x_date(date_labels = '%b',
               breaks = as.Date(c('2021/1/10','2021/2/10','2021/3/10',
                                  '2021/4/10', '2021/5/10','2021/6/10','2021/7/10')),
               expand = expansion(mult = c(0, 0))) +
  labs(x = NULL,
       y = "Percent of state (by area)",
       title = "Drought status in California in 2021",
       subtitle = "Data source: The U.S. Drought Monitor is jointly produced by the National Drought Mitigation Center at the\nUniversity of Nebraska-Lincoln, the United States Department of Agriculture, and the National Oceanic and\nAtmospheric Administration.",
       caption = "@MeghanMHall") +
  annotate("text", x = as.Date('2021/6/15'), y = 85, label = "exceptional\ndrought", 
           size = 5, color = "white", family = "Avenir") +
  annotate("text", x = as.Date('2021/6/15'), y = 50, label = "extreme\ndrought",
           size = 5, color = "white", family = "Avenir") +
  annotate("text", x = as.Date('2021/3/15'), y = 50, label = "severe\ndrought",
           size = 5, color = "white", family = "Avenir") +
  annotate("text", x = as.Date('2021/3/15'), y = 25, label = "moderate\ndrought",
           size = 5, color = "white", family = "Avenir") +
  annotate("text", x = as.Date('2021/3/15'), y = 5, label = "abnormally dry",
           size = 5, color = "white", family = "Avenir") +
  meg_theme()+
  theme(panel.grid.major = element_blank(),
        legend.position = "none")
```

---

{{< figure src="legend_label_bar.png" lightbox="true" >}}

That annotation method also works if you have a stacked bar chart, for example, and would prefer to label the categories on either side of the plot. I've adjusted the available space with `expand = expansion(mult = c(0.09, 0))` within `scale_x_date` and then added more `annotate` layers to specify the labels and the colors of those labels. (Remember that the hex codes within a palette are available with `ggplot_build(plot)$data`.)

I tend to prefer this option when there is adequate space for each category; in this example it's pretty clear what each label is referring to, but visually I don't love how small the top and bottom categories are.

```r
drought %>% 
  filter(state_abb == "CA" & lubridate::year(valid_start) == 2021) %>% 
  mutate(drought_lvl = fct_relevel(drought_lvl, 
                                   levels = c("D4","D3","D2","D1","D0","None"))) %>% 
  arrange(map_date, drought_lvl) %>% 
  mutate(test = lag(area_pct),
         value = ifelse(drought_lvl %in% c("D4","None"),
                        area_pct, area_pct - test)) %>% 
  ggplot(aes(x = valid_start, y = value, fill = drought_lvl)) +
  geom_bar(stat = "identity") +
  scale_fill_viridis_d(option = "A") +
  scale_y_continuous(labels = label_number(suffix = "%"),
                     expand = expansion(mult = c(0, 0))) +
  scale_x_date(date_labels = '%b',
               breaks = as.Date(c('2021/1/10','2021/2/10','2021/3/10',
                                  '2021/4/10','2021/5/10','2021/6/10','2021/7/10')),
               expand = expansion(mult = c(0.09, 0))) +
  labs(x = NULL,
       y = "Percent of state (by area)",
       title = "Drought status in California in 2021",
       subtitle = "Data source: The U.S. Drought Monitor is jointly produced by the National Drought Mitigation Center at the\nUniversity of Nebraska-Lincoln, the United States Department of Agriculture, and the National Oceanic and\nAtmospheric Administration.",
       caption = "@MeghanMHall") +
  annotate("text", x = as.Date('2020/12/15'), y = 97, label = "exceptional\ndrought",
           size = 4, color = "#000004FF", family = "Avenir") +
  annotate("text", x = as.Date('2020/12/15'), y = 75, label = "extreme\ndrought",
           size = 4, color = "#3B0F70FF", family = "Avenir") +
  annotate("text", x = as.Date('2020/12/15'), y = 45, label = "severe\ndrought",
           size = 4, color = "#8C2981FF", family = "Avenir") +
  annotate("text", x = as.Date('2020/12/15'), y = 15, label = "moderate\ndrought",
           size = 4, color = "#DE4968FF", family = "Avenir") +
  annotate("text", x = as.Date('2020/12/15'), y = 4, label = "abnormally\ndry",
           size = 4, color = "#FE9F6DFF", family = "Avenir") +
  meg_theme()+
  theme(panel.grid.major = element_blank(),
        legend.position = "none")
```
