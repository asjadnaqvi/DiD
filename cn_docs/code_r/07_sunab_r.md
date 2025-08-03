---
layout: default
title: sunab
parent: R代码
nav_order: 6
mathjax: true
image: "../../../assets/images/DiD.png"
---

# fixest::sunab (Sun和Abraham 2020)
{: .no_toc }

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 简介

在（许多）其他功能中，
[Laurent Bergé的](https://sites.google.com/site/laurentrberge/)
[**fixest**](https://lrberge.github.io/fixest/)包支持Sun和Abraham 2020年论文[在具有异质处理效应的事件研究中估计动态处理效应](https://www.sciencedirect.com/science/article/pii/S030440762030378X) (以下简称SA20)中描述的估计程序。关键函数是
[**`sunab()`**](https://lrberge.github.io/fixest/reference/sunab.html)，
它提供了与`eventstudyinteract` Stata命令等效的功能。然而，它需要较少的手动调整（例如，前导和滞后自动检测），并且它与**fixest**的其他设施（例如绘图和制表）原生集成。正如对**fixest**的期望，估计也非常快——你可能会发现它是我们在这里涵盖的所有专业DiD库中最快的选项。这些特点使它成为交错DiD设置中有吸引力且自然的选择。

## 安装和选项

该包可以从CRAN安装。

```r
install.packages("fixest") # 安装（只需要运行一次或在更新时运行）
library("fixest")          # 将包加载到内存中（每个新会话都需要）
```

实现SA20聚合程序的关键函数是`sunab()`。
这作为`fixest::feols()`函数的内部参数，
许多用户将熟悉用于估计（高维固定效应）
回归。因此，最基本的形式是：

```r
feols(y ~ sunab(cohort, period) | id + period, data, ...)
```

其中

| 变量 | 描述 |
| ----- | ----- |
| y | 结果变量 |
| cohort | 描述共同处理时期的变量（例如，`year_treated`） |
| period | 时间变量 |
| id | 面板id |
| ... | 额外参数 |

所有常规的`feols()`功能和估计后选项都可以
叠加在上述基本案例之上。例如，用户可以添加协变量，
更改默认队列参考（这里：从未处理）等。甚至可以
将`sunab()`集成到**fixest**的非线性模型估计量中
如`feglm()`和`fepois()`，尽管我不认为这些有良好
的理论支持。参见帮助文件
([`?sunab`](https://lrberge.github.io/fixest/reference/sunab.html))
获取更详细的信息，以及
[介绍性小插图](https://lrberge.github.io/fixest/articles/fixest_walkthrough.html#staggered-difference-in-differences-sun-and-abraham-2020)。

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
library(fixest)
```

让我们尝试基本的`sunab()`函数（作为`feols()`内部集成）。注意
我们没有任何协变量，尽管这些可以很容易地添加到
模型公式中。同样，我们将按个体ID显式聚类标准误，尽管这是多余的，因为**fixest**自动
按固定效应槽中的第一个变量聚类。接下来的代码块
应该几乎瞬间完成。

```r
sa20 = feols(
    y ~ sunab(first_treat, rel_time) | id + time, 
    data = dat, vcov = ~id
    )
sa20
#> OLS估计，因变量：y
#> 观测值：1,800 
#> 固定效应：id：30，time：60
#> 标准误：按id聚类 
#>                估计量 标准误差   t值 Pr(>|t|)    
#> rel_time::-43 -0.992231   0.833177 -1.190901 0.243349    
#> rel_time::-42 -0.682967   0.725131 -0.941854 0.354048    
#> rel_time::-41  0.055083   0.902155  0.061057 0.951733    
#> rel_time::-40 -0.350181   0.549271 -0.637537 0.528777    
#> rel_time::-39 -0.433172   1.175733 -0.368427 0.715231    
#> rel_time::-38 -1.877821   0.949817 -1.977035 0.057614 .  
#> rel_time::-37 -1.994746   0.898465 -2.220171 0.034382 *  
#> rel_time::-36 -0.734659   0.840305 -0.874276 0.389151    
#> ... 剩余83个系数（用summary()显示或使用参数n）
#> ---
#> 显著性代码：  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> RMSE：0.913773     调整R2：0.999927
#>                  组内R2：0.999686
```

作为**fixest**模型，所有常规方法都适用于我们的`sa20`对象。
例如，我们可以使用
[`etable()`](https://lrberge.github.io/fixest/reference/etable.html)将回归表导出到LaTeX，或使用
[`iplot()`](https://lrberge.github.io/fixest/reference/coefplot.html#iplot-1)可视化事件研究。
这里我将做后者，使用一点正则表达式来删除有2位数字的前导和滞后（即，删除所有距离处理超过9期的内容）。
这不是严格必要的，但会让我们更关注处理日期周围的时期。

```r
# iplot(sa20)
# 普通选项（上面）可以，但我们可以稍微调整一下...
sa20 |>
  iplot(
    main     = "fixest::sunab",
    xlab     = "时间到处理",
    drop     = "[[:digit:]]{2}",    # 将前导和滞后时期限制为-9:9
    ref.line = 1
    )
```

<img src="../../../assets/images/sunab_R.png" height="300">

附注：对于那些更喜欢上述（基础R）图的ggplot2版本的人，可以查看[**ggfixest**](https://grantmcdermott.com/ggfixest/)。