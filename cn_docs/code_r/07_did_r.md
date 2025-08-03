---
layout: default
title: did
parent: R代码
nav_order: 2
mathjax: true
image: "../../../assets/images/DiD.png"
---

# did (Callaway和Sant'Anna 2021)
{: .no_toc }

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 简介

[**did**](https://bcallaway11.github.io/did/) R包由
[Brantly Callaway](https://bcallaway11.github.io/)和
[Pedro Sant'Anna](https://pedrohcgs.github.io/)开发，以配合他们2021年的论文
[具有多个时间段的双重差分](https://www.sciencedirect.com/science/article/pii/S0304407620303948) (以下简称CS21)。

CS21提供了一个极其灵活的框架来估计DiD风格的回归，并且可以在其他包/例程困难的情况下产生有效的估计量。CS21的核心——因此也是**did**包的核心——是一套完全饱和的组（即队列）×时间交互。其思想是相对于有效的对照组（默认情况下，从未处理的单位）估计这些交互中的每一个，从而产生个体平均处理效应（ATT）。然后我们可以沿着不同的维度聚合这些个体ATT，以产生感兴趣的"汇总"结果。例如，我们可以动态地聚合（即，跨越时间段）以获得等效的事件研究系数。

如果这个通用性和灵活性听起来需要很多工作，那是因为确实如此。**did**在底层做了很多工作，我甚至还没有谈到它如何计算个体ATT。（_TL;DR_ 默认情况下，它使用"双重稳健"方法，因为CS21证明了通过回归或逆概率加权估计的等价条件。）但该包非常用户友好且出奇地灵活。为了使估计快速，投入了大量工作，通过C++优化
[显著的速度提升](https://twitter.com/pedrohcgs/status/1470526912447528960)。

## 安装和选项

该包可以从CRAN安装。

```r
install.packages("did") # 安装（只需要运行一次或在更新时运行）
library("did")          # 将包加载到内存中（每个新会话都需要）
```

**did**的典型工作流程涉及两个连续的函数调用。

1. **[`agg_gt()`](https://bcallaway11.github.io/did/reference/att_gt.html)**: 估计个体（组×时间）ATT。
2. **[`aggte()`](https://bcallaway11.github.io/did/reference/aggte.html)**: 沿着感兴趣的维度聚合ATT。例如，我们可以使用`aggte(..., type = "dynamic")`沿着相对时间维度聚合ATT，从而获得事件研究。

让我们快速看一下这两个函数的主要参数：

```r
att_gt(yname, tname, idname, gname, xformla, data, ...)
```

其中

| 变量 | 描述 |
| ----- | ----- |
| yname | 结果变量（字符型） |
| tname | 时间变量（字符型） |
| idname | 面板id变量（字符型） |
| gname | 定义共同第一期的组或队列变量（字符型） |
| xformla | 额外控制变量（公式，可选） |
| data | 数据集 |
| ... | 额外参数（估计方法、DiD对照组等） |

和

```r
aggte(model, type, ...)
```

其中

| 变量 | 描述 |
| ----- | ----- |
| model | 来自上述`att_gt()`调用的模型对象 |
| type | 要计算的聚合类型，例如"group"或"dynamic"（字符型） |
| ... | 额外参数（聚类、自助法等） |

再次，**did**极其灵活，并允许大量超出此处呈现的额外参数，从处理预期到聚类或自助标准误的一切。参见相关的帮助文件
([`?att_gt`](https://bcallaway11.github.io/did/reference/att_gt.html)和
[`?aggte`](https://bcallaway11.github.io/did/reference/aggte.html))
获取更多信息。最后，**did**网站包含一个
[一系列极其有用的用户指南](https://bcallaway11.github.io/did/articles/index.html)
（即小插图），不仅演示如何使用包，而且还有
帮助用户更普遍地思考DiD估计问题。

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
library(did)
```

好的，让我们运行我们的两个互补函数中的第一个，`att_gt()`，来获得（组×时间）ATT。下面的函数调用应该相当
不言自明，只需要一两秒钟运行。但我想要强调我们指定`control_group = "notyettreated"`（而不是"nevertreated"默认）的事实。这只是我们模拟数据集的一个产物，它没有为底层CS21估计程序提供足够的从未处理单位。如果你省略了这个参数（如我最初所做的），那么函数将返回一个有用的提示来解决问题。

```r
cs21 = att_gt(
    yname         = "y",
    tname         = "time",
    idname        = "id",
    gname         = "first_treat",
  # xformla       = NULL,            # 此数据集中没有额外控制
    control_group = "notyettreated", # 对于"nevertreated"默认组太少
    clustervars   = "id", 
    data          = dat
    )
cs21

#' 调用：
#' att_gt(yname = "y", tname = "time", idname = "id", gname = "first_treat", 
#'     data = dat, control_group = "notyettreated", clustervars = "id")
#' 
#' 参考：Callaway, Brantly和Pedro H.C. Sant'Anna。"具有多个时间段的双重差分"。计量经济学杂志，第225卷，第2期，第200-230页，2021年。
#' 
#' 组-时间平均处理效应：
#'  组 时间 ATT(g,t) 标准误 [95% 同时置信带]  
#'     12    2   0.3932     0.6474       -1.4985      2.2849  
#'     12    3  -0.9038     0.7147       -2.9919      1.1844  
#'     12    4   0.6265     0.5265       -0.9118      2.1648  
#'     12    5   0.7449     0.5280       -0.7979      2.2876  
#'     12    6  -1.4944     0.5348       -3.0571      0.0683
#> <截断>
```

有了我们的ATT，我们现在可以进入第二个函数`aggte()`，来计算感兴趣的聚合量。在这种情况下，我将指定"dynamic"聚合来获得事件研究（即，ATT在相对时间到处理期间的聚合）。我还将研究范围限制在处理日期周围的10个前导和10个滞后。

```r
cs21_es = aggte(cs21, type = "dynamic", min_e = -10, max_e = 10)
cs21_es
#' 调用：
#' aggte(MP = cs21, type = "dynamic", min_e = -10, max_e = 10)
#' 
#' 参考：Callaway, Brantly和Pedro H.C. Sant'Anna。"具有多个时间段的双重差分"。计量经济学杂志，第225卷，第2期，第200-230页，2021年。
#' 
#' 
#' 基于事件研究/动态聚合的ATT总体摘要：  
#'     ATT    标准误     [ 95%  置信区间]  
#'  30.183        2.2437    25.7853     34.5807 *
#' 
#' 
#' 动态效应：
#'  事件时间 估计量 标准误 [95% 同时置信带]  
#'         -10   0.1890     0.3215       -0.6810      1.0589  
#'          -9  -0.4952     0.5115       -1.8792      0.8889  
#'          -8  -0.0711     0.4076       -1.1740      1.0318  
#'          -7   0.4991     0.2262       -0.1129      1.1112  
#'          -6  -0.9216     0.3219       -1.7925     -0.0508 *
#'          -5   0.5933     0.4658       -0.6671      1.8538  
#'          -4  -0.2031     0.2951       -1.0017      0.5954  
#'          -3   0.3527     0.4170       -0.7757      1.4810  
#'          -2  -0.1218     0.4732       -1.4022      1.1586  
#'          -1   0.2054     0.4968       -1.1388      1.5496  
#'           0  -0.4572     0.4672       -1.7212      0.8069  
#'           1   6.0124     0.5745        4.4578      7.5670 *
#'           2  12.1593     0.9938        9.4702     14.8483 *
#'           3  17.7974     1.2370       14.4504     21.1444 *
#'           4  23.8820     1.7787       19.0693     28.6946 *
#'           5  29.8164     2.2644       23.6894     35.9434 *
#'           6  36.4129     2.5552       29.4991     43.3267 *
#'           7  42.9080     2.8311       35.2477     50.5683 *
#'           8  48.4004     3.8096       38.0925     58.7083 *
#'           9  54.3290     3.6510       44.4502     64.2079 *
#'          10  60.7524     4.2551       49.2392     72.2657 *
#' ---
#' 显著性代码：`*' 置信带不包含0
#' 
#' 对照组： 尚未处理， 预期期：  0
#' 估计方法：  双重稳健
```

**did**的最后锦上添花是它提供了一套完整的估计后整理和可视化方法。（看看**DIDmultiplegt**）。这里有一个使用后者的快速示例，使用
[`ggdid()`](https://bcallaway11.github.io/did/reference/ggdid.MP.html)函数
来产生事件研究图。

```r
ggdid(cs21_es, title = "(cs)did")
```

<img src="../../../assets/images/csdid_R.png" height="300">