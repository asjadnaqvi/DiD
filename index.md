---
layout: default
title: Difference-in-Difference (DiD)
nav_order: 1
description: "Welcome to the DiD revolution."
image: "/assets/images/DiD.jpg"
permalink: /
---


# Welcome!

*Last updated: August 2022*

This repository tracks the recent developments in the **Difference-in-Difference (DiD)** literature. It serves two purposes. First, it is an organized collection of various bookmarks from Twitter, GitHub, YouTube etc. Second is to make sense of the different packages from an end-user's perspective. This part has to do with how to apply these methods in daily applied research work. On the theory side, several really useful resources already exist (see the [Resources](https://asjadnaqvi.github.io/DiD/docs/resources) section) and workshops are also regularly organized. Please refer to the original papers or notes and lectures by authors for a better understanding of the theory.

I will keep adding content to this website until necessary. It might contain errors or the language might not be precise enough. This probably reflects my own poor understanding. So please give feedback! The aim of this repository is to collectively build up notes and a code base that we can all use.

Some thoughts below from my own perspective (these are also subject to change over time):


## What happened? The DiD renaissance

Several DiD innovations came out simultaneously in 2020 and 2021 with some staggered roll-outs in 2022. At the heart of this new DiD literature is the premise that the classic Twoway Fixed Effects (TWFE) model can give [wrong estimates](https://asjadnaqvi.github.io/DiD/docs/code/06_twfe/). This is especially true if the treatments are heterogeneous (differential treatment timings, different treatment sizes, different treatment statuses over time) which can result in "negative weights". As a result, the TWFE estimates dilute the true treatment effects. 

Recent innovations like the [Bacon decomposition](https://asjadnaqvi.github.io/DiD/docs/code/06_bacon/) help us unpack the weights of the different combinations of different treated and untreated cohorts. The recent DiD methods papers introduce various DiD estimation techniques that "correct" for TWFE biases. Within these packages are different ways of handling parallel trends, negative weights, covariates, controls, etc. This is done using different methods ranging from bootstrapping, inverse probability weights, matching, influence functions, imputations, etc. The packages are currently being improved, and it is not very clear which method/package to use for which problem. Hopefully, more will be written on comparing the utility of each estimation technique by those who know this stuff better. At the time of writing this (August 2022), new papers and package are still being released. But hopefully, we will also see more applications and replications that can help us understand the nuances of the different methods. Additionally, in 2022, several review papers were released that summarize the state of the field. These papers are a good starting point to familiarize oneself with the methods and are marked in the [literature](https://asjadnaqvi.github.io/DiD/docs/reading/04_literature/) section.


## Misc info

This is a working document. If you want to report errors or contribute, just [open an issue](https://github.com/AsjadNaqvi/DiD/issues), or [start a discussion](https://github.com/asjadnaqvi/DiD/discussions), or e-mail me at asjadnaqvi@gmail.com. Since paths and links are also subject to change, please report them to keep this repository as up-to-date as possible.

I am slowly starting to build a Stata code repository here. This is to help me (and you) navigate the literature and figure out the code structure for different packages. If you can improve these, then please open a pull request (PR). If you use this repository and find it helpful, acknowledgements will be highly appreciated!



