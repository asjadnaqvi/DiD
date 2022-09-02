---
layout: default
title: Difference-in-Difference (DiD)
nav_order: 1
description: "Welcome to the DiD revolution."
image: "/assets/images/DiD.jpg"
permalink: /
---


# Welcome!

*Last updated: September 2022*

This repository tracks the recent developments and innovations in the **Difference-in-Difference (DiD)** literature. It serves two purposes. First, it is an organized collection of various bookmarks from Twitter, GitHub, YouTube etc. Second, it aims to present the different packages from an end-user's perspective. This part has to do with how to apply these methods in day-to-day applied research. On the theory side, several really useful resources are listed in the [Resources](https://asjadnaqvi.github.io/DiD/docs/resources) including workshops and notes by some of the key authors leading the development in this field. Please refer to this section if you want a deeper theoreical understanding.

I will keep adding content to this website until necessary. It might contain errors, or links might get broken, or new packages and papers are not listed. So please give feedback by opening an [Issue](https://github.com/asjadnaqvi/DiD/issues). The aim of this repository is to collectively build notes and a code base that we can all use.

Some thoughts below from my own perspective (these are also subject to change over time):


## What happened? The DiD renaissance

Several DiD innovations came out simultaneously in 2020 and 2021 with some staggered roll-outs in 2022. At the heart of this new DiD literature is the premise that the classic Two-way Fixed Effects (TWFE) model can give [wrong estimates](https://asjadnaqvi.github.io/DiD/docs/code/06_twfe/). This is especially true if the treatments are heterogeneous (differential treatment timings, different treatment sizes, different treatment statuses over time) which can result in "negative weights". As a result, the TWFE model dilutes the true treatment effect. 

Recent innovations like the [Bacon decomposition](https://asjadnaqvi.github.io/DiD/docs/code/06_bacon/) help us unpack the weights of the different combinations of different treated and untreated cohorts. The recent DiD methods papers introduce various DiD estimation techniques that "correct" for TWFE biases. Within these packages are different ways of handling parallel trends, negative weights, covariates, controls, etc. This is done using different methods ranging from bootstrapping, inverse probability weights, matching, influence functions, imputations, etc. The packages are constantly being improved. It is also not very clear which methods/packages are the best option for certain problems. Hopefully, more will be written on comparing the utility of each estimation technique by those who know this stuff better. At the time of writing this (September 2022), new papers and package are still being released. But hopefully, we will also start seeing more applications and replications that can help us understand the nuances. In 2022, several review papers were released that summarize the state of the field. These papers are a good starting point to familiarize oneself with the methods and are marked in the [literature](https://asjadnaqvi.github.io/DiD/docs/resources#papers) section.


## Misc info

This is a working document. If you want to report errors or contribute, just [open an issue](https://github.com/AsjadNaqvi/DiD/issues), or [start a discussion](https://github.com/asjadnaqvi/DiD/discussions), or e-mail me at asjadnaqvi@gmail.com. 

I update the `Stata` code every 3 months or so. [@grantmcdermott](https://github.com/grantmcdermott) is now maintaining the `R` code base. If anyone can help contribute code for `Python` or `Julia`, then please reach out!


The of the code repository is to help the readers navigate the code structure, and syntax usage for different packages. If you use this repository and find it helpful, acknowledgements and/or citations will be highly appreciated. 




