---
layout: default
title: did_multiplegt
parent: R代码
nav_order: 4
mathjax: true
image: "../../../assets/images/DiD.png"
---

# did_multiplegt (Chaisemartin和D'Haultfœuille 2020, 2021)
{: .no_toc }

## 注意
{: .no_toc}

为了估计事件研究/动态效应，我们强烈建议使用<ins>快得多</ins>的[did_multiplegt_dyn](https://asjadnaqvi.github.io/DiD/docs/code_r/07_did_multiplegt_dyn_r/)命令。

除此之外，did_multiplegt_dyn提供了比did_multiplegt更多的选项，其中包括：
+ **normalized**: 估计标准化动态效应 (de Chaisemartin & D'Haultfoeuille, 2024);
+ **predict_het**: 内置处理效应异质性分析;
+ **design** 和 **date_first_switch**: 估计后选项，用于分析处理的设计和时机;
+ **by** 和 **by_path**: 在组级变量或处理路径内估计动态效应;
+ **trends_lin**: 内置组特定线性趋势。

最后，在最新版本中，did_multiplegt_dyn还包含了几个用户请求的功能：
+ **only_never_switchers**: 将de Chaisemartin & D'Haultfoeuille (2024)的估计量限制为仅比较转换者和从不转换者;
+ did_multiplegt_dyn的输出可以作为具有**did_multiplegt_dyn**类的列表进行分配 (例如： `did <- did_multiplegt_dyn(df, Y, G, T, D)`);
+ 自定义类允许内置定制的**print()**和**summary()**方法;
+ 通过简单地浏览列表，可以从分配的对象中完整检索显示输出;
+ 与**ggplot2**集成：分配的输出将始终包含事件研究图的**ggplot**对象。

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 简介

**DIDmultiplegt**包实现了[de Chaisemartin和D'Haultfœuille (2020)](https://www.aeaweb.org/articles?id=10.1257%2Faer.20181169) (以下简称dCDH20)提出的估计程序。dCDH20的一个关键优点是它是目前可用的最灵活的DiD估计量之一。它允许处理转换（单位可以进入和退出处理状态）以及时变、异质的处理效应。

缺点是，该命令是可用DiD估计量中最慢的之一。这部分与计算标准误需要自助复制有关，添加额外选项会在后台乘以估计计算的数量。另一方面，R实现确实支持并行化——至少在Linux和Mac上——并且似乎比Stata等效版本快得多。但仍然没有显示或进度条，因此很难跟踪估计时间（即使对于小数据集也可能需要几分钟）。此外，该包不提供通常在R中用于询问模型对象的标准方法，如`summary`和`print`。因此，它确实缺乏可用性。我将在下面的例子中展示一些克服这个问题的方法。

## 安装和选项

该包可以从CRAN安装

```r
install.packages("DIDmultiplegt") # 安装（只需要运行一次或在更新时运行）
library("DIDmultiplegt") # 将包加载到内存中（每个新会话都需要）
```

该包的主要工作函数是`did_multiplegt()`，其最简单的形式如下：

```r
did_multiplegt(df, Y, G, T, D, ...)
```

其中

| 变量 | 描述 |
| ----- | ----- |
| df | 数据集 |
| Y | 结果变量 |
| G | 组变量 |
| T | 时间变量 |
| D | 处理虚拟变量（如果处理则为1） |
| ... | 额外参数 |

再次，`did_multiplegt()`的一个关键优点是它允许非常灵活的估计策略和要求。有各种额外的函数参数旨在支持或调用这些灵活性。我们将在下面介绍一些最重要的参数，但你可以查看帮助文件 (`?did_multiplegt`) 获取更详细的信息。

## 数据集

为了演示该包的实际应用，我们将使用我们[之前创建]({{ "/docs/code_r#data-generation" | relative_url }})的虚假数据集。这是数据外观的提醒。

```r
head(dat)
#>   time id        y rel_time treat first_treat
#> 1    1  1 2.158289      -11 FALSE          12
#> 2    2  1 2.498052      -10 FALSE          12
#> 3    3  1 3.034077       -9 FALSE          12
#> 4    4  1 4.886266       -8 FALSE          12
#> 5    5  1 7.085950       -7 FALSE          12
#> 6    6  1 5.788352       -6 FALSE          12
```

或者以图形形式显示。

<img src="../../../assets/images/test_data_R.png" height="300">

## 测试包

如果还没有加载包，请记得加载。

```r
library(DIDmultiplegt)
```

让我们尝试基本的`did_multiplegt()`命令：

```r
did_multiplegt(df = dat, Y = "y", G = "id", T = "time", D = "treat")
#> $effect
#>  treatment 
#> -0.4571712 
#> 
#> $N_effect
#> [1] 83
#> 
#> $N_switchers_effect
#> [1] 26
```

这完成得相当快（几秒钟），但信息不是特别丰富。它只是瞬时处理效应的点估计（即转换者转换的时间段）。因此，让我们通过调用额外的函数参数来尝试一个更现实的用例...

首先，注意我们可以通过调用`breps`参数来获得自助标准误。我们还将继续估计一个实际的事件研究，有10个预处理前导和10个处理后滞后（在dCDH20框架中有些混淆地分别称为`placebo`和`dynamic`时期）。这次，我还将保存结果模型对象，尽管注意它将花费_显著_更长的估计时间。（在我的笔记本电脑上超过6分钟，尽管调用并行化使用所有12个可用线程。）

```r
mod_dCDH20 = did_multiplegt(
  dat, 'y', 'id', 'time', 'treat', # 原始回归参数
  dynamic   = 10,                  # 后处理期数
  placebo   = 10,                  # 预处理期数
  brep      = 20,                  # 自助次数（SE所需）
  cluster   = 'id',                # 聚类SE的变量
  parallel  = TRUE                 # 并行运行自助
  )
```
运行上述命令将自动产生以下事件研究图。

<img src="../../../assets/images/did_multiplegt_R.png" height="300">

虽然上面的图相当不错——并且可以导出/保存供将来使用——但事实是，我们的返回`mod_dCDH20`对象不是特别用户友好。它只是一个列表，缺乏明确的模型类。因此，它不提供我们在R中期望的模型对象的标准便利方法，例如`summary`或`print`。

```r
head(mod_dCDH20)
#> $placebo_10
#> [1] 0.06805525
#> 
#> $se_placebo_10
#> [1] 0.3151775
#> 
#> $N_placebo_10
#> [1] 83
#> 
#> $placebo_9
#> [1] -0.4496167
#> 
#> $se_placebo_9
#> [1] 0.5380869
#> 
#> $N_placebo_9
#> [1] 83
```

你可以关注[这个
问题](https://github.com/shuo-zhang-ucsb/did_multiplegt/issues/2)以查看何时
一些标准方法将被添加到包中。同时，这里有一个
快速函数，用于将`did_multiplegt`对象转换为"整洁"的数据框，_类似于_[**broom**](https://broom.tidymodels.org/)约定。

```r
# install.packages("broom")
library(broom)

# 为"multiplegt"对象创建整洁器
tidy.did_multiplegt = function(x, level = 0.95) {
  ests = x[grepl("^placebo_|^effect|^dynamic_", names(x))]
  ret = data.frame(
    term      = names(ests),
    estimate  = as.numeric(ests),
    std.error = as.numeric(x[grepl("^se_placebo|^se_effect|^se_dynamic", names(x))]),
    N         = as.numeric(x[grepl("^N_placebo|^N_effect|^N_dynamic", names(x))])
    ) |>
    # 对于置信区间，我们假设标准正态分布
    within({
      conf.low  = estimate - std.error*(qnorm(1-(1-level)/2))
      conf.high = estimate + std.error*(qnorm(1-(1-level)/2))
      })
  return(ret)
}
```

现在我们可以使用我们的小函数以更友好的数据框格式查看估计结果。反过来，这个数据框使得使用基础R `plot()`函数或[**ggplot2**](https://ggplot2.tidyverse.org/)构造你自己的（定制的）事件研究图变得容易。

```r
tidy_dCDH20 = tidy(mod_dCDH20)
tidy_dCDH20
#>          term    estimate std.error  N  conf.high    conf.low
#> 1  placebo_10  0.06805525 0.3151775 83  0.6857918 -0.54968129
#> 2   placebo_9 -0.44961673 0.5380869 83  0.6050142 -1.50424768
#> 3   placebo_8 -0.08261323 0.3500397 83  0.6034519 -0.76867836
#> 4   placebo_7  0.51945343 0.2586573 83  1.0264123  0.01249453
#> 5   placebo_6 -0.92753693 0.2747529 83 -0.3890312 -1.46604263
#> 6   placebo_5  0.62703000 0.4021329 83  1.4151960 -0.16113600
#> 7   placebo_4 -0.20311433 0.2146316 83  0.2175558 -0.62378446
#> 8   placebo_3  0.35268709 0.3082441 83  0.9568345 -0.25146028
#> 9   placebo_2 -0.12184467 0.5099217 83  0.8775835 -1.12127286
#> 10  placebo_1  0.20542543 0.5867543 83  1.3554428 -0.94459195
#> 11     effect -0.45717121 0.4331831 83  0.3918520 -1.30619441
#> 12  dynamic_1  6.01240948 0.3870975 83  6.7711067  5.25371223
#> 13  dynamic_2 12.15926002 0.6807289 83 13.4934641 10.82505594
#> 14  dynamic_3 17.79738274 1.0158897 83 19.7884900 15.80627550
#> 15  dynamic_4 23.88198369 1.3854778 77 26.5974703 21.16649703
#> 16  dynamic_5 29.81641003 1.6276905 77 33.0066249 26.62619521
#> 17  dynamic_6 36.41289963 1.9836774 77 40.3008360 32.52496330
#> 18  dynamic_7 42.90801358 2.3987287 77 47.6094354 38.20659181
#> 19  dynamic_8 48.40043286 2.7062129 67 53.7045128 43.09635296
#> 20  dynamic_9 54.32903314 3.0309359 67 60.2695583 48.38850799
#> 21 dynamic_10 60.75243562 3.3986148 67 67.4135983 54.09127299

# install.packages("ggplot2")
library(ggplot2)
theme_set(theme_minimal(base_family = "ArialNarrow")) # 可选

tidy_dCDH20 |>
  within({
    term = gsub("^placebo_", "-", term)
    term = gsub("^effect", "0", term)
    term = gsub("^dynamic_", "", term)
    term = as.integer(term)
    }) |>
  ggplot(aes(x = term, y = estimate, ymin = conf.low, ymax = conf.high)) +
  geom_pointrange() +
  labs(
    x = "时间到处理", y = "效应大小", title = "事件研究图", 
    subtitle = "由Chaisemartin和D'Haultfœuille (2020)和ggplot2提供"
    )
```

<img src="../../../assets/images/did_multiplegt_R_ggplot2.png" height="300">

_待办：检查与`TwoWayFEWeights`的集成/互补性。_