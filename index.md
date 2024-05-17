---
layout: default
title: Difference-in-Difference (DiD)
nav_order: 1
description: "Welcome to the DiD revolution."
image: "/assets/images/DiD.jpg"
permalink: /
---


# Welcome!

*Last updated: May 2024*

This repository tracks the developments in **Difference-in-Difference (DiD)** software packages. Brief explanations of how to use these packages is also provided. The [Resources](https://asjadnaqvi.github.io/DiD/docs/resources) section includes information on relevant readings, books, videos, and workshops in this field. The website gets updated roughly every three to four months. Therefore, it might not contain the most recent information. Therefore, if you come across new updates, broken links, or new packages, then please send a message, start an [Issue](https://github.com/asjadnaqvi/DiD/issues), or simply do a pull request. The aim of this repository is to collectively build notes and a code base that we can all use.



## What happened? The DiD renaissance
The DiD renaissance was nothing short of a revolutionary movement in 2020. Several DiD papers and packages coming out back-to-back in 2020 and 2021. This combined with COVID-19 lockdowns where everyone working from home, and #EconTwitter at its peak levels of activity helped boost these methods. Even in 2023 and 2024, existing and new packages continue to be released and optimized.

At the heart of this new DiD literature is the premise that the classic Two-way Fixed Effects (TWFE) model can give [wrong estimates](https://asjadnaqvi.github.io/DiD/docs/code/06_01_twfe/). This is very likely especially if treatments are heterogeneous (differential treatment timings, different treatment sizes, different treatment statuses over time) that can contaminate the treatment effects. This can result from "bad" treatment combinations biased the average treatment estimation to the point of even reversing the sign. Innovations like the [Bacon decomposition](https://asjadnaqvi.github.io/DiD/docs/code/06_02_bacon/) help us unpack the relative weight of the various combinations of treated versus untreated cohorts. The new DiD methods "correct" for these TWFE biases by combining various estimation techniques, such as bootstrapping, inverse probability weights, matching, influence functions, and imputations, to handle parallel trends, negative weights, covariates, and controls.

While these methods are definite improvement over classic TWFE methods, what requires a deeper dive, is a solid understanding of which methods and/or packages works best for specific problems. Hopefully, more will be written on comparing the utility of each estimation technique by those who know this stuff better. Currently in 2024, while packages are still rolling out, we are also observing more applications and discussions that can help us understand the nuances across various DiD innovations. 

Several review papers have come out that summarize the state-of-the-field really well. They are a good starting point to familiarize oneself with the methods and are marked in the [literature](https://asjadnaqvi.github.io/DiD/docs/reading/04_resources) section.


## Misc info

If you want to report errors, updates, and/or want to contribute, then please [open an issue](https://github.com/AsjadNaqvi/DiD/issues) or e-mail me at asjadnaqvi@gmail.com. 

I maintain the [Stata code](https://asjadnaqvi.github.io/DiD/docs/code) part while [@grantmcdermott](https://github.com/grantmcdermott) has been super amazing in maintaining the [R code](https://asjadnaqvi.github.io/DiD/docs/code_r). Please reach out if you can help contribute code for *Python* or *Julia*.

If you use this repository and find it helpful, acknowledgements and/or citations will be highly appreciated.

