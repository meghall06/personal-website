---
title: "Wrapping Up The Penalty Kill Project"
diagram: yes
date: '2020-02-24'
markup: mmark
math: yes
categories: ["hockey analysis"]
image:
  caption: null
  placement: null
---

Last year, I tracked 1146 minutes of penalty kills, spread across 12 teams from the 2018-19 season. The teams were chosen semi-randomly (to get a decent distribution of shot attempt rates, both for and against), and games were selected randomly to end up with about a quarter of all penalty kill minutes for that team during 2018-19. I tracked zone time (so that I could track how well a penalty kill was able to keep a power play out of its offensive zone and also calculate shot rates for offensive zone time only), as well as zone entries and exits.

| Selected Teams    |
| ------------------|
| Chicago            |
| Colorado |
| Dallas            |
| Winnipeg |
| Vegas            |
| Edmonton |
| Vancouver |
| New Jersey            |
| NY Islanders |
| NY Rangers            |
| Philadelphia |
| Florida            |

The bulk of the penalty kill data is available in the <a href="https://drive.google.com/file/d/1XjUKQn1yw7K_Rvdtv7h1FKcqkeQfN7q6/view" target="_blank">slides from my OTTHAC presentation</a> and the <a href="https://public.tableau.com/profile/balls.and.sticks#!/vizhome/DiscreteDefensiveStrategiesonthePenaltyKill/PK" target="_blank">data visualization that accompanied it</a>.

### Power play data

However, tracking penalty kills means I automatically have some data on power plays! I ended up with some data for all 31 teams, but here I have restricted the plots to the 11 teams for which I had the most data (60 to ~100 minutes). This isn't enough game time to make sweeping conclusions, but it's enough to look at a few graphs.

| Selected Teams    |
| ------------------|
| Buffalo |
| Calgary            |
| Colorado |
| Edmonton            |
| Florida |
| Nashville            |
| Ottawa |
| Philadelphia |
| St. Louis            |
| Vancouver           |
| Washington |

Shown below is the percent of total power play time on ice that the power play spent in its offensive zone. I was surprised to see a relatively small spread in the percentages (besides Ottawa).

{{< figure src="PP_OZ.png" lightbox="true" >}}

As I mentioned previously with the penalty kill data, having zone time makes it possible to calculate a per 60 shot rate (for unblocked shot attempts, in this case) that is based on offensive zone time only, instead of just total power play time on ice. This shows how frequently teams generate shots when they're actually in the zone.

{{< figure src="PP_OZ_FF.png" lightbox="true" >}}

It's interesting to contrast Ottawa and Colorado in these two graphs. Ottawa wasn't particularly successful at staying in the offensive zone, but when they were there, they generated a lot of unblocked shot attempts. Colorado was nearly the opposite, in that they spent a lot of time in the offensive zone but weren't as prolific with the shots. The "regular" unblocked shot attempt rates for the two teams over these games were nearly identical.

{{< figure src="PP_OZ_dump.png" lightbox="true" >}}

Lastly, since I tracked zone entry data, as well, we can look at how power play teams tended to enter their own zone by examining the percentage of all entries that were dump-ins versus carries and passes. In this smallish sample there was a wide variation between teams that tended to dump the puck in more (Nashville, Calgary) and teams that ver rarely did (Colorado, Ottawa).

