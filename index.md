---
layout: default
title: Difference-in-Difference (DiD)
nav_order: 1
description: "Welcome to the DiD revolution."
image: "/assets/images/DiD.jpg"
permalink: /
---


# Welcome!

*Last updated: November 2024*

This repository tracks the developments in **Difference-in-Difference (DiD)** software packages. Brief explanations on how to use these packages is also provided. The [Resources](https://asjadnaqvi.github.io/DiD/docs/resources) section includes information on relevant readings, books, videos, and workshops in this field. 

The website gets updated roughly every three to four months. Therefore, it might not contain the most recent information. If you come across bugs, package updates, broken links, or even new packages, then please do a Pull Request or start an [Issue](https://github.com/asjadnaqvi/DiD/issues). The aim of this repository is to collectively build notes and a code base that we can all use.


## What happened? The DiD renaissance
The DiD renaissance was nothing short of a revolution in 2020. Several papers and packages coming out in 2020 and 2021. This combined with COVID-19 lockdowns, where everyone working from home, and with #EconTwitter at its peak online activity, boosted the popularity of the new DiD methods tremendously. Even in 2023 and 2024 we continue to see improvements to existing packages and new releases. More applications are also coming out.

At the heart of this new DiD literature is the premise that the classic Two-way Fixed Effects (TWFE) model can give [wrong estimates](https://asjadnaqvi.github.io/DiD/docs/code/06_01_twfe/) under certain conditions. This is highly likely if treatments are heterogeneous (differential treatment timings, different treatment sizes, different treatment statuses over time) that can contaminate the treatment effects. This can result from "bad" treatment combinations biased the average treatment estimation to the point of even reversing the sign. Innovations like the [Bacon decomposition](https://asjadnaqvi.github.io/DiD/docs/code/06_02_bacon/) help us unpack the relative weight of the various combinations of treated versus untreated cohorts. The new DiD methods automatically "correct" for the TWFE biases using various techniques such as bootstrapping, inverse probability weights, matching, influence functions, and imputations, to handle parallel trends, negative weights, covariates, and controls.

While these methods are definitely an improvement over classic TWFE methods, a careful and deeper dive is required in order to gain a solid understanding of which methods and/or packages works best for which problems. Currently, more is being written on comparing the different packages by those who know this stuff better.

Several review papers have come out that summarize the state-of-the-field really well. They are a good starting point to familiarize oneself with the methods and are marked in the [Resources](https://asjadnaqvi.github.io/DiD/docs/resources) section.


## Misc info

If you want to report errors, updates, and/or want to contribute, then please do a Pull Request (especially if you have written the package), [open an issue](https://github.com/AsjadNaqvi/DiD/issues) or worse case scenario, e-mail me. 

I maintain the [Stata code](https://asjadnaqvi.github.io/DiD/docs/code) while [@grantmcdermott](https://github.com/grantmcdermott) has been super amazing in maintaining the [R code](https://asjadnaqvi.github.io/DiD/docs/code_r). Please reach out if you can help contribute information for *Python*, *Julia*, or other languages.

If you use this repository and find it helpful, giving it a star, an acknowledgement, and/or citations will be highly appreciated.

