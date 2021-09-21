---
layout: default
title: Welcome to DiD
nav_order: 1
description: "Welcome to the DiD repository"
image: "/assets/images/DiD.png"
permalink: /
---


# Welcome to this DiD page

This repository tracks the recent developments in the **Difference-in-Difference (DiD)** literature. It serves two purposes. First, it is an organized dump of my bookmarks from Twitter, GitHub, YouTube etc. The aim here is to keep track of the DiD developments. The second is to make sense out of all of it from an end-user perspective in terms of application. This part has to do with how to apply these methods in our research work. On the theory side, several really useful notes already exist (see the [Readings](https://asjadnaqvi.github.io/DiD/docs/reading) section).

I will keep adding content to this website. It might contain errors or the language might not be precise enough. This probably reflects my own poor understanding of what is going on since I am also trying to make sense out of all of this. So please give feedback! The aim of this repository is to collectively build up notes and a code base that we can all use. 

Some thoughts below from my own perspective (these are also subject to change over time):


## What happened? The DiD renaissance

Several DiD innovations came out simultaneously in 2020 and 2021 leading to collective confusion online. At the core of this new-DiD literature is the premise that the classic Twoway Fixed Effects (TWFE) model gives wrong estimates of treatment effects. This is especially true if the treatments are heterogenous (differential treatment timings, different treatment sizes, different treatment status over time) which can result in "negative weights" that dilute the true treatment effects. The negative weights can be derived by comparing combinations of late-treated with early-treated, and not-treated groups (Bacon-decomposition). There is also broad agreement that these biases still persist *even if* treatments are not staggered. 

Starting from TWFE-bashing, the different DiD packages uses different methodological innovations to "correct" for biases arising from the TWFE method. Within these packages are different lines of thought that deal with: (a) parallel trends, (b) covariates, and (c), negative weights. All sorts of methods have been utilized across different packages including bootstrapping, inverse probability weights, matching, influence functions, and imputations to adjust for the above three points. 

Here also lies my own confusion in terms of which package to use for which problem. Based on readings online, it seems like it all boils down the research question what really we are trying to estimate. This sort of makes the package choice for analysis a bit subjective. Hopefully, more will be written on comparing the utility of each package by the experts out there. But at the time of writing this, more innovations are expected to come out in the coming months. So the current aim is to at least get the DiD packages up and running. 

## Why should we invest in DiD?

Because not everything can be evauated using an RCT. RCTS are methodologically very clean, but are really costly both in terms of time and money simply because of their life-cycle. Plus they require quite a bit of social and politcal capital to execute, especially in a developing-country setting. In contrast, applications of quasi-experimental methods like IVs and RDDs are hard to find especially when using secondary data. This makes DiDs, in terms of applicability, one of the most powerful tools out there. If one has access to detailed secondary micro data, it is also relatively easy to find exogenous interventions with differential timings (that is basically all policy implementations) and test their impacts. Here going from data to results is fairly fast (as compared to RCTs) and the straggered treatment graphs are just visually very easy to present especially to policymakers. Thus this method, if used properly, can also have powerful policy implications. Furthemore, my hunch is that the methodological issues identified with TWFEs, that led to new DiD papers, will also spillover into IV and RDD methodology papers in the coming years. So investing in the DiD literature now will provide a strong foundation for keep track of the the upcoming methodological innovations.


## Misc info

This is a working document. If you want to report errors or contribute, just [open an issue](https://github.com/AsjadNaqvi/DiD/issues), or [start a discussion](https://github.com/asjadnaqvi/DiD/discussions), or e-mail at asjadnaqvi@gmail.com. Since paths and links are also subject to change, please report them to keep this repository as up-to-date as possible. I might add a discussion section below posts to allow for direct comments.

I will slowly build up this website with some Stata code. This is to help me (and you) navigate the literature and figure out the code structure for different packages.



