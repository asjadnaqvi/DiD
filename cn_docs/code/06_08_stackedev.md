---
layout: default
title: stackedev
parent: Stata代码
nav_order: 8
mathjax: true
image: "../../../assets/images/DiD.png"
---

# stackedev
{: .no_toc }

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 说明

- 基于：Cengiz, Dube, Lindner, Zipperer 2019。[最低工资对低工资工作的影响](https://academic.oup.com/qje/article/134/3/1405/5484905)
- 程序版本（如有）：-
- 最后检查：2024年11月



## 安装和选项

从SSC安装命令：

```stata
ssc install stackedev, replace
```

查看帮助文件：

```stata
help stackedev
```


## 测试命令

定义参考年份：

```stata
ren F_1 ref  //基准年
	
```

让我们运行基本的`stackedev`命令：

```stata
stackedev Y F_* L_* ref, cohort(first_treat) time(t) never_treat(no_treat) unit_fe(id) clust_unit(id)
```


这将显示以下输出：

```stata
**** Building Stack 24 ****
**** Building Stack 34 ****
**** Building Stack 38 ****
**** Building Stack 56 ****
**** Appending Stacks ****
**** Estimating Model with reghdfe ****
(MWFE estimator converged in 2 iterations)
warning: missing F statistic; dropped variables due to collinearity or too few clusters
note: ref omitted because of collinearity

HDFE Linear regression                            Number of obs   =      3,060
Absorbing 2 HDFE groups                           F(  91,     49) =          .
Statistics robust to heteroskedasticity           Prob > F        =          .
                                                  R-squared       =     0.9974
                                                  Adj R-squared   =     0.9970
                                                  Within R-sq.    =     0.9896
Number of clusters (unit_stack) =         50      Root MSE        =     4.1332

                            (Std. err. adjusted for 50 clusters in unit_stack)
------------------------------------------------------------------------------
             |               Robust
           Y | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
         F_2 |   .2173356    .429718     0.51   0.615    -.6462151    1.080886
         F_3 |   .1386198   .4137917     0.33   0.739    -.6929257    .9701654
         F_4 |  -.0771335   .4251788    -0.18   0.857    -.9315624    .7772953
         F_5 |  -.3127445   .3628929    -0.86   0.393    -1.042005    .4165161
         F_6 |  -.4361147   .4095256    -1.06   0.292    -1.259087    .3868578
         F_7 |  -.3144571    .526613    -0.60   0.553    -1.372726    .7438113
         F_8 |  -.1044745   .4800377    -0.22   0.829    -1.069146    .8601974
         F_9 |  -.1156501   .4238786    -0.27   0.786    -.9674661    .7361659
        F_10 |   .1485313   .4001261     0.37   0.712    -.6555522    .9526148
        F_11 |  -.2473913     .47278    -0.52   0.603    -1.197478    .7026957
        F_12 |  -.1452927   .4785819    -0.30   0.763    -1.107039    .8164536

                                 <输出截断>

        L_27 |   258.8725   1.506249   171.87   0.000     255.8456    261.8994
        L_28 |   270.2441   1.502177   179.90   0.000     267.2253    273.2628
        L_29 |   280.5032   1.489283   188.35   0.000     277.5104     283.496
        L_30 |   290.4652   1.590089   182.67   0.000     287.2698    293.6606
        L_31 |   298.6743   1.470175   203.16   0.000     295.7199    301.6288
        L_32 |   310.7671    1.43449   216.64   0.000     307.8844    313.6498
        L_33 |   319.9876   1.486439   215.27   0.000     317.0004    322.9747
        L_34 |    330.728   1.523338   217.11   0.000     327.6668    333.7893
        L_35 |   339.7674   1.475247   230.31   0.000     336.8028     342.732
        L_36 |   349.8512    1.53732   227.57   0.000     346.7618    352.9405
         ref |          0  (omitted)
       _cons |   47.28654   .5001833    94.54   0.000     46.28138    48.29169
------------------------------------------------------------------------------

Absorbed degrees of freedom:
-----------------------------------------------------+
 Absorbed FE | Categories  - Redundant  = Num. Coefs |
-------------+---------------------------------------|
    id#stack |        51          51           0    *|
     t#stack |       240           0         240     |
-----------------------------------------------------+
* = FE nested within cluster; treated as redundant for DoF computation
```


为了绘制估计结果，我们可以使用`event_plot`命令（`ssc install event_plot, replace`），我们将图形限制在10个前置期和滞后期：


```stata
	event_plot, default_look graph_opt(xtitle("事件发生后时期") ytitle("平均效应") xlabel(-10(1)10) ///
		标题("stackedev")) stub_lag(L_#) stub_lead(F_#) trimlag(10) trimlead(10) together 
```

我们得到：

<img src="../../../assets/images/stackedev_1.png" width="100%">