---
title: R in spoRts
description: |
  My personal blog.
author: "Meghan Hall"
show_post_thumbnail: true
thumbnail_left: true # for list-sidebar only
show_author_byline: true
show_post_date: true
# for listing page layout
layout: list-sidebar # list, list-sidebar, list-grid

# for list-sidebar layout
sidebar: 
  title: R in spoRts
  description: |
    I write about a wide variety of topics—sometimes specifically about hockey, sometimes more generally about R.
  author: "Meghan Hall"
  text_link_label: View post categories
  text_link_url: /categories/

# set up common front matter for all pages inside blog/
cascade:
  author: "Meghan Hall"
  show_author_byline: true
  show_post_date: true
  show_comments: false # see site config to choose Disqus or Utterances
  # for single-sidebar layout
  sidebar:
    text_link_label: View recent posts
    text_link_url: /blog/
    show_sidebar_adunit: false # show ad container
---

** No content below YAML for the blog _index. This file provides front matter for the listing page layout and sidebar content. It is also a branch bundle, and all settings under `cascade` provide front matter for all pages inside blog/. You may still override any of these by changing them in a page's front matter.**