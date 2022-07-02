---
layout: default
title: Difference-in-Difference (DiD)
nav_order: 1
description: "Welcome to the DiD revolution."
image: "/assets/images/DiD.jpg"
permalink: /
---


# Welcome!

*Last updated: July 2022*

This repository tracks the recent developments in the **Difference-in-Difference (DiD)** literature. It serves two purposes. First, it is an organized collection of my bookmarks from Twitter, GitHub, YouTube etc. The aim here is to keep track of the updates. Second is to make sense of the different packages from an end-user's perspective. This part has to do with how to apply these methods in our day-to-day applied research work. On the theory side, several really useful resources already exist (see the [Resources](https://asjadnaqvi.github.io/DiD/docs/resources) section) and workshops are also regularly organized.

I will keep adding content to this website until necessary. It might contain errors or the language might not be precise enough. This probably reflects my own poor understanding. So please give feedback! The aim of this repository is to collectively build up notes and a code base that we can all use.

Some thoughts below from my own perspective (these are also subject to change over time):


## What happened? The DiD renaissance

Several DiD innovations came out simultaneously (well, it was actually a staggered roll-out) in 2020 and 2021. At the heart of this new DiD literature is the premise that the classic Twoway Fixed Effects (TWFE) model can give [wrong estimates](https://asjadnaqvi.github.io/DiD/docs/code/06_twfe/). This is especially true if the treatments are heterogeneous (differential treatment timings, different treatment sizes, different treatment statuses over time) which can result in "negative weights", that dilute the true treatment effect. Recent innovations like the [Bacon decomposition](https://asjadnaqvi.github.io/DiD/docs/code/06_bacon/) unpacks the weights of each combination of untreated, early treated, and late treated groups. 

The different papers that introduce DiD packages start with TWFE bashing and use various methodological innovations to "correct" for TWFE biases. Within these packages are different ways of handling different DiD aspects like parallel trends, negative weights, and covariates. This is done using various methods ranging from bootstrapping, inverse probability weights, matching, influence functions, and imputations, etc. The packages are currently being improved, and it is not very clear which package to use for which problem. Hopefully, more will be written on comparing the utility of each estimation technique by those who know this stuff better. At the time of writing this (July 2022), new package versions are slotted to be released and newer ones are expected to come out. But hopefully, we will also see more applications and replications that can help us understand the nuances of the different methods. Additionally, in 2022, several review papers were released, that summarize the state of the field. These papers are a good starting point to familiarize oneself with the methods and are marked in the [literature](https://asjadnaqvi.github.io/DiD/docs/reading/04_literature/) section.


## Misc info

This is a working document. If you want to report errors or contribute, just [open an issue](https://github.com/AsjadNaqvi/DiD/issues), or [start a discussion](https://github.com/asjadnaqvi/DiD/discussions), or e-mail me at asjadnaqvi@gmail.com. Since paths and links are also subject to change, please report them to keep this repository as up-to-date as possible.

I am slowly starting to build a Stata code repository here. This is to help me (and you) navigate the literature and figure out the code structure for different packages. If you can improve these, then please open a pull request (PR).If you use this repository and find it helpful, acknowledgements will be highly appreciated!



