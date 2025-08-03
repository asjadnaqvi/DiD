---
layout: default
title: did_multiplegt_old
parent: Stata代码
nav_order: 4
mathjax: true
image: "../../../assets/images/DiD.png"
---

# did_multiplegt_old 
{: .no_toc }


## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 注释
{: .no_toc}

这现在是一个遗留命令，应该被更快的[did_multiplegt_dyn](https://asjadnaqvi.github.io/DiD/docs/code/06_16_did_multiplegt_dyn/)取代。

- 基于：Chaisemartin和D'Haultfœuille 2020, 2021
- 程序版本（如果可用）：-
- 最后检查：2024年11月

## 安装

现在以下安装添加了各种`did_multiplegt`命令的集合：

```stata
ssc install did_multiplegt, replace
```

看看帮助文件：

```stata
help did_multiplegt_old
```

## 测试命令

请确保你使用[这里](https://asjadnaqvi.github.io/DiD/docs/code/06_03_data/)给出的脚本生成数据

让我们尝试基本的`did_multiplegt_old`命令：

```stata
did_multiplegt_old  Y id t D, robust_dynamic dynamic(10) placebo(10) breps(20) cluster(id) seed(0)
```

我们得到这个输出：

```stata
DID瞬时处理效应的估计量，如果使用dynamic选项则动态处理效应的估计量，如果使用placebo选项则平行趋势假设的安慰剂检验的估计量。估计量对异质效应稳健，如果使用robust_dynamic选项则对动态效应稳健。

             |  估计量         SE      LB CI      UB CI          N  切换者 
-------------+-----------------------------------------------------------------
    Effect_0 | -.0608394   .2767628  -.6032945   .4816157         78         23 
    Effect_1 |   8.49767   .3463686   7.818787   9.176552         78         23 
    Effect_2 |  17.64773   .4428714    16.7797   18.51576         78         23 
    Effect_3 |   25.9377   .5286248   24.90159    26.9738         78         23 
    Effect_4 |  34.62362   .7949031   33.06561   36.18163         75         23 
    Effect_5 |  42.85682   .9838843   40.92841   44.78524         64         19 
    Effect_6 |  51.93103   1.263135   49.45529   54.40677         64         19 
    Effect_7 |  60.13327   1.582643   57.03129   63.23525         64         19 
    Effect_8 |  68.82446    1.71335    65.4663   72.18263         64         19 
    Effect_9 |  77.30792   1.879409   73.62428   80.99156         64         19 
   Effect_10 |  85.78878   2.259642   81.35988   90.21768         55         19 
     Average |  40.79851   .9506058   38.93532    42.6617        762        229 
   Placebo_1 |  .1308918   .5697715  -.9858602   1.247644         78         23 
   Placebo_2 | -.0635463   .2533317  -.5600764   .4329839         78         23 
   Placebo_3 | -.1275425   .4031795  -.9177744   .6626893         78         23 
   Placebo_4 | -.3848304    .371244  -1.112469   .3428078         78         23 
   Placebo_5 | -.4583827   .2356492  -.9202551   .0034897         75         23 
   Placebo_6 | -.1875761   .3825025  -.9372809   .5621287         64         19 
   Placebo_7 |  .1194069    .335752  -.5386669   .7774807         64         19 
   Placebo_8 |  .0628537   .3785411  -.6790868   .8047943         64         19 
   Placebo_9 | -.1943704   .3368038   -.854506   .4657651         64         19 
  Placebo_10 | -.2936845   .4187626  -1.114459   .5270903         64         19 
```

默认情况下，该命令还会产生一个事件研究图，除非指定了**firstdiff_placebo**选项：在这种情况下，我们不建议将一阶差分安慰剂与长差分事件研究估计放在同一个事件研究图上。

<img src="../../../assets/images/did_multiplegt_stata.png" width="100%">

我们也可以使用`event_plot`（`ssc install event_plot, replace`）命令绘制结果如下：

```stata
event_plot e(estimates)#e(variances), default_look ///
	graph_opt(xtitle("自事件以来的时期") ytitle("平均因果效应") ///
	title("did_multiplegt") xlabel(-10(1)10)) stub_lag(Effect_#) stub_lead(Placebo_#) together
```

我们得到这个数字：

<img src="../../../assets/images/did_multiplegt_old.png" width="100%">