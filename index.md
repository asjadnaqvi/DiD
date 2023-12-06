---
layout: default
title: Difference-in-Difference (DiD)
nav_order: 1
description: "Welcome to the DiD revolution."
image: "/assets/images/DiD.jpg"
permalink: /
---


# Welcome!

*Last updated: December 2023*

This repository tracks the recent developments and innovations in the **Difference-in-Difference (DiD)** literature. It serves two purposes. First, it is an organized collection of various bookmarks from Twitter, GitHub, YouTube etc. Second, it aims to present the different packages from an end-user's perspective. This part has to do with how to apply these methods in day-to-day applied research. On the theory side, several really useful resources are listed in the [Resources](https://asjadnaqvi.github.io/DiD/docs/resources) including workshops and notes by some of the key authors leading the development in this field. Please refer to this section if you want a deeper theoreical understanding.

The contents of this page will get intermitent updates as necessary. It might contain errors, or links might get broken, or packages get updated, or new papers are not listed. Therefore, please give feedback by opening a Pull Request (PR) or opening an [Issue](https://github.com/asjadnaqvi/DiD/issues). The aim of this repository is to collectively build notes and a code base that we can all use.

Some thoughts below from my own perspective (these are also subject to evolve over time):


## What happened? The DiD renaissance

The DiD renaissance was nothing short of a revolutionary movement. Several DiD papers and packages coming out simultaneously in 2020 and 2021 was a game changer for a relatively stable field of causal inference. Additionally, with COVID-19 lockdowns where everyone working from home, and #EconTwitter at its peak levels of activities on line helped boost these new methods.  Even in 2023, several really solid packages have been released and various existing packages have been optimizated.

At the heart of this new DiD literature is the premise that the classic Two-way Fixed Effects (TWFE) model can give [wrong estimates](https://asjadnaqvi.github.io/DiD/docs/code/06_01_twfe/). This is very likely especially if treatments are heterogeneous (differential treatment timings, different treatment sizes, different treatment statuses over time) that can contaminate the treatment effects. This can result from "bad" treatment combinations biased the average treatment estimation to the point of even reversing the sign.

Innovations like the [Bacon decomposition](https://asjadnaqvi.github.io/DiD/docs/code/06_02_bacon/) help us unpack the relative weight of the various combinations of treated versus untreated cohorts. The new DiD methods "correct" for these TWFE biases by combining various estimation techniques, such as bootstrapping, inverse probability weights, matching, influence functions, and imputations, to handle parallel trends, negative weights, covariates, and controls. The packages are constantly being improved, and currently have multiple implementations across and within different languages.

While these methods are definite improvement over classic TWFE methods, what is not very clear, and requires a deeper dive, is which method and/or package works best for which problems. Hopefully, more will be written on comparing the utility of each estimation technique by those who know this stuff better. At the time of updating this, new papers and packages are still being released but at a considerably less frequency. We are now seeing more applications and replications that can help us understand the nuances across these various DiD innovations. 

Several review papers have come out that summarize the state-of-the-field really well. They are a good starting point to familiarize oneself with the methods and are marked in the [literature](https://asjadnaqvi.github.io/DiD/docs/reading/04_resources) section.


## Misc info

The aim of this repository is to help readers navigate the packages, code, and syntax usage. Therefore, this repository is periodically updated. If you want to report errors, updates, and/or want to contribute, then please [open an issue](https://github.com/AsjadNaqvi/DiD/issues), or [start a discussion](https://github.com/asjadnaqvi/DiD/discussions), or e-mail me at asjadnaqvi@gmail.com. 

I update the [Stata code](https://asjadnaqvi.github.io/DiD/docs/code) every few months or so. Similary, [@grantmcdermott](https://github.com/grantmcdermott) maintains the [R code](https://asjadnaqvi.github.io/DiD/docs/code_r). Please reach out if you can help contribute code for *Python* or *Julia*.

If you use this repository and find it helpful, acknowledgements and/or citations will be highly appreciated. 

