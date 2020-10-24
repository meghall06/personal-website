---
title: "Leveling Up with the Tidyverse <br> (and hockey data)"
subtitle: 'Meghan Hall'
author: 'Carnegie Mellon Sports Analytics Conference <br> October 25, 2020 | #CMSAC20'
institute: '<!--html_preserve--><i class="fab  fa-twitter "></i><!--/html_preserve-->  @MeghanMHall <br> <!--html_preserve--><i class="fab  fa-github "></i><!--/html_preserve--> meghall06 <br> <!--html_preserve--><i class="fas  fa-link "></i><!--/html_preserve--> meghan.rbind.io'
date: 
output:
  xaringan::moon_reader:
    css: xaringan-themer.css
    lib_dir: libs_CMSAC
    nature:
      titleSlideClass: ["left", "middle"]
      highlightStyle: github
      highlightLines: true
      countIncrementalSlides: false
      slideNumberFormat: "%current%"
---





# Me, Exceedingly Briefly

--

1️⃣&nbsp; I work in higher ed as a data manager.

<br>
<br>

--

2️⃣&nbsp; I dabble in hockey analysis.

<br>
<br>

--

3️⃣&nbsp; I use R a **lot**, thanks to 1️⃣ and 2️⃣, and love helping other people learn.

<br>
<br>

---

# The Plan for Today

--

Do you need to know anything about hockey?

--

**No.**

