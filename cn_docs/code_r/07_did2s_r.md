---
layout: default
title: did2s
parent: R代码
nav_order: 3
mathjax: true
image: "../../../assets/images/DiD.png"
---

# did2s (Gardner 2021)
{: .no_toc }

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 简介

[**did2s**](https://kylebutts.github.io/did2s) R包由[Kyle
Butts](https://kylebutts.com/)开发，实现了Gardner
2021年论文[两阶段双重差分](https://jrgcmu.github.io/2sdd_current.pdf)中提出的方法。
详细描述可在**did2s**包的[网站](https://kylebutts.github.io/did2s/articles/Two-Stage-Difference-in-Differences.html)上找到。

**did2s**背后的核心思想非常简单，巧妙地实现了[Frisch-Waugh-Lovell (FWL)](https://towardsdatascience.com/the-fwl-theorem-or-how-to-make-all-regressions-intuitive-59f801eb3299)定理，这应该对很多读者来说都很熟悉。简而言之，我们可以通过运行两个回归（因此得名）来避免交错DiD设置中的病态问题：

1. 仅使用未处理/尚未处理的观测值，对我们的结果变量运行固定效应回归（包括控制变量）。对结果进行残差化（即从实际结果中减去预测结果）。
2. 使用所有观测值，将残差化后的结果回归到处理虚拟变量（或用于事件研究的时间到处理虚拟变量）上，以获得无偏的处理效应。

这个两步程序的优点是估计速度非常快。在底层，**did2s**调用了[**fixest**](https://lrberge.github.io/fixest/)，因此后者的所有相关方法都可用（制表、绘图等）。更重要的是，它共享了一些语法快捷方式/约定，我们应该在指定模型时使用。我们将在下面看到一些例子。值得注意的是，**did2s**包还提供了便利函数来[运行和可视化一系列DiD估计量](https://kylebutts.github.io/did2s/articles/event_study.html)（即，不仅仅是Gardner 2021提出的方法）。这使得它成为应用计量经济学家R工具箱中非常有用的包。不过，我们将这些功能留到"所有估计量"部分。_还需要添加这个部分。_

## 安装和选项

该包可以从CRAN安装。

```r
install.packages("did2s") # 安装（只需要运行一次或在更新时运行）
library("did2s")          # 将包加载到内存中（每个新会话都需要）
```

核心估计函数是`did2s()`，它接受以下参数：

```r
did2s(data, yname, treatment, first_stage, second_stage, ...)
```

其中

| 变量 | 描述 |
| ----- | ----- |
| data | 数据集 |
| yname | 结果变量（字符型） |
| first_stage | 第一阶段回归公式（控制变量和固定效应） |
| second_stage | 第二阶段回归公式（处理指标） |
| treatment | 处理虚拟变量（字符型） |
| cluster_var | 如何聚类标准误（字符型） |
| ... | 额外参数（自助法等） |

如上所述，**did2s**在底层调用**fixest**，因此期望后者的语法约定和快捷方式。最明显的例子是在`first_stage`公式中使用`|`固定效应槽，以及在`second_stage`公式中使用`i()`。我们将在下面用例子说明这一点。但你可以查看帮助文件([`?did2s`](https://kylebutts.github.io/did2s/reference/did2s.html))获取详细信息和额外例子。

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
library(did2s)
```

让我们在我们的虚假数据集上尝试基本的`did2s()`命令。我们将从估计一个简单的二元处理效应开始，而不是一个完整的事件研究。下面有一些关于我们的第一阶段和第二阶段回归参数的事情我想引起你的注意。`first_stage`公式使用`|`来划分常规协变量（尽管这个数据集没有）和固定效应槽。`second_stage`公式调用`i()`操作符来创建我们"treat"变量的指标（因子）。这两个语法特征对**fixest**用户来说应该很熟悉，但仍然值得强调。

```r
did2s(
  data         = dat,
  yname        = "y", 
  first_stage  = ~ 0 | id + time, # 0是因为这个数据集没有控制变量
  second_stage = ~ i(treat),      # 二元处理虚拟变量（不是事件研究） 
  treatment    = "treat",
  cluster_var  = "id",
  )

#' 运行两阶段双重差分
#' • 第一阶段公式 `~ 0 | id + time`
#' • 第二阶段公式 `~ i(treat)`
#' • 表示处理开启的指标变量是 `treat`
#' • 标准误将按 `id` 聚类
#' OLS估计，因变量：y
#' 观测值：1,800 
#' 标准误：自定义 
#'                   估计量   标准误差  t值  Pr(>|t|)    
#' treat::FALSE -5.010000e-15 1.070000e-15 -4.69674 2.844e-06 ***
#' treat::TRUE   1.399854e+02 1.216437e+01 11.50782 < 2.2e-16 ***
#' ---
#' 显著性代码：  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#' RMSE: 80.9   调整R2: 0.425782
```

好的，现在让我们通过估计一个完整的事件研究来尝试一个更现实的用例。与前面的回归相比，我们唯一需要改变的是`second_stage`公式。这次，我们将使用相对时间变量（也称为时间到处理）而不是二元处理指标。注意我通过`i(rel_time, ref = c(-1, Inf))`指定了两个参考期。第一个(`-1`)将所有效应设定为相对于处理前一期。第二个(`Inf`)为这个数据集建立"从未处理"的对照组；这个参考值在你自己的数据中可能不同。我还将继续保存结果模型对象，因为我计划在下面绘制相应的事件研究图。

```r
es_mod = did2s(
  data         = dat,
  yname        = "y",
  first_stage  = ~ 0 | id + time,
  second_stage = ~ i(rel_time, ref = -c(1, Inf)), # 使用相对时间变量进行事件研究
  treatment    = "treat",
  cluster_var  = "id"
  )

#' 运行两阶段双重差分
#' • 第一阶段公式 `~ 0 | id + time`
#' • 第二阶段公式 `~ i(rel_time, ref = -c(1, Inf))`
#' • 表示处理开启的指标变量是 `treat`
#' • 标准误将按 `id` 聚类

es_mod
#' OLS估计，因变量：y
#' 观测值：1,800 
#' 标准误：自定义 
#' rel_time::-43  -0.049719   0.272847   -0.182224 0.8554282    
#' rel_time::-42  -0.150764   0.196905   -0.765670 0.4439783    
#' rel_time::-41   0.411294   0.419485    0.980472 0.3269918    
#' rel_time::-40  -0.060809   0.285788   -0.212777 0.8315264    
#' rel_time::-39  -0.104809   0.445865   -0.235069 0.8141833    
#' <截断>
#' ---
#' 显著性代码：  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#' RMSE: 25.7   调整R2: 0.939163
```

正如我一直强调的，**did2s**在底层使用**fixest**，后者的所有方法都适用。所以我们使用[`fixest::iplot()`](https://lrberge.github.io/fixest/reference/coefplot.html#iplot-1)来绘制我们的事件研究模型。

```r
# fixest::iplot(es_mod) 
# 上面的普通选项可以，但我们可以稍微调整一下...
es_mod |>
  fixest::iplot(
    main     = "did2s",
    xlab     = "时间到处理",
    drop     = "[[:digit:]]{2}",    # 删除任何大于|9|的前导/滞后
    ref.line = 1
  )
```

<img src="../../../assets/images/did2s_R.png" height="300">

附注：对于那些更喜欢上述（基础R）图的ggplot2版本的人，可以查看[**ggfixest**](https://grantmcdermott.com/ggfixest/)。