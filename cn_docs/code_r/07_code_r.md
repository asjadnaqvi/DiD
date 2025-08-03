---
layout: default
title: R代码
nav_order: 7
permalink: /docs/code_r
has_children: true
mathjax: true
image: "../../../assets/images/DiD.png"
---

# R代码

本节旨在涵盖各种R包中的R估计命令。
点击页面底部的导航链接查看特定包的详细
实现代码。

开始之前，你可以参考以下符号表：

| 符号 | 描述 | 
| $$ id $$ | 面板id |
| $$ time $$ | 时间变量 |
| $$ y $$ | 结果变量 |
| $$ treat $$ | 如果观测被处理则为1 |
| $$ \epsilon $$ | 误差项 |

## 数据生成

本节中的所有R代码都将使用相同的虚假数据集，我们在下面生成这个数据集。该数据集将密切模仿[Stata示例]({{ "/docs/code" | relative_url }})中使用的等效数据集。但由于不同的随机种子，它将*不完全*相同（**重要！**）。这意味着你不应该期望在比较本网站上的R和Stata示例时得到相同的结果。（当然，除非你明确使用相同的数据集。）

```r
set.seed(123456L)

# 60个时间段，30个个体，5个处理波次
tmax = 60; imax = 30; nlvls = 5

dat = 
  expand.grid(time = 1:tmax, id = 1:imax) |>
  within({
    
    cohort      = NA
    effect      = NA
    first_treat = NA
    
    for (chrt in 1:imax) {
      cohort = ifelse(id==chrt, sample.int(nlvls, 1), cohort)
    }
    
    for (lvls in 1:nlvls) {
      effect      = ifelse(cohort==lvls, sample(2:10, 1), effect)
      first_treat = ifelse(cohort==lvls, sample(1:(tmax+20), 1), first_treat)
    }
    
    first_treat = ifelse(first_treat>tmax, Inf, first_treat)
    treat       = time>=first_treat
    rel_time    = time - first_treat
    y           = id + time + ifelse(treat, effect*rel_time, 0) + rnorm(imax*tmax)
    
    rm(chrt, lvls, cohort, effect)
  })

head(dat)
#>   time id        y rel_time treat first_treat
#> 1    1  1 2.158289      -11 FALSE          12
#> 2    2  1 2.498052      -10 FALSE          12
#> 3    3  1 3.034077       -9 FALSE          12
#> 4    4  1 4.886266       -8 FALSE          12
#> 5    5  1 7.085950       -7 FALSE          12
#> 6    6  1 5.788352       -6 FALSE          12
```

从视觉上看，这个数据集更容易理解，所以这里以图形形式展示。我将使用**lattice**包而不是**ggplot2**，因为前者与基础R安装捆绑在一起。

```r
library(lattice)
# 一些（可选的！）绘图主题设置
trellis.par.set(list(
  axis.line      = list(col = NA),
  reference.line = list(col = "gray85", lty = 3),
  superpose.line = list(col = hcl.colors(imax, "SunsetDark")),
  par.xlab.text  = list(fontfamily = "ArialNarrow"),
  par.ylab.text  = list(fontfamily = "ArialNarrow"),
  axis.text      = list(fontfamily = "ArialNarrow")
  ))

xyplot(
  y ~ time,  
  groups = id,
  type = c("l", "g"),
  ylab = "Y", xlab = "时间变量",
  data = dat
  )
```

<img src="../../../assets/images/test_data_R.png" height="300">

有了我们的数据集，请点击下面的**目录**中的各个页面。每个页面都使用我们的测试数据集通过实现示例更详细地探索一个特定的R包。我计划随着时间的推移添加更多包，但请随时通过PR贡献你自己的内容。

{: .fs-6 .fw-300 }