---
background-image: url(https://pbs.twimg.com/media/D6gCaiyW0AAAwdf?format=jpg&name=large)
background-position: center
background-size: contain
class: center, inverse

---

# The Plan for Today

Do you need to know anything about hockey?

**No.**

<br>
<br>

Do you need to know anything about coding?

--

**Eh.**

---

# The Plan for Today


**GOAL**: "Level up your R programming and make your analysis more efficient."

--

<br>

1️⃣&nbsp; Data manipulation with `tidyr` and `dplyr` (and `stringr` and `lubridate` and `purrr`!)

--

2️⃣&nbsp; User-defined functions

--

3️⃣&nbsp; Custom `ggplot2` themes

<br>

--

🕦&nbsp; 5-minute breaks at 5:00 and 5:30

--

❓&nbsp; Questions!

<br>

--

**HOW**: Let's examine the composition of a power play.

---

class: center, middle

# Five-on-five

<img src="figs/CMSAC/5-5.png" width="400" style="display: block; margin: auto;" />

---

class: center, middle

# Five-on-four with three forwards

<img src="figs/CMSAC/3-2.png" width="400" style="display: block; margin: auto;" />

---

class: center, middle

# Five-on-four with four forwards

<img src="figs/CMSAC/4-1.png" width="400" style="display: block; margin: auto;" />

---

# Two questions

--

1️⃣&nbsp; How does the positional composition change over the time of the power play?

<br>

(Is the four-forward configuration maybe more common at the beginning or the end of the power play?)

<br>

--

2️⃣&nbsp; Does a four-forward power play unit have a higher rate of zone exits?

---
class: inverse, center, middle

# Let's Get Set Up

---

# If you want to follow along

--

<img src="figs/CMSAC/pipes_logo.png" width="200" style="display: block; margin: auto;" />

--


```r
# Load the package
devtools::install_github("meghall06/betweenthepipes")
library(betweenthepipes)

# Load the data
pbp <- pbp_example
bio <- bio_example
tracking <- track_example
```

---

# Data sources

--

### Play-by-play data

- `pbp`: NHL play-by-play data
- Four Philadelphia Flyers games in November 2019
- Scraped via the [Evolving-Hockey]() R scraper

---

# Data sources

<table class="table" style="font-size: 9.5px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_date </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_period </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_type </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_description </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> PGSTR </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> PGEND </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> ANTHEM </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> PSTR </td>
   <td style="text-align:left;"> Period Start- Local time: 7:08 EST </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> CHANGE </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> CHANGE </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> FAC </td>
   <td style="text-align:left;"> PHI won Neu. Zone - PHI #28 GIROUX vs CAR #20 AHO </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 21 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 21 </td>
   <td style="text-align:left;"> GIVE </td>
   <td style="text-align:left;"> PHI GIVEAWAY - #28 GIROUX, Neu. Zone </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> CHANGE </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 7 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 31 </td>
   <td style="text-align:left;"> CHANGE </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
</tbody>
</table>

---

# Data sources

<table class="table" style="font-size: 9.5px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_date </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_period </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_type </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_description </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> PGSTR </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> PGEND </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 3 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> ANTHEM </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> PSTR </td>
   <td style="text-align:left;"> Period Start- Local time: 7:08 EST </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 5 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> CHANGE </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 6 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> CHANGE </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 7 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> FAC </td>
   <td style="text-align:left;"> PHI won Neu. Zone - PHI #28 GIROUX vs CAR #20 AHO </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 21 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 8 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 21 </td>
   <td style="text-align:left;"> GIVE </td>
   <td style="text-align:left;"> PHI GIVEAWAY - #28 GIROUX, Neu. Zone </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 9 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> CHANGE </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 7 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 10 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 31 </td>
   <td style="text-align:left;"> CHANGE </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
</tbody>
</table>

---

# Data sources

<table class="table" style="font-size: 9.5px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_date </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_period </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_type </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_description </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
   <td style="text-align:left;"> PGSTR </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
   <td style="text-align:left;"> PGEND </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
   <td style="text-align:left;"> ANTHEM </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
   <td style="text-align:left;"> PSTR </td>
   <td style="text-align:left;"> Period Start- Local time: 7:08 EST </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
   <td style="text-align:left;"> CHANGE </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
   <td style="text-align:left;"> CHANGE </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
   <td style="text-align:left;"> FAC </td>
   <td style="text-align:left;"> PHI won Neu. Zone - PHI #28 GIROUX vs CAR #20 AHO </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 21 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 21 </td>
   <td style="text-align:left;"> GIVE </td>
   <td style="text-align:left;"> PHI GIVEAWAY - #28 GIROUX, Neu. Zone </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 24 </td>
   <td style="text-align:left;"> CHANGE </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 7 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 31 </td>
   <td style="text-align:left;"> CHANGE </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2 </td>
  </tr>
</tbody>
</table>


---

# Data sources

<table class="table" style="font-size: 9.5px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_strength_state </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> home_team </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> away_team </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> home_on_1 </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> home_on_2 </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> home_on_3 </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> home_on_4 </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> home_on_5 </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> home_on_6 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 5v4 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:left;"> JACCOB.SLAVIN </td>
   <td style="text-align:left;"> JORDAN.STAAL </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:left;"> WARREN.FOEGELE </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5v4 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5v4 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5v4 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5v4 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5v4 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5v4 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5v4 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5v4 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 4v5 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:left;"> BRETT.PESCE </td>
   <td style="text-align:left;"> BROCK.MCGINN </td>
   <td style="text-align:left;"> JOEL.EDMUNDSON </td>
   <td style="text-align:left;"> JORDAN.STAAL </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;">  </td>
  </tr>
</tbody>
</table>

---

# Data sources


```r
pbp %>% 
  count(game_id, game_date, home_team, away_team)
```

<table class="table" style="font-size: 20px; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_date </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> home_team </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> away_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> n </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> 2019-11-21 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 586 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020349 </td>
   <td style="text-align:left;"> 2019-11-23 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:left;"> CGY </td>
   <td style="text-align:right;"> 682 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020367 </td>
   <td style="text-align:left;"> 2019-11-25 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:left;"> VAN </td>
   <td style="text-align:right;"> 606 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020384 </td>
   <td style="text-align:left;"> 2019-11-27 </td>
   <td style="text-align:left;"> CBJ </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 627 </td>
  </tr>
</tbody>
</table>
---

# Data sources

### Play-by-play data

- `pbp`: NHL play-by-play data
- Four Philadelphia Flyers games in November 2019
- Scraped via the [Evolving-Hockey]() R scraper

### Skater Data

- `bio`: Demographic and position data for these players from 2019
- Downloaded from [Natural Stat Trick]()

---

# Data sources

<table class="table" style="font-size: 15px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Player </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Position </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Age </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Date of Birth </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Birth City </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Birth State/Province </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Birth Country </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Nationality </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Height (in) </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Weight (lbs) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Adam Gaudette </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:left;"> 10/3/96 </td>
   <td style="text-align:left;"> Braintree </td>
   <td style="text-align:left;"> MA </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:right;"> 73 </td>
   <td style="text-align:right;"> 170 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alan Quine </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:left;"> 2/25/93 </td>
   <td style="text-align:left;"> Belleville </td>
   <td style="text-align:left;"> ON </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 203 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alexander Edler </td>
   <td style="text-align:left;"> D </td>
   <td style="text-align:right;"> 34 </td>
   <td style="text-align:left;"> 4/21/86 </td>
   <td style="text-align:left;"> Ostersund </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:right;"> 212 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alexander Wennberg </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 25 </td>
   <td style="text-align:left;"> 9/22/94 </td>
   <td style="text-align:left;"> Stockholm </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:right;"> 74 </td>
   <td style="text-align:right;"> 197 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alexander Yelesin </td>
   <td style="text-align:left;"> D </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> 2/7/96 </td>
   <td style="text-align:left;"> Yaroslavl </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 195 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alexandre Texier </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> 9/13/99 </td>
   <td style="text-align:left;"> St. Martin D'heres </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> FRA </td>
   <td style="text-align:left;"> FRA </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 192 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Andrei Svechnikov </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> 3/26/00 </td>
   <td style="text-align:left;"> Barnual </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:right;"> 74 </td>
   <td style="text-align:right;"> 195 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Andrew Mangiapane </td>
   <td style="text-align:left;"> L </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> 4/4/96 </td>
   <td style="text-align:left;"> Toronto </td>
   <td style="text-align:left;"> ON </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:right;"> 70 </td>
   <td style="text-align:right;"> 184 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Andrew Peeke </td>
   <td style="text-align:left;"> D </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:left;"> 3/17/98 </td>
   <td style="text-align:left;"> Parkland </td>
   <td style="text-align:left;"> FL </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:right;"> 194 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Andy Andreoff </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 29 </td>
   <td style="text-align:left;"> 5/17/91 </td>
   <td style="text-align:left;"> Pickering </td>
   <td style="text-align:left;"> ON </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:right;"> 73 </td>
   <td style="text-align:right;"> 203 </td>
  </tr>
</tbody>
</table>

---

# Data sources

<table class="table" style="font-size: 15px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Player </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Position </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Age </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Date of Birth </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Birth City </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Birth State/Province </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Birth Country </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Nationality </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Height (in) </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Weight (lbs) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Adam Gaudette </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> C </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:left;"> 10/3/96 </td>
   <td style="text-align:left;"> Braintree </td>
   <td style="text-align:left;"> MA </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:right;"> 73 </td>
   <td style="text-align:right;"> 170 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Alan Quine </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> C </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:left;"> 2/25/93 </td>
   <td style="text-align:left;"> Belleville </td>
   <td style="text-align:left;"> ON </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 203 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Alexander Edler </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> D </td>
   <td style="text-align:right;"> 34 </td>
   <td style="text-align:left;"> 4/21/86 </td>
   <td style="text-align:left;"> Ostersund </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:right;"> 212 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Alexander Wennberg </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> C </td>
   <td style="text-align:right;"> 25 </td>
   <td style="text-align:left;"> 9/22/94 </td>
   <td style="text-align:left;"> Stockholm </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:right;"> 74 </td>
   <td style="text-align:right;"> 197 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Alexander Yelesin </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> D </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> 2/7/96 </td>
   <td style="text-align:left;"> Yaroslavl </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 195 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Alexandre Texier </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> C </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> 9/13/99 </td>
   <td style="text-align:left;"> St. Martin D'heres </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> FRA </td>
   <td style="text-align:left;"> FRA </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 192 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Andrei Svechnikov </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> R </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> 3/26/00 </td>
   <td style="text-align:left;"> Barnual </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:right;"> 74 </td>
   <td style="text-align:right;"> 195 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Andrew Mangiapane </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> L </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> 4/4/96 </td>
   <td style="text-align:left;"> Toronto </td>
   <td style="text-align:left;"> ON </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:right;"> 70 </td>
   <td style="text-align:right;"> 184 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Andrew Peeke </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> D </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:left;"> 3/17/98 </td>
   <td style="text-align:left;"> Parkland </td>
   <td style="text-align:left;"> FL </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:right;"> 194 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Andy Andreoff </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> C </td>
   <td style="text-align:right;"> 29 </td>
   <td style="text-align:left;"> 5/17/91 </td>
   <td style="text-align:left;"> Pickering </td>
   <td style="text-align:left;"> ON </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:right;"> 73 </td>
   <td style="text-align:right;"> 203 </td>
  </tr>
</tbody>
</table>

---

# Data sources

### Play-by-play data

- `pbp`: NHL play-by-play data
- Four Philadelphia Flyers games in November 2019
- Scraped via the [Evolving-Hockey]() R scraper

### Skater Data

- `bio`: Demographic and position data for these players from 2019
- Downloaded from [Natural Stat Trick]()

### Tracking Data

- `tracking`: Zone exit data on the power play in these four games
- Personally tracked by me!

---

# Data sources

<table class="table" style="font-size: 20px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_period </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> time </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_type </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 16:02:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 15:27:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 14:42:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 13:57:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 12:36:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 12:12:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> 18:36:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> 18:10:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> 17:20:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> 14:40:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
</tbody>
</table>

---

# Data sources

<table class="table" style="font-size: 20px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_period </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> time </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_type </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 16:02:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 15:27:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 14:42:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 13:57:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 12:36:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 12:12:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 18:36:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 18:10:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 17:20:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 14:40:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
</tbody>
</table>

---

# Data sources

### Play-by-play data

- `pbp`: NHL play-by-play data
- Four Philadelphia Flyers games in November 2019
- Scraped via the [Evolving-Hockey]() R scraper

### Skater Data

- `bio`: Demographic and position data for these players from 2019
- Downloaded from [Natural Stat Trick]()

### Tracking Data

- `tracking`: Zone exit data on the power play in these four games
- Personally tracked by me!

---
class: inverse, center, middle

# Plan of attack

---

# Plan of attack

🧐&nbsp; Study your different data sources

<br>
<br>
--

🔎&nbsp; Find the relationships

<br>
<br>
--

📝&nbsp; Sketch out how you want your data to look at the end

---

# Problems we get to solve

❌&nbsp; Player position data is in a different place

<br>
<br>

--

❌&nbsp; Zone exit data is in a different place

<br>
<br>

--

❌&nbsp; One row per event instead of one row per second 🤔

<br>
<br>

---

# Packages we'll be using

--

⭐&nbsp; My package (where the data is)


```r
library(betweenthepipes)
```
--
❤️&nbsp; The tidyverse (aka `dplyr`, `tidyr`, `ggplot2`, `stringr`)


```r
library(tidyverse)
```
--
🕑&nbsp; For dealing with time (also part of the tidyverse)


```r
library(lubridate)
```
--
🧹&nbsp; For some data cleaning help


```r
library(janitor)
```

--
🔂&nbsp; For padding out our data


```r
library(padr)
```

---
class: inverse, center, middle

# Play by play data
---

# Play by play data


```r
power <- pbp %>%
  # filter to only the power play strength states
  filter(game_strength_state %in% c("5v4", "4v5")) %>%
  # filter to only events that have time associated with them
  filter(event_length > 0) %>%
  # create a new variable that designates the PP team
  mutate(PP_team = ifelse(game_strength_state == "5v4", 
                          home_team, away_team)) %>%
  # create a new set of variables to determine who the PP players are
  mutate(PP_1 = ifelse(home_team == PP_team, home_on_1, away_on_1),
         PP_2 = ifelse(home_team == PP_team, home_on_2, away_on_2),
         PP_3 = ifelse(home_team == PP_team, home_on_3, away_on_3),
         PP_4 = ifelse(home_team == PP_team, home_on_4, away_on_4),
         PP_5 = ifelse(home_team == PP_team, home_on_5, away_on_5),
         PP_6 = ifelse(home_team == PP_team, home_on_6, away_on_6))
```

---

# Play by play data


```r
power <- pbp %>%
  # filter to only the power play strength states
* filter(game_strength_state %in% c("5v4", "4v5")) %>%
  # filter to only events that have time associated with them
  filter(event_length > 0) %>%
  # create a new variable that designates the PP team
  mutate(PP_team = ifelse(game_strength_state == "5v4", 
                          home_team, away_team)) %>%
  # create a new set of variables to determine who the PP players are
  mutate(PP_1 = ifelse(home_team == PP_team, home_on_1, away_on_1),
         PP_2 = ifelse(home_team == PP_team, home_on_2, away_on_2),
         PP_3 = ifelse(home_team == PP_team, home_on_3, away_on_3),
         PP_4 = ifelse(home_team == PP_team, home_on_4, away_on_4), 
         PP_5 = ifelse(home_team == PP_team, home_on_5, away_on_5),
         PP_6 = ifelse(home_team == PP_team, home_on_6, away_on_6))
```

---

# Play by play data


```r
power <- pbp %>%
  # filter to only the power play strength states
  filter(game_strength_state %in% c("5v4", "4v5")) %>% 
  # filter to only events that have time associated with them
* filter(event_length > 0) %>%
  # create a new variable that designates the PP team
  mutate(PP_team = ifelse(game_strength_state == "5v4", 
                          home_team, away_team)) %>%
  # create a new set of variables to determine who the PP players are
  mutate(PP_1 = ifelse(home_team == PP_team, home_on_1, away_on_1),
         PP_2 = ifelse(home_team == PP_team, home_on_2, away_on_2),
         PP_3 = ifelse(home_team == PP_team, home_on_3, away_on_3),
         PP_4 = ifelse(home_team == PP_team, home_on_4, away_on_4), 
         PP_5 = ifelse(home_team == PP_team, home_on_5, away_on_5),
         PP_6 = ifelse(home_team == PP_team, home_on_6, away_on_6))
```

---

# Play by play data


```r
power <- pbp %>%
  # filter to only the power play strength states
  filter(game_strength_state %in% c("5v4", "4v5")) %>% 
  # filter to only events that have time associated with them
  filter(event_length > 0) %>% 
  # create a new variable that designates the PP team
* mutate(PP_team = ifelse(game_strength_state == "5v4",
*                         home_team, away_team)) %>%
  # create a new set of variables to determine who the PP players are
  mutate(PP_1 = ifelse(home_team == PP_team, home_on_1, away_on_1),
         PP_2 = ifelse(home_team == PP_team, home_on_2, away_on_2),
         PP_3 = ifelse(home_team == PP_team, home_on_3, away_on_3),
         PP_4 = ifelse(home_team == PP_team, home_on_4, away_on_4), 
         PP_5 = ifelse(home_team == PP_team, home_on_5, away_on_5),
         PP_6 = ifelse(home_team == PP_team, home_on_6, away_on_6))
```

---

# Play by play data


```r
power <- pbp %>%
  # filter to only the power play strength states
  filter(game_strength_state %in% c("5v4", "4v5")) %>% 
  # filter to only events that have time associated with them
  filter(event_length > 0) %>% 
  # create a new variable that designates the PP team
  mutate(PP_team = ifelse(game_strength_state == "5v4", 
                          home_team, away_team)) %>%
  # create a new set of variables to determine who the PP players are
* mutate(PP_1 = ifelse(home_team == PP_team, home_on_1, away_on_1),
*        PP_2 = ifelse(home_team == PP_team, home_on_2, away_on_2),
*        PP_3 = ifelse(home_team == PP_team, home_on_3, away_on_3),
*        PP_4 = ifelse(home_team == PP_team, home_on_4, away_on_4),
*        PP_5 = ifelse(home_team == PP_team, home_on_5, away_on_5),
*        PP_6 = ifelse(home_team == PP_team, home_on_6, away_on_6))
```

---

# Play by play data

<table class="table" style="font-size: 10px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_1 </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_2 </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_3 </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_4 </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_5 </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_6 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 43 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 44 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 45 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 46 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 60 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> CLAUDE.GIROUX </td>
   <td style="text-align:left;"> IVAN.PROVOROV </td>
   <td style="text-align:left;"> JAMES.VAN RIEMSDYK </td>
   <td style="text-align:left;"> MORGAN.FROST </td>
   <td style="text-align:left;"> TRAVIS.KONECNY </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 61 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> CLAUDE.GIROUX </td>
   <td style="text-align:left;"> IVAN.PROVOROV </td>
   <td style="text-align:left;"> JAMES.VAN RIEMSDYK </td>
   <td style="text-align:left;"> MORGAN.FROST </td>
   <td style="text-align:left;"> TRAVIS.KONECNY </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 62 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> CLAUDE.GIROUX </td>
   <td style="text-align:left;"> IVAN.PROVOROV </td>
   <td style="text-align:left;"> JAMES.VAN RIEMSDYK </td>
   <td style="text-align:left;"> MORGAN.FROST </td>
   <td style="text-align:left;"> TRAVIS.KONECNY </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 66 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> JAKUB.VORACEK </td>
   <td style="text-align:left;"> MATT.NISKANEN </td>
   <td style="text-align:left;"> OSKAR.LINDBLOM </td>
   <td style="text-align:left;"> SEAN.COUTURIER </td>
   <td style="text-align:left;"> SHAYNE.GOSTISBEHERE </td>
  </tr>
</tbody>
</table>

---
class: middle, inverse

<img src="figs/CMSAC/pivot.gif" width="600" style="display: block; margin: auto;" />

---

# Play by play data


```r
pivot <- power %>%
  # pick the variables that we want
* select(game_id, event_index, PP_team, game_seconds, event_length,
*        home_goalie, away_goalie, PP_1:PP_6) %>%
  # pivot the six player variables
  pivot_longer(PP_1:PP_6, 
               names_to = "on_ice", 
               values_to = "player") %>%
  # filter out the goalies
  filter(player != home_goalie & player != away_goalie) %>%
  # remove the now-unnecessary goalie variables
  select(-c(home_goalie, away_goalie, on_ice))
```

---

# Play by play data


```r
pivot <- power %>%
  # pick the variables that we want
  select(game_id, event_index, PP_team, game_seconds, event_length,
         home_goalie, away_goalie, PP_1:PP_6) %>%                   
  # pivot the six player variables
* pivot_longer(PP_1:PP_6,
*              names_to = "on_ice",
*              values_to = "player") %>%
  # filter out the goalies
  filter(player != home_goalie & player != away_goalie) %>%
  # remove the now-unnecessary goalie variables
  select(-c(home_goalie, away_goalie, on_ice))
```

---

# Play by play data

<table class="table" style="font-size: 12px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> home_goalie </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> away_goalie </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> on_ice </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> player </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_1 </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_2 </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_3 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_4 </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_5 </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_6 </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_1 </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_2 </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_3 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_4 </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_5 </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_6 </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
</tbody>
</table>

---

# Play by play data

<table class="table" style="font-size: 12px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> home_goalie </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> away_goalie </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> on_ice </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> player </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> ANDREI.SVECHNIKOV </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_2 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> DOUGIE.HAMILTON </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_3 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PETR.MRAZEK </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_4 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> RYAN.DZINGEL </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_5 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> SEBASTIAN.AHO </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_6 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> TEUVO.TERAVAINEN </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> ANDREI.SVECHNIKOV </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_2 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> DOUGIE.HAMILTON </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_3 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PETR.MRAZEK </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_4 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> RYAN.DZINGEL </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_5 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> SEBASTIAN.AHO </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_6 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> TEUVO.TERAVAINEN </td>
  </tr>
</tbody>
</table>

---

# Play by play data

<table class="table" style="font-size: 12px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> home_goalie </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> away_goalie </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> on_ice </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> player </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_1 </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_2 </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 41 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> CAR </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 234 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 7 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PETR.MRAZEK </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_3 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PETR.MRAZEK </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_4 </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_5 </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_6 </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_1 </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_2 </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 42 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> CAR </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 241 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 24 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PETR.MRAZEK </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_3 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PETR.MRAZEK </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_4 </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_5 </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> PETR.MRAZEK </td>
   <td style="text-align:left;"> BRIAN.ELLIOTT </td>
   <td style="text-align:left;"> PP_6 </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
</tbody>
</table>

---

# Play by play data


```r
pivot <- power %>%
  # pick the variables that we want
  select(game_id, event_index, PP_team, game_seconds, event_length,
         home_goalie, away_goalie, PP_1:PP_6) %>%                   
  # pivot the six player variables
  pivot_longer(PP_1:PP_6, 
               names_to = "on_ice", 
               values_to = "player") %>% 
  # filter out the goalies
* filter(player != home_goalie & player != away_goalie) %>%
  # remove the now-unnecessary goalie variables
  select(-c(home_goalie, away_goalie, on_ice))
```

---

# Play by play data


```r
pivot <- power %>%
  # pick the variables that we want
  select(game_id, event_index, PP_team, game_seconds, event_length,
         home_goalie, away_goalie, PP_1:PP_6) %>%                   
  # pivot the six player variables
  pivot_longer(PP_1:PP_6,
               names_to = "on_ice",
               values_to = "player") %>% 
  # filter out the goalies
  filter(player != home_goalie & player != away_goalie) %>%
  # remove the now-unnecessary goalie variables
* select(-c(home_goalie, away_goalie, on_ice))
```

---

# Play by play data

<table class="table" style="font-size: 12px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> player </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
  </tr>
</tbody>
</table>

---

class: inverse, center, middle

# Skater data

---

# Skater data


```r
bio <- bio %>%
  # reformat the variable names
  clean_names() %>%
  # use two stringr functions to convert our player names to all 
  # uppercase and replace the first space with a period
  mutate(player = str_to_upper(player),
         player = str_replace(player, " ", ".")) %>%
  # record our position variable into a 0/1 variable for forward
  mutate(forward = ifelse(position == "D", 0, 1)) %>%
  # select only these two variables
  select(player, forward)
```

---

# Skater data


```r
bio <- bio %>%
  # reformat the variable names
* clean_names() %>%
  # use two stringr functions to convert our player names to all 
  # uppercase and replace the first space with a period
  mutate(player = str_to_upper(player),
         player = str_replace(player, " ", ".")) %>%
  # record our position variable into a 0/1 variable for forward
  mutate(forward = ifelse(position == "D", 0, 1)) %>%
  # select only these two variables
  select(player, forward)
```

---

# Skater data

<table class="table" style="font-size: 15px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Player </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Position </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Age </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Date of Birth </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Birth City </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Birth State/Province </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Birth Country </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Nationality </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Height (in) </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> Weight (lbs) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Adam Gaudette </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:left;"> 10/3/96 </td>
   <td style="text-align:left;"> Braintree </td>
   <td style="text-align:left;"> MA </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:right;"> 73 </td>
   <td style="text-align:right;"> 170 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alan Quine </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:left;"> 2/25/93 </td>
   <td style="text-align:left;"> Belleville </td>
   <td style="text-align:left;"> ON </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 203 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alexander Edler </td>
   <td style="text-align:left;"> D </td>
   <td style="text-align:right;"> 34 </td>
   <td style="text-align:left;"> 4/21/86 </td>
   <td style="text-align:left;"> Ostersund </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:right;"> 212 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alexander Wennberg </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 25 </td>
   <td style="text-align:left;"> 9/22/94 </td>
   <td style="text-align:left;"> Stockholm </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:right;"> 74 </td>
   <td style="text-align:right;"> 197 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alexander Yelesin </td>
   <td style="text-align:left;"> D </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> 2/7/96 </td>
   <td style="text-align:left;"> Yaroslavl </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 195 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alexandre Texier </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> 9/13/99 </td>
   <td style="text-align:left;"> St. Martin D'heres </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> FRA </td>
   <td style="text-align:left;"> FRA </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 192 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Andrei Svechnikov </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> 3/26/00 </td>
   <td style="text-align:left;"> Barnual </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:right;"> 74 </td>
   <td style="text-align:right;"> 195 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Andrew Mangiapane </td>
   <td style="text-align:left;"> L </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> 4/4/96 </td>
   <td style="text-align:left;"> Toronto </td>
   <td style="text-align:left;"> ON </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:right;"> 70 </td>
   <td style="text-align:right;"> 184 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Andrew Peeke </td>
   <td style="text-align:left;"> D </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:left;"> 3/17/98 </td>
   <td style="text-align:left;"> Parkland </td>
   <td style="text-align:left;"> FL </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:right;"> 194 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Andy Andreoff </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 29 </td>
   <td style="text-align:left;"> 5/17/91 </td>
   <td style="text-align:left;"> Pickering </td>
   <td style="text-align:left;"> ON </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:right;"> 73 </td>
   <td style="text-align:right;"> 203 </td>
  </tr>
</tbody>
</table>

---

# Skater data

<table class="table" style="font-size: 15px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> player </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> position </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> age </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> date_of_birth </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> birth_city </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> birth_state_province </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> birth_country </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> nationality </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> height_in </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Adam Gaudette </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:left;"> 10/3/96 </td>
   <td style="text-align:left;"> Braintree </td>
   <td style="text-align:left;"> MA </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:right;"> 73 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alan Quine </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:left;"> 2/25/93 </td>
   <td style="text-align:left;"> Belleville </td>
   <td style="text-align:left;"> ON </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:right;"> 72 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alexander Edler </td>
   <td style="text-align:left;"> D </td>
   <td style="text-align:right;"> 34 </td>
   <td style="text-align:left;"> 4/21/86 </td>
   <td style="text-align:left;"> Ostersund </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:right;"> 75 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alexander Wennberg </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 25 </td>
   <td style="text-align:left;"> 9/22/94 </td>
   <td style="text-align:left;"> Stockholm </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:right;"> 74 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alexander Yelesin </td>
   <td style="text-align:left;"> D </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> 2/7/96 </td>
   <td style="text-align:left;"> Yaroslavl </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:right;"> 72 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alexandre Texier </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> 9/13/99 </td>
   <td style="text-align:left;"> St. Martin D'heres </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> FRA </td>
   <td style="text-align:left;"> FRA </td>
   <td style="text-align:right;"> 72 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Andrei Svechnikov </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> 3/26/00 </td>
   <td style="text-align:left;"> Barnual </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:right;"> 74 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Andrew Mangiapane </td>
   <td style="text-align:left;"> L </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> 4/4/96 </td>
   <td style="text-align:left;"> Toronto </td>
   <td style="text-align:left;"> ON </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:right;"> 70 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Andrew Peeke </td>
   <td style="text-align:left;"> D </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:left;"> 3/17/98 </td>
   <td style="text-align:left;"> Parkland </td>
   <td style="text-align:left;"> FL </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:right;"> 75 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Andy Andreoff </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 29 </td>
   <td style="text-align:left;"> 5/17/91 </td>
   <td style="text-align:left;"> Pickering </td>
   <td style="text-align:left;"> ON </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:right;"> 73 </td>
  </tr>
</tbody>
</table>

---

# Skater data


```r
bio <- bio %>%
  # reformat the variable names
  clean_names() %>%
  # use two stringr functions to convert our player names to all 
  # uppercase and replace the first space with a period
* mutate(player = str_to_upper(player),
*        player = str_replace(player, " ", ".")) %>%
  # record our position variable into a 0/1 variable for forward
  mutate(forward = ifelse(position == "D", 0, 1)) %>%
  # select only these two variables
  select(player, forward)
```

---

# Skater data

<table class="table" style="font-size: 15px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> player </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> position </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> age </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> date_of_birth </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> birth_city </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> birth_state_province </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> birth_country </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> nationality </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> ADAM.GAUDETTE </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:left;"> 10/3/96 </td>
   <td style="text-align:left;"> Braintree </td>
   <td style="text-align:left;"> MA </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:left;"> USA </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> ALAN.QUINE </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:left;"> 2/25/93 </td>
   <td style="text-align:left;"> Belleville </td>
   <td style="text-align:left;"> ON </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> CAN </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> ALEXANDER.EDLER </td>
   <td style="text-align:left;"> D </td>
   <td style="text-align:right;"> 34 </td>
   <td style="text-align:left;"> 4/21/86 </td>
   <td style="text-align:left;"> Ostersund </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:left;"> SWE </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> ALEXANDER.WENNBERG </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 25 </td>
   <td style="text-align:left;"> 9/22/94 </td>
   <td style="text-align:left;"> Stockholm </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:left;"> SWE </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> ALEXANDER.YELESIN </td>
   <td style="text-align:left;"> D </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> 2/7/96 </td>
   <td style="text-align:left;"> Yaroslavl </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:left;"> RUS </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> ALEXANDRE.TEXIER </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> 9/13/99 </td>
   <td style="text-align:left;"> St. Martin D'heres </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> FRA </td>
   <td style="text-align:left;"> FRA </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> 3/26/00 </td>
   <td style="text-align:left;"> Barnual </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:left;"> RUS </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> ANDREW.MANGIAPANE </td>
   <td style="text-align:left;"> L </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> 4/4/96 </td>
   <td style="text-align:left;"> Toronto </td>
   <td style="text-align:left;"> ON </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> CAN </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> ANDREW.PEEKE </td>
   <td style="text-align:left;"> D </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:left;"> 3/17/98 </td>
   <td style="text-align:left;"> Parkland </td>
   <td style="text-align:left;"> FL </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:left;"> USA </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> ANDY.ANDREOFF </td>
   <td style="text-align:left;"> C </td>
   <td style="text-align:right;"> 29 </td>
   <td style="text-align:left;"> 5/17/91 </td>
   <td style="text-align:left;"> Pickering </td>
   <td style="text-align:left;"> ON </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> CAN </td>
  </tr>
</tbody>
</table>

---

# Skater data

<table class="table" style="font-size: 15px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> player </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> position </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> age </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> date_of_birth </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> birth_city </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> birth_state_province </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> birth_country </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> nationality </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> ADAM.GAUDETTE </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> C </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:left;"> 10/3/96 </td>
   <td style="text-align:left;"> Braintree </td>
   <td style="text-align:left;"> MA </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:left;"> USA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ALAN.QUINE </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> C </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:left;"> 2/25/93 </td>
   <td style="text-align:left;"> Belleville </td>
   <td style="text-align:left;"> ON </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> CAN </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ALEXANDER.EDLER </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> D </td>
   <td style="text-align:right;"> 34 </td>
   <td style="text-align:left;"> 4/21/86 </td>
   <td style="text-align:left;"> Ostersund </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:left;"> SWE </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ALEXANDER.WENNBERG </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> C </td>
   <td style="text-align:right;"> 25 </td>
   <td style="text-align:left;"> 9/22/94 </td>
   <td style="text-align:left;"> Stockholm </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:left;"> SWE </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ALEXANDER.YELESIN </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> D </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> 2/7/96 </td>
   <td style="text-align:left;"> Yaroslavl </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:left;"> RUS </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ALEXANDRE.TEXIER </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> C </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> 9/13/99 </td>
   <td style="text-align:left;"> St. Martin D'heres </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> FRA </td>
   <td style="text-align:left;"> FRA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> R </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> 3/26/00 </td>
   <td style="text-align:left;"> Barnual </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:left;"> RUS </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ANDREW.MANGIAPANE </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> L </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> 4/4/96 </td>
   <td style="text-align:left;"> Toronto </td>
   <td style="text-align:left;"> ON </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> CAN </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ANDREW.PEEKE </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> D </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:left;"> 3/17/98 </td>
   <td style="text-align:left;"> Parkland </td>
   <td style="text-align:left;"> FL </td>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:left;"> USA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ANDY.ANDREOFF </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> C </td>
   <td style="text-align:right;"> 29 </td>
   <td style="text-align:left;"> 5/17/91 </td>
   <td style="text-align:left;"> Pickering </td>
   <td style="text-align:left;"> ON </td>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> CAN </td>
  </tr>
</tbody>
</table>

---

# Skater data


```r
bio <- bio %>%
  # reformat the variable names
  clean_names() %>%
  # use two stringr functions to convert our player names to all 
  # uppercase and replace the first space with a period
  mutate(player = str_to_upper(player),
         player = str_replace(player, " ", ".")) %>% 
  # record our position variable into a 0/1 variable for forward
* mutate(forward = ifelse(position == "D", 0, 1)) %>%
  # select only these two variables
  select(player, forward)
```

---

# Skater data


```r
bio <- bio %>%
  # reformat the variable names
  clean_names() %>%
  # use two stringr functions to convert our player names to all 
  # uppercase and replace the first space with a period
  mutate(player = str_to_upper(player),
         player = str_replace(player, " ", ".")) %>% 
  # record our position variable into a 0/1 variable for forward
  mutate(forward = ifelse(position == "D", 0, 1)) %>% 
  # select only these two variables
* select(player, forward)
```

---

# Skater data

<table class="table" style="font-size: 15px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> player </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> forward </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> ADAM.GAUDETTE </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ALAN.QUINE </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ALEXANDER.EDLER </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ALEXANDER.WENNBERG </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ALEXANDER.YELESIN </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ALEXANDRE.TEXIER </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ANDREW.MANGIAPANE </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ANDREW.PEEKE </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ANDY.ANDREOFF </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table>

---

# Skater data


```r
pivot_position <- pivot %>%
  left_join(bio, by = "player")
```

--

<table class="table" style="font-size: 15px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> player </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> forward </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table>

---

# Skater data


```r
pivot_position %>%
  get_dupes(game_id, event_index, player)
```

```
## # A tibble: 0 x 8
## # … with 8 variables: game_id <dbl>, event_index <dbl>, player <chr>,
## #   dupe_count <int>, PP_team <chr>, game_seconds <dbl>, event_length <dbl>,
## #   forward <dbl>
```

---

# Skater data


```r
fixes <- pivot_position %>%
  filter(is.na(forward)) %>%
  count(player) %>%
  arrange(player)
```

--

<table class="table" style="font-size: 15px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> player </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> n </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> ALEX.EDLER </td>
   <td style="text-align:right;"> 9 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ALEX.WENNBERG </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHRIS.TANEV </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
</tbody>
</table>


---

# Skater data


```r
bio %>%
  filter(str_detect(player, 'EDLER|WENNBERG|TANEV'))
```

--

<table class="table" style="font-size: 15px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> player </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> forward </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> ALEXANDER.EDLER </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ALEXANDER.WENNBERG </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHRISTOPHER.TANEV </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
</tbody>
</table>

---

# Skater data


```r
bio <- bio %>%
  mutate(player = case_when(
                      player == "ALEXANDER.EDLER" ~ "ALEX.EDLER",
                      player == "ALEXANDER.WENNBERG" ~ "ALEX.WENNBERG",
                      player == "CHRISTOPHER.TANEV" ~ "CHRIS.TANEV",
                      TRUE ~ player))
```

--


```r
pivot_position <- pivot %>%
  left_join(bio, by = "player")

fixes <- pivot_position %>%
  filter(is.na(forward)) %>%
  count(player) %>%
  arrange(player)
```

--

<table class="table" style="font-size: 15px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> player </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> n </th>
  </tr>
 </thead>
<tbody>
  <tr>

  </tr>
</tbody>
</table>

---

# Play by play

<table class="table" style="font-size: 15px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> player </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> forward </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table>

---
class: middle, inverse

<img src="figs/CMSAC/pivot.gif" width="600" style="display: block; margin: auto;" />

---

# Play by play


```r
data <- pivot_position %>%
  # first create a basic count variable for each player within a PP
  group_by(game_id, event_index) %>%
  mutate(on_ice = row_number()) %>%
  ungroup() %>%
  # pivot the players and positions
  pivot_wider(names_from = "on_ice", 
              values_from = c("player", "forward")) %>%
  # create a variable to count the number of forwards
  mutate(PP_fwds = select(., forward_1:forward_5) %>% 
           rowSums(na.rm = TRUE)) %>%
  # remove the now-unnecessary variables
  select(-c(player_1:forward_5))
```

---

# Play by play


```r
data <- pivot_position %>%
  # first create a basic count variable for each player within a PP
* group_by(game_id, event_index) %>%
* mutate(on_ice = row_number()) %>%
* ungroup() %>%
  # pivot the players and positions
  pivot_wider(names_from = "on_ice", 
              values_from = c("player", "forward")) %>%
  # create a variable to count the number of forwards
  mutate(PP_fwds = select(., forward_1:forward_5) %>% 
           rowSums(na.rm = TRUE)) %>%
  # remove the now-unnecessary variables
  select(-c(player_1:forward_5))
```

---

# Play by play

<table class="table" style="font-size: 15px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> player </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> forward </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> on_ice </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> DOUGIE.HAMILTON </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> RYAN.DZINGEL </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> SEBASTIAN.AHO </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> TEUVO.TERAVAINEN </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 5 </td>
  </tr>
</tbody>
</table>

---

# Play by play


```r
data <- pivot_position %>%
  # first create a basic count variable for each player within a PP
  group_by(game_id, event_index) %>%
  mutate(on_ice = row_number()) %>%
  ungroup() %>% 
  # pivot the players and positions
* pivot_wider(names_from = "on_ice",
*             values_from = c("player", "forward")) %>%
  # create a variable to count the number of forwards
  mutate(PP_fwds = select(., forward_1:forward_5) %>% 
           rowSums(na.rm = TRUE)) %>%
  # remove the now-unnecessary variables
  select(-c(player_1:forward_5))
```

---

# Play by play

<table class="table" style="font-size: 12px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> player_1 </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> forward_1 </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> player_2 </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> forward_2 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> DOUGIE.HAMILTON </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> DOUGIE.HAMILTON </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 43 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 265 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> DOUGIE.HAMILTON </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 44 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 267 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> DOUGIE.HAMILTON </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 45 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 272 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> DOUGIE.HAMILTON </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 46 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 276 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> ANDREI.SVECHNIKOV </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> DOUGIE.HAMILTON </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 60 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 313 </td>
   <td style="text-align:right;"> 33 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> CLAUDE.GIROUX </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> IVAN.PROVOROV </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 61 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 346 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> CLAUDE.GIROUX </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> IVAN.PROVOROV </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 62 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 356 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> CLAUDE.GIROUX </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> IVAN.PROVOROV </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 66 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 357 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> JAKUB.VORACEK </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> MATT.NISKANEN </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
  </tr>
</tbody>
</table>

---

# Play by play


```r
data <- pivot_position %>%
  # first create a basic count variable for each player within a PP
  group_by(game_id, event_index) %>%
  mutate(on_ice = row_number()) %>%
  ungroup() %>% 
  # pivot the players and positions
  pivot_wider(names_from = "on_ice", 
              values_from = c("player", "forward")) %>%
  # create a variable to count the number of forwards
* mutate(PP_fwds = select(., forward_1:forward_5) %>%
*          rowSums(na.rm = TRUE)) %>%
  # remove the now-unnecessary variables
  select(-c(player_1:forward_5))
```

---

# Play by play


```r
data <- pivot_position %>%
  # first create a basic count variable for each player within a PP
  group_by(game_id, event_index) %>%
  mutate(on_ice = row_number()) %>%
  ungroup() %>% 
  # pivot the players and positions
  pivot_wider(names_from = "on_ice", 
              values_from = c("player", "forward")) %>%
  # create a variable to count the number of forwards
  mutate(PP_fwds = select(., forward_1:forward_5) %>% 
           rowSums(na.rm = TRUE)) %>%
  # remove the now-unnecessary variables
* select(-c(player_1:forward_5))
```

---

# Play by play

<table class="table" style="font-size: 20px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 43 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 265 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 44 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 267 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 45 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 272 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 46 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 276 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 60 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 313 </td>
   <td style="text-align:right;"> 33 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 61 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 346 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 62 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 356 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 66 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 357 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 3 </td>
  </tr>
</tbody>
</table>

---

# Problems we get to solve

✅&nbsp; Player position data is in a different place

<br>
<br>

❌&nbsp; Zone exit data is in a different place

<br>
<br>

❌&nbsp; One row per event instead of one row per second 🤔

---

class: inverse, center, middle

# Tracking data

---

# Tracking data

<table class="table" style="font-size: 20px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_period </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> time </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_type </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 16:02:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 15:27:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 14:42:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 13:57:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 12:36:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 12:12:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 18:36:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 18:10:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 17:20:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 14:40:00 </td>
   <td style="text-align:left;"> EXIT </td>
  </tr>
</tbody>
</table>

---

# Tracking data


```r
tracking <- tracking %>%
  # create a new variable that converts to m:s
  mutate(time_new = str_sub(time, 1, 5),
         time_new = ms(time_new),
         # create a new variable for total seconds
         seconds = minute(time_new)*60 + second(time_new),
         # create a game_seconds variable to match what's in pbp data
         game_seconds = case_when(
                            game_period == 1 ~ 1200 - seconds,
                            game_period == 2 ~ 2400 - seconds,
                            game_period == 3 ~ 3600 - seconds)) %>%
  # remove now-unnecessary variables
  select(-c(time, time_new, seconds, game_period))
```

---

# Tracking data


```r
tracking <- tracking %>%
  # create a new variable that converts to m:s
* mutate(time_new = str_sub(time, 1, 5),
*        time_new = ms(time_new),
         # create a new variable for total seconds
         seconds = minute(time_new)*60 + second(time_new),
         # create a game_seconds variable to match what's in pbp data
         game_seconds = case_when(
                            game_period == 1 ~ 1200 - seconds,
                            game_period == 2 ~ 2400 - seconds,
                            game_period == 3 ~ 3600 - seconds)) %>%
  # remove now-unnecessary variables
  select(-c(time, time_new, seconds, game_period))
```

---

# Tracking data

<table class="table" style="font-size: 20px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_period </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> time </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_type </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> time_new </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 16:02:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 16M 2S </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 15:27:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 15M 27S </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 14:42:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 14M 42S </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 13:57:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 13M 57S </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 12:36:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 12M 36S </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 12:12:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 12M 12S </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> 18:36:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 18M 36S </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> 18:10:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 18M 10S </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> 17:20:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 17M 20S </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> 14:40:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 14M 40S </td>
  </tr>
</tbody>
</table>

---

# Tracking data


```r
tracking <- tracking %>%
  # create a new variable that converts to m:s
  mutate(time_new = str_sub(time, 1, 5),
         time_new = ms(time_new), 
         # create a new variable for total seconds
*        seconds = minute(time_new)*60 + second(time_new),
         # create a game_seconds variable to match what's in pbp data
         game_seconds = case_when(
                            game_period == 1 ~ 1200 - seconds,
                            game_period == 2 ~ 2400 - seconds,
                            game_period == 3 ~ 3600 - seconds)) %>%
  # remove now-unnecessary variables
  select(-c(time, time_new, seconds, game_period))
```

---

# Tracking data

<table class="table" style="font-size: 20px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_period </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> time </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_type </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> time_new </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> seconds </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 16:02:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;"> 16M 2S </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 962 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 15:27:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;"> 15M 27S </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 927 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 14:42:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;"> 14M 42S </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 882 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 13:57:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;"> 13M 57S </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 837 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 12:36:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;"> 12M 36S </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 756 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 12:12:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;"> 12M 12S </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 732 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> 18:36:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;"> 18M 36S </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1116 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> 18:10:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;"> 18M 10S </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1090 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> 17:20:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;"> 17M 20S </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1040 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> 14:40:00 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;"> 14M 40S </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 880 </td>
  </tr>
</tbody>
</table>

---

# Tracking data


```r
tracking <- tracking %>%
  # create a new variable that converts to m:s
  mutate(time_new = str_sub(time, 1, 5),
         time_new = ms(time_new), 
         # create a new variable for total seconds
         seconds = minute(time_new)*60 + second(time_new), 
         # create a game_seconds variable to match what's in pbp data
*        game_seconds = case_when(
*                           game_period == 1 ~ 1200 - seconds,
*                           game_period == 2 ~ 2400 - seconds,
*                           game_period == 3 ~ 3600 - seconds)) %>%
  # remove now-unnecessary variables
  select(-c(time, time_new, seconds, game_period))
```

---

# Tracking data

<table class="table" style="font-size: 20px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_type </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 238 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 273 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 318 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 363 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 444 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 468 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1284 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1310 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1360 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:left;"> EXIT </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1520 </td>
  </tr>
</tbody>
</table>

---

class: middle, center, inverse

# Padding our data

---

# What's the goal?

We want to expand our data: one row per event ➡️&nbsp; one row per second

<br>
<br>
--

So we can more easily:

1️⃣&nbsp; Examine the average composition of a power play per second

2️⃣&nbsp; Join in our manually-tracked data

<br>
<br>
--

Thankfully, we have the `padr` package.

---

# Padding our data


```r
data <- data %>%
  # create an 0/1 variable to identify a new power play
  # and a power_play_count variable
  mutate(new_power_play = ifelse(lag(game_seconds + event_length) == 
                                   game_seconds & lag(PP_team) == 
                                   PP_team, 0, 1),
         new_power_play = ifelse(is.na(new_power_play), 
                                 1, new_power_play),
         power_play_count = cumsum(new_power_play)) %>%
  select(power_play_count, everything())
```

---

# Padding our data


```r
data <- data %>%
  # create an 0/1 variable to identify a new power play
  # and a power_play_count variable
* mutate(new_power_play = ifelse(lag(game_seconds + event_length) ==
*                                  game_seconds & lag(PP_team) ==
*                                  PP_team, 0, 1),
*        new_power_play = ifelse(is.na(new_power_play),
*                                1, new_power_play),
         power_play_count = cumsum(new_power_play)) %>%
  select(power_play_count, everything())
```

---

# Padding our data

<table class="table" style="font-size: 18px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> new_power_play </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 41 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> CAR </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 234 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 7 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 43 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 265 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 44 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 267 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 45 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 272 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 46 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 276 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 60 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PHI </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 313 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 33 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 61 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 346 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 62 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 356 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 66 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 357 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
</tbody>
</table>

---

# Padding our data


```r
data <- data %>%
  # create an 0/1 variable to identify a new power play
  # and a power_play_count variable
  mutate(new_power_play = ifelse(lag(game_seconds + event_length) == 
                                   game_seconds & lag(PP_team) ==
                                   PP_team, 0, 1), 
         new_power_play = ifelse(is.na(new_power_play), 
                                 1, new_power_play), 
*        power_play_count = cumsum(new_power_play)) %>%
  select(power_play_count, everything())
```

---

# Padding our data

<table class="table" style="font-size: 14px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> new_power_play </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> power_play_count </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 43 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 265 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 44 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 267 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 45 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 272 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 46 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 276 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 60 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 313 </td>
   <td style="text-align:right;"> 33 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 61 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 346 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 62 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 356 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 66 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 357 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2 </td>
  </tr>
</tbody>
</table>

---

# Padding our data


```r
data <- data %>%
  # create an 0/1 variable to identify a new power play
  # and a power_play_count variable
  mutate(new_power_play = ifelse(lag(game_seconds + event_length) == 
                                   game_seconds & lag(PP_team) ==
                                   PP_team, 0, 1), 
         new_power_play = ifelse(is.na(new_power_play), 
                                 1, new_power_play), 
         power_play_count = cumsum(new_power_play)) %>% 
* select(power_play_count, everything())
```

---

# Padding our data

<table class="table" style="font-size: 14px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> power_play_count </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> new_power_play </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 43 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 265 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 44 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 267 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 45 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 272 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 46 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 276 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 60 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 313 </td>
   <td style="text-align:right;"> 33 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 61 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 346 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 62 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 356 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 66 </td>
   <td style="text-align:left;"> PHI </td>
   <td style="text-align:right;"> 357 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
</tbody>
</table>

---

# Let's do a test


```r
sample <- data %>%
  filter(power_play_count == 1) %>%
  pad_int('game_seconds',
          start_val = 234,
          end_val = 283) %>%
  fill(power_play_count, game_id, PP_team, PP_fwds, 
       .direction = "down")
```

---

# Let's do a test


```r
sample <- data %>%
* filter(power_play_count == 1) %>%
  pad_int('game_seconds',
          start_val = 234,
          end_val = 283) %>%
  fill(power_play_count, game_id, PP_team, PP_fwds, 
       .direction = "down")
```

---

# Let's do a test

<table class="table" style="font-size: 14px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> power_play_count </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> new_power_play </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 43 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 265 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 44 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 267 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 45 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 272 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 46 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 276 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
</tbody>
</table>

---

# Let's do a test

<table class="table" style="font-size: 14px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> power_play_count </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> new_power_play </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 41 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> CAR </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 234 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 7 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 43 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 265 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 44 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 267 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 45 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 272 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 46 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 276 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
</tbody>
</table>

---

# Let's do a test

<table class="table" style="font-size: 14px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> power_play_count </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> new_power_play </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 43 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 265 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 44 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 267 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 45 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 272 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 46 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> CAR </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 276 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 7 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0 </td>
  </tr>
</tbody>
</table>

---

# Let's do a test


```r
sample <- data %>%
  filter(power_play_count == 1) %>% 
* pad_int('game_seconds',
*         start_val = 234,
*         end_val = 283) %>%
  fill(power_play_count, game_id, PP_team, PP_fwds, 
       .direction = "down")
```

---

# Let's do a test

<table class="table" style="font-size: 14px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> power_play_count </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> new_power_play </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 235 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 236 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 237 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 238 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 239 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 240 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 242 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 243 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
  </tr>
</tbody>
</table>

---

# Let's do a test

<table class="table" style="font-size: 14px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> power_play_count </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> new_power_play </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 234 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 235 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 236 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 237 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 238 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 239 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 240 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 241 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 242 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 243 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
  </tr>
</tbody>
</table>

---

# Let's do a test


```r
sample <- data %>%
  filter(power_play_count == 1) %>% 
  pad_int('game_seconds', 
          start_val = 234,
          end_val = 283) %>% 
* fill(power_play_count, game_id, PP_team, PP_fwds,
*      .direction = "down")
```

---

# Let's do a test

<table class="table" style="font-size: 14px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> power_play_count </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> new_power_play </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 235 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 236 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 237 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 238 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 239 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 240 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 242 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 243 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
</tbody>
</table>

---

# Let's do a test

<table class="table" style="font-size: 14px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> power_play_count </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> new_power_play </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> CAR </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 235 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 236 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 237 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 238 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 239 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 240 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> CAR </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 242 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 243 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
</tbody>
</table>

---

# When is it time for a function?

--

😬&nbsp; (Don't be scared like me.)

<br>

--

📝&nbsp; You've copied and pasted code more than twice.

<br>

--

🔁&nbsp; You need to run multiple lines of code on different segments of data.

--

<br>


```r
# basic syntax of a function

name_of_function <- function(needed_value) {
  
  # all the code goes here
  
}
```

---

# Padding our data


```r
padding_function <- function(count) {
  
  each_power_play <- data %>%
    filter(power_play_count == count)
  
  minimum <- min(each_power_play$game_seconds)
  maximum <- max(each_power_play$game_seconds + 
                   each_power_play$event_length - 1)
  
  padded <- each_power_play %>%
    pad_int('game_seconds',
            start_val = minimum,
            end_val = maximum) %>%
    fill(power_play_count, game_id, PP_team, PP_fwds, 
         .direction = "down")
}
```

---

# Padding our data


```r
*padding_function <- function(count) {
  
  each_power_play <- data %>%
    filter(power_play_count == count)
  
  minimum <- min(each_power_play$game_seconds)
  maximum <- max(each_power_play$game_seconds + 
                   each_power_play$event_length - 1)
  
  padded <- each_power_play %>%
    pad_int('game_seconds',
            start_val = minimum,
            end_val = maximum) %>%
    fill(power_play_count, game_id, PP_team, PP_fwds, 
         .direction = "down")
}
```

---

# Padding our data


```r
padding_function <- function(count) { 
  
* each_power_play <- data %>%
*   filter(power_play_count == count)
  
  minimum <- min(each_power_play$game_seconds)
  maximum <- max(each_power_play$game_seconds + 
                   each_power_play$event_length - 1)
  
  padded <- each_power_play %>%
    pad_int('game_seconds',
            start_val = minimum,
            end_val = maximum) %>%
    fill(power_play_count, game_id, PP_team, PP_fwds, 
         .direction = "down")
}
```

---

# Padding our data


```r
padding_function <- function(count) { 
  
  each_power_play <- data %>% 
    filter(power_play_count == count)
  
* minimum <- min(each_power_play$game_seconds)
* maximum <- max(each_power_play$game_seconds +
*                  each_power_play$event_length - 1)
  
  padded <- each_power_play %>%
    pad_int('game_seconds',
            start_val = minimum,
            end_val = maximum) %>%
    fill(power_play_count, game_id, PP_team, PP_fwds, 
         .direction = "down")
}
```

---

# Padding our data


```r
padding_function <- function(count) { 
  
  each_power_play <- data %>% 
    filter(power_play_count == count)
  
  minimum <- min(each_power_play$game_seconds) 
  maximum <- max(each_power_play$game_seconds +
                   each_power_play$event_length - 1)
  
* padded <- each_power_play %>%
*   pad_int('game_seconds',
*           start_val = minimum,
*           end_val = maximum) %>%
*   fill(power_play_count, game_id, PP_team, PP_fwds,
*        .direction = "down")
}
```

---

# Padding our data

A common scenario:

<br>

--

✂️&nbsp; Split the data into pieces

<br>

--

🔁&nbsp; Apply a function to each piece

<br>

--

➕&nbsp; Put it back together

<br>

--

We can do this with the `map()` family of functions in the `purrr` package.

---

# Padding our data


```r
data_padded <- 
  map_df(unique(data$power_play_count), padding_function)
```

--

`map_df` has two arguments: the data and the function

--


```r
unique(data$power_play_count)
```

We're telling it to perform the function for each unique value of `power_play_count` in the `data` data frame

--

It will apply our `padding_function` and return a data frame with the data padded

---

# Padding our data

<table class="table" style="font-size: 14px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> power_play_count </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> new_power_play </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 235 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 236 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 237 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 238 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 239 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 240 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 242 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 243 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
  </tr>
</tbody>
</table>

---

# Padding our data

<table class="table" style="font-size: 14px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> power_play_count </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> new_power_play </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2266 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;"> 2019020384 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CBJ </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2267 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;"> 2019020384 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CBJ </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2268 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;"> 2019020384 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CBJ </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2269 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;"> 2019020384 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CBJ </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2270 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;"> 2019020384 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CBJ </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2271 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;"> 2019020384 </td>
   <td style="text-align:right;"> 381 </td>
   <td style="text-align:left;"> CBJ </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2272 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;"> 2019020384 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CBJ </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2273 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;"> 2019020384 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CBJ </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2274 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;"> 2019020384 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CBJ </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2275 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;"> 2019020384 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CBJ </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;">  </td>
  </tr>
</tbody>
</table>

---

# Padding our data


```r
data_final <- data_padded %>%
  group_by(power_play_count) %>%
  # add in a new variable for the second of 
  # each power play, counting up from 1
  mutate(power_play_second = row_number()) %>%
  ungroup()
```

---

# Padding our data


```r
data_final <- data_padded %>%
  group_by(power_play_count) %>%
  # add in a new variable for the second of 
  # each power play, counting up from 1
  mutate(power_play_second = row_number()) %>%
* ungroup()
```

---

# Padding our data

<table class="table" style="font-size: 12px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> power_play_count </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> new_power_play </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> power_play_second </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 235 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 236 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 237 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 238 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 239 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 6 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 240 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 7 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 242 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 9 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 243 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 10 </td>
  </tr>
</tbody>
</table>

--


```r
max(data_final$power_play_second)
```

```
## [1] 120
```

---

# Problems we get to solve

✅&nbsp; Player position data is in a different place

<br>
<br>

❌&nbsp; Zone exit data is in a different place

<br>
<br>

✅&nbsp; One row per event instead of one row per second 🤔

---

# Tracking data


```r
data_final <- data_final %>%
  left_join(tracking, by = c("game_id", "game_seconds"))
```

---

# Tracking data

<table class="table" style="font-size: 12px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_seconds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> power_play_count </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> game_id </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_index </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_team </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_length </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> new_power_play </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> power_play_second </th>
   <th style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> event_type </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 234 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 235 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 236 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 237 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 238 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;"> EXIT </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 239 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 240 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 242 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;">  </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 243 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2019020336 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:left;"> CAR </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;font-weight: bold;color: white !important;background-color: #5C164E !important;">  </td>
  </tr>
</tbody>
</table>

--


```r
data_final %>% 
  get_dupes(game_id, game_seconds)
```

```
## # A tibble: 0 x 11
## # … with 11 variables: game_id <dbl>, game_seconds <dbl>, dupe_count <int>,
## #   power_play_count <dbl>, event_index <dbl>, PP_team <chr>,
## #   event_length <dbl>, PP_fwds <dbl>, new_power_play <dbl>,
## #   power_play_second <int>, event_type <chr>
```

---

# Problems we get to solve

✅&nbsp; Player position data is in a different place

<br>
<br>

✅&nbsp; Zone exit data is in a different place

<br>
<br>

✅&nbsp; One row per event instead of one row per second 🤔

---

class: center, middle, inverse

<blockquote>
If you can't handle the data cleaning,
you don't deserve the data analysis.
.center[-- <cite>Me</cite>]
</blockquote>

---

class: center, middle, inverse

# Does a four-forward power play unit have a higher rate of zone exits?

---

# Summarizing our data


```r
summary <- data_final %>%
  group_by(PP_fwds) %>%
  summarize(time_on_ice = sum(event_length, na.rm = TRUE) / 60,
            exits = sum(!is.na(event_type))) %>%
  mutate(exit_rate = exits * 60 / time_on_ice)
```

---

# Summarizing our data


```r
summary <- data_final %>% 
* group_by(PP_fwds) %>%
  summarize(time_on_ice = sum(event_length, na.rm = TRUE) / 60,
            exits = sum(!is.na(event_type))) %>%
  mutate(exit_rate = exits * 60 / time_on_ice)
```

---

# Summarizing our data


```r
summary <- data_final %>%
  group_by(PP_fwds) %>%
* summarize(time_on_ice = sum(event_length, na.rm = TRUE) / 60,
            exits = sum(!is.na(event_type))) %>%
  mutate(exit_rate = exits * 60 / time_on_ice)
```

---

# Summarizing our data


```r
summary <- data_final %>%
  group_by(PP_fwds) %>%
  summarize(time_on_ice = sum(event_length, na.rm = TRUE) / 60, 
*           exits = sum(!is.na(event_type))) %>%
  mutate(exit_rate = exits * 60 / time_on_ice)
```

---

# Summarizing our data


```r
summary <- data_final %>%
  group_by(PP_fwds) %>%
  summarize(time_on_ice = sum(event_length, na.rm = TRUE) / 60, 
            exits = sum(!is.na(event_type))) %>% 
* mutate(exit_rate = exits * 60 / time_on_ice)
```

---

# Summarizing our data


```r
summary <- data_final %>%
  group_by(PP_fwds) %>%
  summarize(time_on_ice = sum(event_length, na.rm = TRUE) / 60, 
            exits = sum(!is.na(event_type))) %>% 
  mutate(exit_rate = exits * 60 / time_on_ice)
```

<table class="table" style="font-size: 20px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> time_on_ice </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> exits </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> exit_rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 11.25 </td>
   <td style="text-align:right;"> 17 </td>
   <td style="text-align:right;"> 90.66667 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 30.50 </td>
   <td style="text-align:right;"> 66 </td>
   <td style="text-align:right;"> 129.83607 </td>
  </tr>
</tbody>
</table>

---

class: center, middle, inverse

# Let's make a graph!

---

# The simplest graph


```r
summary %>%
  ggplot(aes(x = as.character(PP_fwds), y = exit_rate)) +
  geom_bar(stat="identity")
```

<img src="figs/CMSAC/unnamed-chunk-116-1.png" width="70%" style="display: block; margin: auto;" />

---

# A little better


```r
summary %>%
  ggplot(aes(x = as.character(PP_fwds), y = exit_rate)) +
  geom_bar(stat="identity") +
* labs(title = "Rate of zone exits on the power play",
*      subtitle = "5v4 only, 4 NHL games November 2019",
*      x = "Number of forwards on the power play",
*      y = "Zone exits per 60 minutes") +
* geom_text(aes(label = round(exit_rate, 2)), vjust = 1.6,
*           color = "white", size = 4)
```

---

# A little better

<img src="figs/CMSAC/unnamed-chunk-118-1.png" width="70%" style="display: block; margin: auto;" />

---

# With color!


```r
summary %>%
  ggplot(aes(x = as.character(PP_fwds), y = exit_rate, 
*            fill = as.character(PP_fwds))) +
  geom_bar(stat="identity") +
  labs(title = "Rate of zone exits on the power play",
       subtitle = "5v4 only, 4 NHL games November 2019",
       x = "Number of forwards on the power play", 
       y = "Zone exits per 60 minutes") +
  geom_text(aes(label = round(exit_rate, 2)), vjust = 1.6, 
            color = "white", size = 4) +
* scale_fill_manual(values = c("#808080", "#5C164E")) +
  theme(legend.position = "none")
```

---

# With color!

<img src="figs/CMSAC/unnamed-chunk-120-1.png" width="70%" style="display: block; margin: auto;" />

---

# Much better


```r
summary %>%
  ggplot(aes(x = as.character(PP_fwds), y = exit_rate, 
             fill = as.character(PP_fwds))) +
  geom_bar(stat="identity") +
  labs(title = "Rate of zone exits on the power play",
       subtitle = "5v4 only, 4 NHL games November 2019",
       x = "Number of forwards on the power play", 
       y = "Zone exits per 60 minutes") +
  geom_text(aes(label = round(exit_rate, 2)), vjust = 1.6, 
            color = "white", size = 4) +
  scale_fill_manual(values = c("#808080", "#912919")) +
* CMSAC_theme() +
  theme(legend.position = "none")
```

---

# Much better

<img src="figs/CMSAC/unnamed-chunk-122-1.png" width="70%" style="display: block; margin: auto;" />

---

# What are the benefits of creating a custom theme?

🕢&nbsp; Saves time!

<br>
<br>

--

⭐&nbsp; Helps establish your #brand.

<br>
<br>

--

❤️&nbsp; Looks way prettier than a standard `ggplot2` graph.

---

# Custom theme how-to

📝&nbsp; Use Google fonts


```r
library(showtext)
font_add_google("Open Sans", "opensans")
```

--

📓&nbsp; Design your theme


```r
CMSAC_theme <- function () { 
  theme_linedraw(base_size=11, base_family="opensans") %+replace% 
    theme(
    axis.ticks = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    plot.title = element_text(size = 15, hjust = 0, vjust = 0.5, 
                              margin = margin(b = 0.2, unit = "cm")),
    plot.subtitle = element_text(size = 9, face = "italic", hjust = 0, 
                  vjust = 0.5, margin = margin(b = 0.2, unit = "cm")),
    axis.title = element_text(face = "bold"))
  }
```

---

# Custom theme how-to

📝&nbsp; Use Google fonts


```r
library(showtext)
font_add_google("Open Sans", "opensans")
```

📓&nbsp; Design your theme


```r
CMSAC_theme <- function () { 
* theme_linedraw(base_size=11, base_family="opensans") %+replace%
    theme(
    axis.ticks = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    plot.title = element_text(size = 15, hjust = 0, vjust = 0.5, 
                              margin = margin(b = 0.2, unit = "cm")),
    plot.subtitle = element_text(size = 9, face = "italic", hjust = 0, 
                  vjust = 0.5, margin = margin(b = 0.2, unit = "cm")),
    axis.title = element_text(face = "bold"))
  }
```

---

# Custom theme how-to

📝&nbsp; Use Google fonts


```r
library(showtext)
font_add_google("Open Sans", "opensans")
```

📓&nbsp; Design your theme


```r
CMSAC_theme <- function () { 
  theme_linedraw(base_size=11, base_family="opensans") %+replace% 
    theme(
*   axis.ticks = element_blank(),
*   panel.grid.minor = element_blank(),
*   panel.grid.major = element_blank(),
    plot.title = element_text(size = 15, hjust = 0, vjust = 0.5, 
                              margin = margin(b = 0.2, unit = "cm")),
    plot.subtitle = element_text(size = 9, face = "italic", hjust = 0, 
                  vjust = 0.5, margin = margin(b = 0.2, unit = "cm")),
    axis.title = element_text(face = "bold"))
  }
```

---

# Custom theme how-to

📝&nbsp; Use Google fonts


```r
library(showtext)
font_add_google("Open Sans", "opensans")
```

📓&nbsp; Design your theme


```r
CMSAC_theme <- function () { 
  theme_linedraw(base_size=11, base_family="opensans") %+replace% 
    theme(
    axis.ticks = element_blank(), 
    panel.grid.minor = element_blank(), 
    panel.grid.major = element_blank(), 
*   plot.title = element_text(size = 15, hjust = 0, vjust = 0.5,
*                             margin = margin(b = 0.2, unit = "cm")),
*   plot.subtitle = element_text(size = 9, face = "italic", hjust = 0,
*                 vjust = 0.5, margin = margin(b = 0.2, unit = "cm")),
*   axis.title = element_text(face = "bold"))
  }
```

---

# Custom theme how-to

1️⃣&nbsp; Start with an existing theme: `theme_linedraw()`, `theme_classic()`, `theme_light()`, `theme_minimal()`, etc.

--

2️⃣&nbsp; Use the [ggplot2 theme reference page](https://ggplot2.tidyverse.org/reference/theme.html) to find your arguments.

--

3️⃣&nbsp; Investigate the options within those arguments.


```r
theme_minimal <- theme_minimal()
theme_minimal$plot.subtitle
```

```
## List of 11
##  $ family       : NULL
##  $ face         : NULL
##  $ colour       : NULL
##  $ size         : NULL
##  $ hjust        : num 0
##  $ vjust        : num 1
##  $ angle        : NULL
##  $ lineheight   : NULL
##  $ margin       : 'margin' num [1:4] 0pt 0pt 5.5pt 0pt
##   ..- attr(*, "valid.unit")= int 8
##   ..- attr(*, "unit")= chr "pt"
##  $ debug        : NULL
##  $ inherit.blank: logi TRUE
##  - attr(*, "class")= chr [1:2] "element_text" "element"
```

---

class: center, middle, inverse

# How does the positional composition change over the time of the power play?

---

# Summarizing our data


```r
time <- data_final %>%
  group_by(power_play_second, PP_fwds) %>%
  summarize(n = n()) %>%
  add_tally(n, name = "total") %>%
  mutate(percent = n / total)
```

---

# Summarizing our data


```r
time <- data_final %>%
* group_by(power_play_second, PP_fwds) %>%
* summarize(n = n()) %>%
  add_tally(n, name = "total") %>%
  mutate(percent = n / total)
```

---

# Summarizing our data

<table class="table" style="font-size: 20px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> power_play_second </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> n </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 9 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 18 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 9 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 18 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 9 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 18 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 9 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 18 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 18 </td>
  </tr>
</tbody>
</table>

---

# Summarizing our data


```r
time <- data_final %>%
  group_by(power_play_second, PP_fwds) %>%
  summarize(n = n()) %>% 
* add_tally(n, name = "total") %>%
  mutate(percent = n / total)
```

---

# Summarizing our data

<table class="table" style="font-size: 20px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> power_play_second </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> n </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> total </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 27 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 27 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 27 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 27 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 27 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 27 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 27 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 27 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 26 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 26 </td>
  </tr>
</tbody>
</table>

---

# Summarizing our data


```r
time <- data_final %>%
  group_by(power_play_second, PP_fwds) %>%
  summarize(n = n()) %>% 
  add_tally(n, name = "total") %>% 
* mutate(percent = n / total)
```

---

# Summarizing our data

<table class="table" style="font-size: 20px; width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> power_play_second </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> PP_fwds </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> n </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> total </th>
   <th style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> percent </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0.3333333 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0.6666667 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0.3333333 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0.6666667 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0.3333333 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0.6666667 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0.3333333 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0.6666667 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 26 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0.3076923 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> 26 </td>
   <td style="text-align:right;font-weight: bold;color: white !important;background-color: #5C164E !important;"> 0.6923077 </td>
  </tr>
</tbody>
</table>

---

# Making an area graph


```r
time %>%
  mutate(PP_fwds = ifelse(PP_fwds == 3, 
                          "3 forwards", "4 forwards")) %>%
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
```

---

# Making an area graph

<img src="figs/CMSAC/unnamed-chunk-140-1.png" width="70%" style="display: block; margin: auto;" />

---

# Making an area graph


```r
time %>%
* mutate(PP_fwds = ifelse(PP_fwds == 3,
*                         "3 forwards", "4 forwards")) %>%
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
```

---

# Making an area graph


```r
time %>%
  mutate(PP_fwds = ifelse(PP_fwds == 3, 
                          "3 forwards", "4 forwards")) %>%
  ggplot(aes(x = power_play_second, y = percent, fill = PP_fwds)) + 
* geom_area() +
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
```

---

# Making an area graph


```r
time %>%
  mutate(PP_fwds = ifelse(PP_fwds == 3, 
                          "3 forwards", "4 forwards")) %>%
  ggplot(aes(x = power_play_second, y = percent, fill = PP_fwds)) + 
  geom_area() + 
  labs(title = "Composition of the power play",
       subtitle = "5v4 only, 4 NHL games November 2019",
       x = "Second of the power play") +
  scale_fill_manual(values = c("#808080", "#912919")) +
* scale_y_continuous(labels = scales::percent_format(accuracy = 1),
*                    expand = c(0, 0)) +
* scale_x_continuous(limits = c(1, 120),
*                    breaks = seq(0, 120, 20),
*                    expand = c(0, 0)) +
  CMSAC_theme() +
  theme(legend.position = c(0.87, 1.106),
        legend.title = element_blank(),
        axis.title.y = element_blank())
```

---

# Making an area graph

<img src="figs/CMSAC/unnamed-chunk-144-1.png" width="70%" style="display: block; margin: auto;" />

---

# Making an area graph


```r
time %>%
  mutate(PP_fwds = ifelse(PP_fwds == 3, 
                          "3 forwards", "4 forwards")) %>%
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
* theme(legend.position = c(0.87, 1.106),
*       legend.title = element_blank(),
*       axis.title.y = element_blank())
```

---

# We've done a lot!

<img src="figs/CMSAC/Rudd.gif" width="300" style="display: block; margin: auto;" />

⭐&nbsp; Pivoted and joined data with `tidyr` and `dplyr`.

<br>

⭐&nbsp; Wrote our own function and used `purrr` to apply it iteratively.

<br>

⭐&nbsp; Created a custom theme and made an area graph.

<br>

--

❗&nbsp; Slides/data/code are available on my website and Github so you can review.

---

class: center, middle

# Thanks!

<!--html_preserve--><i class="fab  fa-twitter "></i><!--/html_preserve--> [@MeghanMHall](https://twitter.com/MeghanMHall)
<br>
<!--html_preserve--><i class="fab  fa-github "></i><!--/html_preserve--> [meghall06](https://github.com/meghall06) 
<br>
<!--html_preserve--><i class="fas  fa-link "></i><!--/html_preserve--> [meghan.rbind.io](https://meghan.rbind.io)
<br>
<!--html_preserve--><i class="fas  fa-envelope "></i><!--/html_preserve--> meghanhall6@gmail.com
<br>
<br>
Slides created via the R package [**xaringan**](https://github.com/yihui/xaringan).
