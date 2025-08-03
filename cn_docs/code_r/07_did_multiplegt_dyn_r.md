---
layout: default
title: did_multiplegt_dyn
parent: R代码
nav_order: 7
mathjax: true
image: "../../../assets/images/DiD.png"
---

# did_multiplegt_dyn (Chaisemartin和D'Haultfœuille 2024)
{: .no_toc }

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 简介

**DIDmultiplegtDYN**包实现了[de Chaisemartin和D'Haultfœuille (2024)](https://doi.org/10.1162/rest_a_01414) (以下简称dCDH24)提出的估计量。与其前身**DIDmultiplegt**一样，dCDH24的关键优势在于命令中允许的广泛处理设计范围。它可以与二元且吸收的(<ins>交错</ins>)处理一起使用，但也可以与<ins>非二元处理</ins>（离散或连续）一起使用，这种处理可以多次增加或减少，即使滞后处理影响结果，并且即使当前和滞后处理在空间上和/或时间上具有异质效应。

与**DIDmultiplegt**不同，dCDH24<ins>不依赖自助</ins>复制来计算标准误。默认情况下，该命令计算解析标准误，这大大减少了运行时间。与其前身的另一个不同之处在于与R语言的改进集成。该命令现在提供了`summary`和`print`的自定义方法。由于输出是具有`did_multiplegt_dyn`类的嵌套列表，该命令允许进一步的方法分派。最后，命令输出始终包括事件研究图作为`ggplot`对象，这意味着用户可以使用`ggplot2`库提供的全部工具来自定义事件研究图的显示。

相对于**DIDmultiplegt**，dCDH24配备了大量新的估计和估计后选项：
+ **normalized**: 估计*每单位处理*的动态效应;
+ **predict_het**: 内置处理效应异质性分析;
+ **design** 和 **date_first_switch**: 估计后选项，用于分析处理的设计和时机;
+ **by** 和 **by_path**: 在组级变量或处理路径内估计动态效应;
+ **trends_lin**: 内置组特定线性趋势;
+ **only_never_switchers**: 将dCDH24估计量限制为仅比较转换者和从不转换者。

## 安装和选项

该包可以从CRAN安装

```r
install.packages("DIDmultiplegtDYN") # 安装（只需要运行一次或在更新时运行）
library("DIDmultiplegtDYN") # 将包加载到内存中（每个新会话都需要）
```

该包的主要工作函数是`did_multiplegt_dyn()`，其最简单的形式如下：

```r
did_multiplegt_dyn(df, outcome, group, time, treatment, ...)
```

其中

| 变量 | 描述 |
| ----- | ----- |
| df | 数据集 |
| outcome | 结果变量 |
| group | 组变量 |
| time | 时间变量 |
| treatment | 处理变量（任何虚拟变量、离散或连续数值变量） |
| ... | 额外参数 |

再次，`did_multiplegt_dyn()`的一个关键优点是它允许非常灵活的估计策略和要求。有各种额外的函数参数旨在支持或调用这些灵活性。我们在上面已经介绍了一些最重要的参数，但你可以查看帮助文件 (`?did_multiplegt_dyn`) 获取更详细的信息。

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
library(DIDmultiplegtDYN)
```

让我们尝试基本的`did_multiplegt_dyn()`命令：

```r
did_multiplegt_dyn(df = dat, outcome = "y", group = "id", time = "time", treatment = "treat")

#' ----------------------------------------------------------------------
#'        处理效应估计：事件研究效应
#' ----------------------------------------------------------------------
#'  估计量        SE     LB CI     UB CI         N 转换者
#'  -0.45717   0.44252  -1.32450   0.41015        83        26

#' ----------------------------------------------------------------------
#'     每单位处理的平均累积（总）效应
#' ----------------------------------------------------------------------
#'  估计量        SE     LB CI     UB CI         N 转换者
#'  -0.45717   0.44252  -1.32450   0.41015        83        26
#' 累积处理效应所跨越的平均时间段数：1.0000


#' 该包的开发由欧盟资助。
#' ERC REALLYCREDIBLE - GA N. 101043899
```

一次性运行`did_multiplegt_dyn`计算处理转换后第一个时期的动态效应。现在让我们尝试具有更多动态效应、安慰剂和组级聚类的命令。

```r
mod_dCDH24 = did_multiplegt_dyn(
  dat, 'y', 'id', 'time', 'treat', # 原始回归参数
  effects   = 10,                  # 后处理期数
  placebo   = 10,                  # 预处理期数
  cluster   = 'id'                 # 聚类SE的变量
  )

#' ----------------------------------------------------------------------
#'        处理效应估计：事件研究效应
#' ----------------------------------------------------------------------
#'              估计量 SE      LB CI    UB CI    N  转换者
#' Effect_1     -0.45717 0.44252 -1.32450 0.41015  83 26       
#' Effect_2     6.01241  0.41452 5.19997  6.82485  83 26       
#' Effect_3     12.15926 0.37512 11.42404 12.89448 83 26       
#' Effect_4     17.79738 0.38663 17.03960 18.55516 83 26       
#' Effect_5     23.88198 0.31469 23.26520 24.49877 77 26       
#' Effect_6     29.81641 0.42263 28.98808 30.64474 77 26
#' Effect_7     36.41290 0.47205 35.48770 37.33810 77 26
#' Effect_8     42.90801 0.28881 42.34196 43.47407 77 26
#' Effect_9     48.40043 0.50253 47.41549 49.38537 67 26
#' Effect_10    54.32903 0.40159 53.54193 55.11614 67 26

#' ----------------------------------------------------------------------
#'     每单位处理的平均累积（总）效应
#' ----------------------------------------------------------------------
#'  估计量        SE     LB CI     UB CI         N 转换者
#'  27.12607   0.32014  26.49860  27.75353       642       260
#' 累积处理效应所跨越的平均时间段数：5.5000

#' ----------------------------------------------------------------------
#'      测试平行趋势和无预期假设
#' ----------------------------------------------------------------------
#'              估计量 SE      LB CI    UB CI   N  转换者
#' Placebo_1    -0.20543 0.53571 -1.25541 0.84456 83 26
#' Placebo_2    -0.08358 0.36033 -0.78982 0.62266 83 26
#' Placebo_3    -0.43627 0.38175 -1.18449 0.31195 83 26
#' Placebo_4    -0.23315 0.43870 -1.09300 0.62669 83 26
#' Placebo_5    -0.88144 0.50670 -1.87455 0.11167 77 26
#' Placebo_6    0.07470  0.36160 -0.63401 0.78342 77 26
#' Placebo_7    -0.48019 0.42165 -1.30661 0.34624 77 26
#' Placebo_8    -0.35821 0.44594 -1.23225 0.51582 77 26
#' Placebo_9    0.06761  0.56032 -1.03060 1.16582 67 26
#' Placebo_10   0.06228  0.44232 -0.80465 0.92920 67 26

#' 安慰剂联合零假设检验：p值 = 0.1132

#' 该包的开发由欧盟资助。
#' ERC REALLYCREDIBLE - GA N. 101043899
```
注意，第一个效应的标准误相对于前一个例子没有改变。这是由于程序计算的标准误已经默认在组级聚类。输出显示动态效应、安慰剂和平均总效应（每单位处理）的点估计、标准误、置信区间和样本大小。默认情况下，`print`和`summary`显示还包括安慰剂联合显著性检验的p值和第一个转换后落入动态效应估计的时间段平均数。

让我们检查分配的对象。

```r
print(class(mod_dCDH24))
# [1] "did_multiplegt_dyn"
print(names(mod_dCDH24))
# [1] "args"    "results" "coef"    "plot"
```

在这个基本设置中，我们可以检索：
1. 命令调用的参数(_args_)
2. 标量/矩阵形式的命令结果(_results_)
3. 与`honestdid`更兼容的格式的命令结果(_coef_)
4. `ggplot`事件研究图(_plot_)

除非指定了`graph_off = TRUE`参数，否则图将自动由命令显示。无论如何，图对象将存储在输出中，并且可以在之后检索。
让我们看看图。

```r
print(mod_dCDH24$plot)
```

<img src="../../../assets/images/did_multiplegt_dyn_R.png" height="300">

由于上图是一个`ggplot`对象，可以使用`ggplot2`库的所有工具来添加自定义层。例如，
我们可以仅用几行代码重现(cs)`did`图的风格：

```r
# 一个图表示例来说服怀疑的did用户
library(ggplot2) # 加载ggplot2库
plt <- mod_dCDH24$plot # 将图分配给新对象（避免每次都写完整路径）

plt$layers[[1]] <- NULL # 删除线
plt$layers[[1]]$aes_params$colour <- c(rep("#00BFC4", 10), rep("#F7736B", 10)) # 更改CI颜色
plt$layers[[2]]$aes_params$colour <- c(rep("#00BFC4", 11), rep("#F7736B", 10)) # 更改散点颜色
plt <- plt + geom_hline(yintercept = 0, linetype = "dashed", color = "black") +  # 添加参考线
    theme(plot.title = element_text(hjust = 0.5), panel.grid.major = element_blank(), # 清理背景
        panel.grid.minor = element_blank(), panel.background = element_blank(), 
        axis.line = element_line(colour = "black")
    ) + scale_x_continuous(breaks=seq(-10,10,1)) +  # 调整x轴刻度
    ylab(" ") + ggtitle("DIDmultiplegtDYN") # 添加标题
print(plt) 
```

结果如下：

<img src="../../../assets/images/did_multiplegt_dyn_R_did.png" height="300">