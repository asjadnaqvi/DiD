---
layout: default
title: Welcome to DiD
nav_order: 1
description: "Welcome to the DiD repository"
image: "/assets/images/DiD.png"
permalink: /
---


# Welcome to this DiD repository

This repository tracks the recent developments in the **Difference-in-Difference (DiD)** literature. It serves two purposes. First, it is an organized dump of my bookmarks from Twitter, GitHub, YouTube etc. The aim here is to keep track of the DiD developments. The second is to make sense out of all of it from an end-user perspective in terms of application. This part has to do with applying these methods in papers. On the theory side, several really useful notes already exist (see the Readings section on the left).

I will keep adding content on this website. It might contain errors or the language might not be precise enough. And this probably reflects my own poor understanding of what is going on since I am also trying to make sense out of all of this. So please give feedback! The aim of this repository is to collectively build up notes and a code base that we can all use for our research. 

Some thoughts below from my own perspective (these are also subject to change over time):


## What happened? The DiD renaissance

Several DiD innovations came out simultaneously in 2020 and 2021 leading to collective confusion online. The new-DiD literature agrees with the premise that the classic Twoway Fixed Effects (TWFE) model gives wrong estimates of treatment effects especially if the treatments are heterogenous (differential treatment timings, different treatment sizes, different treatment status over time) caused by "negative weights". These can be seen by comparing combinations of late treated with early treated, and/or not treated. There is also some agreement that these biases still persist *even if* treatments are not staggered. Hence TWFE models are still being scrutinized and probably need to be subjected to tests like the Bacon decomposition. 

Starting from TWFE-bashing, the different DiD packages uses different methodological innovations to "correct" for biases especially negative weights. Within these packages there are different lines of thought in how to deal with: (a) parallel trends, (b) covariates, (c) negative weights arising from TWFE estimates. All sorts of methods have been thrown in different packages including bootstrapping, inverse probability weights, matching, influence functions, imputations etc. Here also lies my own confusion in terms of which package to use for which problem. Based on readings online, it seems like it all boils down the research question and the estimand, which also makes all of this very subjective. Hopefully, more will be written on comparing the utility of each package by the experts out there. But at the time of writing this, more innovations are expected to come out in the coming months.

## Why should we invest in DiD?

Because not everything can be an RCT. I have overseen quite a lot of RCTs. On the one hand, RCTS are methodologically very clean, but are really expensive to run. Plus they require quite a bit of social and politcal capital to execute, especially in a developing country setting. There are also issues of external validity that keep coming up (I will write more on RCTs in another space). On the other hand, other quasi-experimental methods like IVs and RDDs are hard to find in secondary data. This makes DiDs, in terms of applicability, one of the most powerful tools out there. It is easy to get secondary micro data (for countries that make these things accesible), and it is also relatively easy to find exogenous interventions with differential timings (that's basically all policy implementations). And the straggered treatment graphs are just easy to present especially to policymakers (don't underestimate the research-to-policy aspect). Furthemore, my hunch is that the methodological issues identified with TWFEs that led to DiD papers will also spillover into IV and RDD methodology papers in the coming years resulting in further confusion. So investing in the DiD literature now will provide a strong foundation for keep track of the the upcoming methodology papers.


## Misc info

This is a working document. If you want to report errors or contribute, just [open an issue](https://github.com/AsjadNaqvi/DiD/issues), or [start a discussion](https://github.com/asjadnaqvi/DiD/discussions), or e-mail at asjadnaqvi@gmail.com. Since paths and links are also subject to change, please report them to keep this repository as up-to-date as possible. I might add a discussion section below posts to allow for direct comments.

I will slowly build up this website with some Stata code. This is to help me (and you) navigate the literature and figure out the code structure for different packages.



