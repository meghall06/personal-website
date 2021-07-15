---
title: "Learning R with Hockey Data in Swirl"
diagram: yes
date: '2020-03-15'
markup: mmark
math: yes
categories: ["R"]
image:
  caption: null
  placement: null
---

<a href="https://swirlstats.com/" target="_blank">The `swirl` package</a> is an incredibly neat learning tool that teaches you how to use R via interactive learning in the RStudio console. And an associated package called `swirlify` allows anyone to *create* lessons that can then be used by anyone using `swirl`.

I've created a course called <a href="https://github.com/meghall06/Hockey_Data_With_Swirl" target="_blank">Hockey Data With Swirl</a> that aims to teach you basic tidyverse functions using hockey data. The data set used in the swirl lesson is the same one used in <a href="https://hockey-graphs.com/2019/12/11/an-introduction-to-r-with-hockey-data/" target="_blank">my introduction to R at Hockey-Graphs</a>, and the content is similar, but not quite identical. You can go through either tutorial, or both, in any order. The `swirl` package is just another learning tool that guides you through, question by question. Right now there is only one lesson in the course, but my goal is to add more in the future (such as a lesson for `ggplot2`!).

In order to go through the lesson, you need to have downloaded R and RStudio (the instructions for which are available in the Hockey-Graphs tutorial I linked above). In RStudio, open a script and run the following code:

```r

install.packages("swirl")
library(swirl)
install_course_github("meghall06", "Hockey_Data_With_Swirl")
swirl()

```

The console prompts will take over from there. `swirl` works through the console, which allows for interactivity but doesn't make it easy to save your code and go back to it later. I've attempted to account for that by making available <a href="https://github.com/meghall06/Hockey_Data_With_Swirl/blob/master/swirl_lesson_one.R" target="_blank">the code file</a> that contains all of the questions and answers from the lesson.

I hope you find the lesson useful, feel free to give feedback and let me know what other topics you'd be interested in!