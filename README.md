


Last updated: 17 July 2021.




# Notes

This repository tracks the recent developments in the Difference-in-Difference (DiD) literature. Currently, it is just a dump of my bookmarks from different websites including Twitter, GitHub, YouTube etc. This will be sorted out over time as the literature converges to some consensus. But this might still take a while.

This is a working document, if you want to contribute, just message, or open an issue on GitHub. Let's make this the most epic DiD repository ever! 

TODO:
* Dump the info.
* Add key lit.
* Port to a proper website.


# Why do DiD?

TO BE ADDED


# Stata packages

| Name | Installation |  Package by | Literature | 
| --- | --- | --- |   --- | 
| `bacondecomp` | `ssc install bacondecomp, replace` <br><br>  | [Andrew Goodman-Bacon](http://goodman-bacon.com/) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/agoodmanbacon) <br><br> [Thomas Goldring](https://tgoldring.com/) <br><br> Austin Nichols [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/AustnNchols) |   Andrew Goodman-Bacon (2021). [Difference-in-differences with variation in treatment timing](https://www.sciencedirect.com/science/article/abs/pii/S0304407621001445). Journal of Econometrics | 
| `eventstudyinteract` |   | [Liyang Sun](http://economics.mit.edu/grad/lsun20) |   Liyang Sun, [Sarah Abraham](https://www.cornerstone.com/Staff/Sarah-Abraham#) (2020). [Estimating dynamic treatment effects in event studies with heterogeneous treatment effects](https://www.sciencedirect.com/science/article/abs/pii/S030440762030378X). Journal of Econometrics. | 
| `did_multiplegt` | `ssc install did_multiplegt, replace` |   [Clément de Chaisemartin](https://sites.google.com/site/clementdechaisemartin/) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/CdeChaisemartin) <br><br> [Xavier D'Haultfoeuille](https://faculty.crest.fr/xdhaultfoeuille/)  | Clément de Chaisemartin, Xavier D'Haultfoeuille (2020). [Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects](https://www.aeaweb.org/articles?id=10.1257/aer.20181169). American Economic Review. <br><br>  Clément de Chaisemartin, Xavier D'Haultfoeuille (2021). [Two-way fixed effects regressions with several treatments](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3751060).  <br><br>  Clément de Chaisemartin, Xavier D'Haultfoeuille (2021). [Difference-in-Differences Estimators of Inter-temporal Treatment Effects](https://arxiv.org/abs/2007.04267). |
| `did_imputation` | `ssc install did_imputation, replace` |  [Kirill Borusyak](https://sites.google.com/view/borusyak/home) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/borusyak) <br><br> [Xavier Jaravel](https://www.lse.ac.uk/economics/people/faculty/xavier-jaravel) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/XJaravel) <br><br> [Jann Spiess](https://www.gsb.stanford.edu/faculty-research/faculty/jann-spiess) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/jannspiess)  |   Kirill Borusyak, Xavier Jaravel, Jann Spiess (2021). [Revisiting Event Study Designs: Robust and Efficient Estimation](https://www.google.com/url?q=https%3A%2F%2Fwww.dropbox.com%2Fs%2Fy92mmyndlbkufo1%2FDraft_RobustAndEfficient.pdf%3Fraw%3D1&sa=D&sntz=1&usg=AFQjCNGGDRt4xPz3hCXhTWxchHJWh-1m_Q) | 
| `drdid`   |     | [Fernando Rios-Avila](https://friosavila.github.io/playingwithstata/index.html) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/friosavila) <br><br> [Asjad Naqvi](https://github.com/asjadnaqvi) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/asjadnaqvi) <br><br> [Pedro H.C. Sant'Anna](https://pedrohcgs.github.io/) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/pedrohcgs) |  Pedro H.C. Sant'Anna, [Jun Zhao](https://www.junbeanzhao.com/) (2020). [Doubly robust difference-in-differences estimators](https://www.sciencedirect.com/science/article/abs/pii/S0304407620301901), Journal of Econometrics.  |
| `csdid`   |      | [Fernando Rios-Avila](https://friosavila.github.io/playingwithstata/index.html)   |  [Brantly Callaway](https://bcallaway11.github.io/), Pedro H.C. Sant'Anna (2020). [Difference-in-Differences with multiple time periods](https://www.sciencedirect.com/science/article/abs/pii/S0304407620303948), Journal of Econometrics.  |
| `flexpaneldid` | `ssc install flexpaneldid, replace`   | Eva Dettmann <br><br> Alexander Giebler <br><br> Antje Weyh   | Eva Dettmann, Alexander Giebler, Antje Weyh (2020). [Flexpaneldid: A Stata Toolbox for Causal Analysis with Varying Treatment Time and Duration](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3692458). IWH Discussion Papers No. 3/2020 |
| `xtevent` |    | Simon Freyaldenhoven <br><br> Christian Hansen <br><br> Jorge Perez Perez <br><br>  Jesse M. Shapiro  | Simon Freyaldenhoven, Christian Hansen, Jesse M. Shapiro (2019). [Pre-event Trends in the Panel Event-Study Design](https://www.aeaweb.org/articles?id=10.1257/aer.20180609). American Economic Review. |
| `did2s` |  `ssc install did2s, replace`     |  [Kyle Butts](https://kylebutts.com/) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/kylefbutts) | [John Gardner](https://jrgcmu.github.io/) (2021). [Two-stage differences in differences](https://jrgcmu.github.io/2sdd_current.pdf). |
| `stackedev` |     | [Joshua Bleiberg](https://sites.google.com/view/joshbleiberg) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/JoshBleiberg) | Doruk Cengiz, Arindrajit Dube, Attila Lindner, Ben Zipperer (2019). [The effect of minimum wages on low-wage jobs](https://academic.oup.com/qje/article/134/3/1405/5484905). The Quarterly Journal of Economics.    |

*Note*: The length of the installation paths from GitHub repositories is messing up the table. Till this is sorted out, links here:

* `bacondecomp` alternative: ```net install ddtiming, from(https://tgoldring.com/code/)```
* `csdid`: ```net install csdid, from ("https://raw.githubusercontent.com/friosavila/csdid_drdid/main/code/") replace```
* `eventstudyinteract`  : ```net install eventstudyinteract, from("https://raw.githubusercontent.com/lsun20/EventStudyInteract/main/") replace```
* `xtevent`   : Manual install from here `https://simonfreyaldenhoven.github.io/software/`
* `stackedev`: ```net install stackedev, from("https://raw.githubusercontent.com/joshbleiberg/stackedev/main/")```



## How to use these packages?

COMING SOON



# DiD knowledge curation

Here are people who are actively involved in curating information on the latest DiD developments. This includes blogs, lecture series, tweets.


## Events and Videos

[Scott Cunningham](https://www.scunning.com/) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/causalinf): [CodeChella](https://causalinf.substack.com/p/codechella-announcement) the ultimate DiD event **Workshop 1: Friday July 16th, 2021** and **Workshop 2: Friday July 23, 2021** which will be live on [Twitch](https://www.twitch.tv/causalinf_did). Will post links if recordings are up somewhere.

[Chloe East](https://www.chloeneast.com/) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/ChloeEast2) organizes an online [DiD reading group](https://www.chloeneast.com/metrics-discussions.html).

[Taylor J. Wright](https://taylorjwright.github.io/) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/taylor_wright) organizes an online [DiD reading group](https://taylorjwright.github.io/did-reading-group/). The lecture recordings can also be viewed on [YouTube](https://www.youtube.com/channel/UCA7Idy0MfpP-uAjOebsFVuA/videos).


## Blogs
[Scott Cunningham](https://www.scunning.com/) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/causalinf): Scott's [Substack](https://causalinf.substack.com/) is the goto place for an easy-to-digest explanation of the latest metric-heavy DiD papers.

[Andrew C. Baker](https://andrewcbaker.netlify.app/) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/Andrew___Baker) has notes on [Difference-in-Differences Methodology](https://andrewcbaker.netlify.app/2019/09/25/difference-in-differences-methodology/) with supporting material on [GitHub](https://github.com/andrewchbaker).


## Books

[Scott Cunningham](https://www.scunning.com/) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/causalinf) (2020). [Causal Inference: The Mix Tape](https://mixtape.scunning.com/).

[Nick Huntington-Klein](https://nickchk.com/) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/nickchk) (2021). [The Effect](https://theeffectbook.net/).


## Notes

[Paul Goldsmith-Pinkham](https://paulgp.github.io/) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/paulgp) has a brilliant set of [lectures on empirical methods including DiD on GitHub](https://github.com/paulgp/applied-methods-phd). These are also supplemented by [YouTube videos](https://www.youtube.com/playlist?list=PLWWcL1M3lLlojLTSVf2gGYQ_9TlPyPbiJ). 

Jeffrey Wooldridge [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/jmwooldridge) has made several notes on DiD which are shared on his [Dropbox](https://www.dropbox.com/sh/zj91darudf2fica/AADj_jaf5ZuS1muobgsnxS6Za?dl=0) including Stata dofiles.

[Fernando Rios-Avila](https://friosavila.github.io/playingwithstata/index.html) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/friosavila) has a great explainer for the Callaway and Sant'Anna (2020) CS-DID logic on his [blog](https://friosavila.github.io/playingwithstata/main_csdid.html).

[Christine Cai](https://christinecai.github.io/) [<img width="12px" src="https://cdn.jsdelivr.net/npm/simple-icons@v5/icons/twitter.svg" />](https://twitter.com/Christine_Cai27) has a [working document](https://christinecai.github.io/PublicGoods/applied_micro_methods.pdf) which lists recent papers using different methods including DiDs.



## Tweets

Twitter threads that summarize the DiD literature. In order to render these properly, you need to view them on the [Jekyll website](https://asjadnaqvi.github.io/Diff-in-Diff-Notes/).


<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Navigating the DiD revolution from one applied researcher&#39;s perspective. <br><br>A LONG 🧵 on what I&#39;ve learned &amp; what I&#39;m still trying to figure out. Advice/insights welcome!<br><br>My <a href="https://twitter.com/michaelpollan?ref_src=twsrc%5Etfw">@michaelpollan</a> 🥦🍅🥕🫑 inspired TL;DR take:<br><br>&quot;Apply DiD in context, not every 2x2, mostly event studies&quot; <a href="https://t.co/CWmwyo1Btp">pic.twitter.com/CWmwyo1Btp</a></p>&mdash; Matthew A. Kraft (@MatthewAKraft) <a href="https://twitter.com/MatthewAKraft/status/1408147332164640769?ref_src=twsrc%5Etfw">June 24, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<br>

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">I&#39;ve been catching up on staggered diff-in-diff/two-way fixed effects recently. Simulating helped me see how bad TWFE performs with dynamic treatment effects (see those pre-trends). I also tried implementing Sun &amp; Abraham (2020)&#39;s interaction-weighted estimator in Stata <a href="https://t.co/FQBCQi0m7d">pic.twitter.com/FQBCQi0m7d</a></p>&mdash; Shan Huang (@ShanHuang_ec) <a href="https://twitter.com/ShanHuang_ec/status/1272928307441475585?ref_src=twsrc%5Etfw">June 16, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>


