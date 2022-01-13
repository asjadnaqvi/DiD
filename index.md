---
layout: default
title: Difference-in-Difference (DiD)
nav_order: 1
description: "Welcome to the DiD revolution."
image: "/assets/images/DiD.jpg"
permalink: /
---

<img src="./assets/images/DiD_banner.jpg">

# Welcome!

This repository tracks the recent developments in the **Difference-in-Difference (DiD)** literature. It serves two purposes. First, it is an organized dump of my bookmarks from Twitter, GitHub, YouTube etc. The aim here is to keep track of the DiD updates. The second is to make sense of the different packages from an end-user's perspective. This part has to do with how to apply these methods in our research work. On the theory side, several really useful notes already exist (see the [Resources](https://asjadnaqvi.github.io/DiD/docs/resources) section).

I will keep adding content to this website. It might contain errors or the language might not be precise enough. This probably reflects my own poor understanding of what is going on. So please give feedback! The aim of this repository is to collectively build up notes and a code base that we can all use.

Some thoughts below from my own perspective (these are also subject to change over time):


## What happened? The DiD renaissance

Several DiD innovations came out simultaneously (well, it was actually a staggered roll-out) in 2020 and 2021. At the heart of this new DiD literature is the premise that the classic Twoway Fixed Effects (TWFE) model can give [wrong estimates](https://asjadnaqvi.github.io/DiD/docs/code/06_twfe/). This is especially true if the treatments are heterogeneous (differential treatment timings, different treatment sizes, different treatment statuses over time) which can result in "negative weights" that dilute the true ATT. The negative weights can be derived by comparing combinations of late-treated with early-treated, and treated versus not-treated groups ([Bacon decomposition](https://asjadnaqvi.github.io/DiD/docs/code/06_bacon/)). There is also some discussion that these biases still persist *even if* the treatments are not staggered. 

The different DiD packages start with TWFE bashing and use different methodological innovations to "correct" for TWFE biases. Within these packages are different ways of handling different DiD aspects like parallel trends, negative weights, and covariates. This is done using various methods ranging from bootstrapping, inverse probability weights, matching, influence functions, and imputations, etc. 

Here also lies my own confusion in terms of which package to use and for which problem. For example, why is one method better than the other for a specific estimation. In order to answer this, more information is needed on the estimation methods. Currently, the package choice for analysis seems a bit arbitrary and subjective. Hopefully, more will be written on comparing the utility of each estimation technique by those who know this stuff better. At the time of writing this (Jan 2022), more innovations are expected to come out in the coming months, but hopefully, we will also see more applications and replications. What is now out already are review papers that succiently summarize the state of the field (Jan 2022). See the [literature](https://asjadnaqvi.github.io/DiD/docs/reading/04_literature/) section for more details.


## Why should we invest in DiD?

Let's look at the methods we already know. While each have their own applications and advantages, there are some practical limitations as well. Conducting randomized experiments (RCTs) is not possible in all circumstances, despite being methodologically clean. In contrast, applications of quasi-experimental methods like IVs, synthetic controls, and RDDs are hard to find. This makes DiDs, in terms of applicability, a very powerful tool. If one has access to good primary or even secondary data, it is relatively easy to find interventions that can be tested on the data. Furthermore, these treatments usually have differential timings. Very rarely we see uniform and homogeneous roll-out of treatments. And this makes the new DiD methods useful for two reasons. First, they correct the TWFE issues that are likely to provide wrong estimates especially in a differential treatment setting. And second, the event study setup is just a very powerful visual tool that makes the results easy to understand. Additionally, going from data to results is fairly fast (as compared to RCTs). While the fast implementation holds from a technical standpoint, one should be very careful about theory, context, and other socioeconomic factors. This also recently (Jan 2022) raised some [concerns](https://twitter.com/MeganTStevenson/status/1478108770836353029). 

My hunch is that the methodological issues identified with TWFEs, that led to new DiD papers, might also spillover into IV and RDD papers in the coming years. So investing in the DiD literature now will provide a strong foundation for keeping track of the the upcoming innovations. But as we start 2022, [review papers](https://asjadnaqvi.github.io/DiD/docs/reading/04_literature/#papers) that summarize the recent developments have started popping up.


## Misc info

This is a working document. If you want to report errors or contribute, just [open an issue](https://github.com/AsjadNaqvi/DiD/issues), or [start a discussion](https://github.com/asjadnaqvi/DiD/discussions), or e-mail at asjadnaqvi@gmail.com. Since paths and links are also subject to change, please report them to keep this repository as up-to-date as possible. I might add a discussion section below posts to allow for direct comments.

I am slowly starting to build a Stata code repository here. This is to help me (and you) navigate the literature and figure out the code structure for different packages. If you can improve these, then please open a pull request (PR). 



