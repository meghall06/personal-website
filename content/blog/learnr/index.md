---
title: "Learning R with Hockey Data and learnr"
diagram: yes
date: '2020-06-29'
markup: mmark
math: yes
categories: ["tutorials"]
summary: 'Two tutorials available, using the package learnr, for learning R with hockey data.'
image:
  caption: null
  placement: null
---

{{< figure src="pipes_logo.png" lightbox="true" >}}

When I created <a href="https://meghan.rbind.io/post/hockey-data-with-swirl/" target="_blank">a tutorial with swirl</a> earlier this year, some people asked me why I hadn't instead used <a href="https://rstudio.github.io/learnr/index.html" target="_blank">learnr</a>, another tool for interactive learning. I wasn't familiar with learnr, but since it's based in R Markdown and one of my goals for this year is to improve my skills in that area, I decided to give it a try!

So I've created two tutorials in learnr, one that is a true introduction for beginners (focused on the tidyverse) and one that goes a little bit deeper into data manipuation with pivoting and joining data. These tutorials (screenshot below) live in a package I created called `betweenthepipes`. More detail on the package and the tutorial content is available on <a href="https://github.com/meghall06/betweenthepipes/blob/master/README.md" target="_blank">my Github</a>.

{{< figure src="learnrSS.png" lightbox="true" >}}

To access these tutorials, simply download the package. If you're working in RStudio 1.3 or later, there should be a Tutorial pane in the upper right corner of the program where you should see the two tutorials listed. If not, or if you'd prefer to access the tutorials directly, follow the second block of code below.  

```r
# Install my package via github

install.packages("devtools")
devtools::install_github("meghall06/betweenthepipes")

# Only necessary if you don't have RStudio >= 1.3
# Or if you want to access them directly

learnr::run_tutorial("intro", package = "betweenthepipes")
learnr::run_tutorial("data_manip", package = "betweenthepipes")


```