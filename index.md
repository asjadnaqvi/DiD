---
layout: default
title: Difference-in-Difference (DiD)
nav_order: 1
description: "Welcome to the DiD revolution."
image: "/assets/images/DiD.jpg"
permalink: /
---


# Welcome!

*Last checked: 08 Sep 2026*

This repository tracks developments in **Difference-in-Differences (DiD)** software packages and provides brief implementation examples. The [Resources](https://asjadnaqvi.github.io/DiD/docs/resources) section includes relevant readings, books, videos, and workshops.

Package metadata is reviewed when registry or repository information changes. Literature and implementation notes are reviewed at least twice a year. The site may still miss very recent releases. If you find bugs, package updates, broken links, or new packages, please submit a pull request or start an [Issue](https://github.com/asjadnaqvi/DiD/issues).


## What happened? The DiD renaissance
The DiD renaissance was nothing short of a revolution in 2020. Several papers and packages came out in 2020 and 2021. This, combined with COVID-19 lockdowns (when everyone was working from home) and #EconTwitter at peak online activity, boosted the popularity of the new DiD methods tremendously. At the time of updating this page, we continue to see new papers, new package releases, and continuous improvements to older packages. More and more applications are also coming out.

At the heart of the modern DiD literature is the result that conventional Two-way Fixed Effects (TWFE) models can combine multiple 2x2 comparisons in ways that are difficult to interpret when treatment effects vary over cohorts or exposure lengths. In some staggered-adoption designs, the resulting weights can even be negative. The [Bacon decomposition](https://asjadnaqvi.github.io/DiD/docs/code_stata/06_02_bacon/) helps unpack those comparisons. Alternative DiD methods target different group-time, event-time, or aggregate parameters under different assumptions; they do not automatically solve anticipation, non-parallel trends, interference, poor overlap, or treatment misclassification.

The 2026 [JEL review](https://www.aeaweb.org/articles?id=10.1257/jel.20251650) by Baker, Callaway, Cunningham, Goodman-Bacon, and Sant'Anna is a compact summary of what matters in modern DiD: the target parameter, 2x2 building blocks, weights, covariates, staggered adoption, and the forward-engineering approach. Those ideas are a good guide for deciding which package or estimator to use.

While these methods are definitely an improvement over classic TWFE methods, a careful and deeper dive is required to gain a solid understanding of which methods and/or packages work best for which problems. Currently, more is being written on comparing the different packages by those who know this stuff better.

Several review papers summarize the state of the field really well. They are a good starting point to familiarize oneself with the methods and are marked in the [Resources](https://asjadnaqvi.github.io/DiD/docs/resources) section.

## Choosing a method

Regarding choosing a method: start with the design and target parameter, then choose the relevant implementation. The package tables are organized by language, but their estimands are not interchangeable. Also note that the same package implementation *might* give different estimates across different software packages.



## Misc info

If you want to report errors, updates, and/or contribute, please submit a pull request (especially if you have written the package), [open an issue](https://github.com/AsjadNaqvi/DiD/issues), or, in the worst-case scenario, email me.

If you use this repository and find it helpful, giving it a star, an acknowledgement, and/or citations or references would be highly appreciated.
