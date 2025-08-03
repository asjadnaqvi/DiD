---
layout: default
title: xtevent
parent: Stata代码
nav_order: 13
mathjax: true
image: "../../../assets/images/DiD.png"
---

# xtevent
{: .no_toc }

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 说明


- 基于：Freyaldenhoven, Hansen, Shapiro (2019)。[面板事件研究设计中的事件前趋势](https://www.aeaweb.org/articles?id=10.1257/aer.20180609)
- 程序版本（如有）：2024年7月11日 3.1.0版
- 最后检查：2024年11月



## 安装和选项

```stata
ssc install xtevent, replace
```

查看帮助文件：

```stata
help xtevent
```


## 测试命令


让我们尝试基本命令：

请确保使用[这里](https://asjadnaqvi.github.io/DiD/docs/code/06_03_data/)给出的脚本生成数据


```stata
gen gvar = first_treat
gen never_treat = first_treat==.  // 从未处理组

xtevent Y, pol(D) p(id) t(t) w(9) cohort(gvar) control_cohort(never_treat)
```

这显示以下输出：

```stata
Linear regression, absorbing indicators            Number of obs     =   1,363
Absorbed variable: id                              No. of categories =      30
                                                   F(124, 1209)      =  221.26
                                                   Prob > F          =  0.0000
                                                   R-squared         =  0.9699
                                                   Adj R-squared     =  0.9661
                                                   Root MSE          = 12.4519
------------------------------------------------------------------------------
           Y | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
   _k_eq_m10 |   18.15578   4.048421     4.48   0.000     10.21306    26.09849
    _k_eq_m9 |    1.69811   5.095058     0.33   0.739    -8.298027    11.69425
    _k_eq_m8 |   .7407838   4.890765     0.15   0.880    -8.854545    10.33611
    _k_eq_m7 |  -.8127252    4.72429    -0.17   0.863    -10.08144    8.455992
    _k_eq_m6 |  -1.877507   4.650289    -0.40   0.686    -11.00104    7.246026
    _k_eq_m5 |  -2.868383   4.172285    -0.69   0.492    -11.05411     5.31734
    _k_eq_m4 |   1.819757    5.10636     0.36   0.722    -8.198554    11.83807
    _k_eq_m3 |   1.218878    5.04484     0.24   0.809    -8.678735    11.11649
    _k_eq_m2 |   .7091566    4.99963     0.14   0.887    -9.099757    10.51807
    _k_eq_p0 |   14.29549   6.181089     2.31   0.021     2.168633    26.42234
    _k_eq_p1 |   20.56001   5.980967     3.44   0.001     8.825781    32.29424
    _k_eq_p2 |     26.893   5.888789     4.57   0.000     15.33962    38.44638
    _k_eq_p3 |   32.75074   5.674203     5.77   0.000     21.61837    43.88312
    _k_eq_p4 |    38.8536   5.818875     6.68   0.000     27.43738    50.26981
    _k_eq_p5 |   44.64604   5.927146     7.53   0.000      33.0174    56.27467
    _k_eq_p6 |   51.70155   5.917038     8.74   0.000     40.09275    63.31035
    _k_eq_p7 |   57.33333   6.301961     9.10   0.000     44.96933    69.69732
    _k_eq_p8 |   63.44384   6.605816     9.60   0.000     50.48371    76.40398
    _k_eq_p9 |   68.69211   6.911169     9.94   0.000      55.1329    82.25133
   _k_eq_p10 |   137.5108   5.500292    25.00   0.000     126.7196     148.302
------------------------------------------------------------------------------


```


使用`event_plot`命令可以生成如下图形：


```stata
matrix xt_b = e(b) 
matrix xt_v = e(V)

event_plot xt_b#xt_v, default_look graph_opt(xtitle("事件发生后时期") ytitle("平均效应")  ///
	标题("xtevent")) stub_lag(_k_eq_p#) stub_lead(_k_eq_m#) together
```

<img src="../../../assets/images/xtevent_1.png" width="100%">