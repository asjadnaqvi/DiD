---
layout: default
title: Difference-in-Difference (DiD)
nav_order: 1
description: "Welcome to the DiD revolution."
image: "/assets/images/DiD.jpg"
permalink: /
---


# Welcome!

*Last updated: July 2026*

This repository tracks the developments in **Difference-in-Differences (DiD)** software packages. Brief explanations on how to use these packages are also provided. The [Resources](https://asjadnaqvi.github.io/DiD/docs/resources) section includes information on relevant readings, books, videos, and workshops in this field.

The website is updated roughly every 6-12 months. Therefore, it might not contain the most recent information. If you come across bugs, package updates, broken links, or even new packages, please submit a pull request or start an [Issue](https://github.com/asjadnaqvi/DiD/issues). The aim of this repository is to collectively build notes and a code base that we can all use.


## What happened? The DiD renaissance
The DiD renaissance was nothing short of a revolution in 2020. Several papers and packages came out in 2020 and 2021. This, combined with COVID-19 lockdowns (when everyone was working from home) and #EconTwitter at peak online activity, boosted the popularity of the new DiD methods tremendously. At the time of updating this page, we continue to see new papers, new package releases, and continuous improvements to older packages. More and more applications are also coming out.

At the heart of this new DiD literature is the premise that the classic Two-way Fixed Effects (TWFE) model can give [wrong estimates](https://asjadnaqvi.github.io/DiD/docs/code_stata/06_01_twfe/) under certain conditions. This is highly likely if treatments are heterogeneous (differential treatment timings, different treatment sizes, different treatment statuses over time), which can contaminate treatment effects. This can result from "bad" treatment combinations that bias average treatment effect estimates to the point of even reversing the sign. Innovations like the [Bacon decomposition](https://asjadnaqvi.github.io/DiD/docs/code_stata/06_02_bacon/) help us unpack the relative weight of the various combinations of treated versus untreated cohorts. The new DiD methods automatically "correct" for TWFE biases using various techniques such as bootstrapping, inverse probability weights, matching, influence functions, and imputations to handle parallel trends, negative weights, covariates, and controls.

The 2026 [JEL review](https://www.aeaweb.org/articles?id=10.1257/jel.20251650) by Baker, Callaway, Cunningham, Goodman-Bacon, and Sant'Anna is a compact summary of what matters in modern DiD: the target parameter, 2x2 building blocks, weights, covariates, staggered adoption, and the forward-engineering approach. Those ideas are a good guide for deciding which package or estimator to use.

While these methods are definitely an improvement over classic TWFE methods, a careful and deeper dive is required to gain a solid understanding of which methods and/or packages work best for which problems. Currently, more is being written on comparing the different packages by those who know this stuff better.

Several review papers summarize the state of the field really well. They are a good starting point to familiarize oneself with the methods and are marked in the [Resources](https://asjadnaqvi.github.io/DiD/docs/resources) section.


## Misc info

If you want to report errors, updates, and/or contribute, please submit a pull request (especially if you have written the package), [open an issue](https://github.com/AsjadNaqvi/DiD/issues), or, in the worst-case scenario, email me.

If you use this repository and find it helpful, giving it a star, an acknowledgement, and/or citations or references would be highly appreciated.
