---
layout: default
title: 所有估计量
parent: Stata代码
nav_order: 20
mathjax: true
image: "../../../assets/images/DiD.png"
---

# 所有估计量
{: .no_toc }

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}


*(最后更新：2022年11月29日)*

---


# 估计量比较

这个例子遵循[五个估计量](https://github.com/borusyak/did_imputation/blob/main/five_estimators_example.png)代码，该代码利用`event_plot`命令。在这个例子中，我们将使用我们在上面各个部分中一直使用的相同代码结构。所以让我们开始吧。

请注意，除了在某些情况下，估计量并不是真正可互换的。请仔细阅读每个估计量的假设，然后再将它们绘制在一个图中。理解估计量之间差异的一个好起点是[Roth 2024](https://arxiv.org/abs/2401.12309)。


## 第0步：获取所有包

包会不时更新。不时检查更新也是好的！

```stata
// 支持包
ssc install schemepack, replace
ssc install avar, replace 
ssc install reghdfe, replace
ssc install event_plot, replace
ssc install palettes, replace
ssc install colrspace, replace

// 双重差分包
ssc install drdid, replace
ssc install csdid, replace
ssc install did_imputation, replace
ssc install eventstudyinteract, replace
ssc install did_multiplegt, replace
ssc install stackedev, replace
ssc install did2s, replace
```

`schemepack`包安装Stata图形方案。你可以`set scheme white_tableau`以获得一个干净的方案来完全复制下面显示的图形。`palettes`和`colrspace`包允许用户自定义颜色。


## 第1步：为所有双重差分包创建所有变量

请确保你使用[这里](https://asjadnaqvi.github.io/DiD/docs/code/06_03_data/)给出的脚本生成数据


## 第2步：运行包并存储结果


```stata
************
*** TWFE ***
************

reghdfe Y L_* F_*, absorb(id t) cluster(i)

estimates store twfe 

*************
*** csdid ***
*************

csdid Y, ivar(id) time(t) gvar(gvar) notyet

estat event, window(-10 10) estore(csdd) 

***********************
*** did_imputation  ***
***********************

did_imputation Y i t first_treat, horizons(0/10) pretrend(10) minn(0) 

estimates store didimp	

***********************
*** did_multiplegt  ***
***********************

did_multiplegt_dyn Y id t D, effects(10) placebo(10) cluster(id)

matrix didmgt_b = e(estimates) 
matrix didmgt_v = e(variances)

*****************************
***  eventstudyinteract   ***
*****************************

eventstudyinteract Y L_* F_*, vce(cluster id) absorb(id t) cohort(first_treat) control_cohort(never_treat)	

matrix evtstint_b = e(b_iw) 
matrix evtstint_v = e(V_iw)

***************
*** did2s   ***
***************

did2s Y, first_stage(id t) second_stage(F_* L_*) treatment(D) cluster(id)

matrix did2s_b = e(b)
matrix did2s_v = e(V)

******************
*** stackedev  ***
******************

	
stackedev Y F_* L_* ref, cohort(first_treat) time(t) never_treat(never_treat) unit_fe(id) clust_unit(id)

matrix stackedev_b = e(b)
matrix stackedev_v = e(V)	
```


## 第3步：将所有估计量放在一起

在这里，我们还利用colorpalettes包（`ssc install palettes, replace`和`ssc install colrspace, replace`）来控制颜色。

```stata
colorpalette tableau, nograph	

event_plot    twfe	csdd    didimp  dcdh_b#dcdh_v   sa_b#sa_v   stackedev_b#stackedev_v did2s_b#did2s_v , 	///
	stub_lag( L_#   Tp#     tau#    Effect_#        L_#         L_#                     L_# 			) 		///
	stub_lead(F_# 	Tm#     pre#    Placebo_#       F_#         F_#                     F_# 			)		///
		together perturb(-0.30(0.10)0.30) trimlead(20) trimlag(20) noautolegend 								///
		plottype(scatter) ciplottype(rspike)  															///
			lag_opt1(msymbol(+)   msize(1.2) mlwidth(0.3) color(black)) 	lag_ci_opt1(color(black)     lw(0.15)) 	///
			lag_opt2(msymbol(lgx) msize(1.2) mlwidth(0.3) color("`r(p1)'")) lag_ci_opt2(color("`r(p1)'") lw(0.15)) 	///
			lag_opt3(msymbol(Dh)  msize(1.2) mlwidth(0.3) color("`r(p2)'")) lag_ci_opt3(color("`r(p2)'") lw(0.15)) 	///
			lag_opt4(msymbol(Th)  msize(1.2) mlwidth(0.3) color("`r(p3)'")) lag_ci_opt4(color("`r(p3)'") lw(0.15)) 	///
			lag_opt5(msymbol(Sh)  msize(1.2) mlwidth(0.3) color("`r(p4)'")) lag_ci_opt5(color("`r(p4)'") lw(0.15)) 	///
			lag_opt6(msymbol(Oh)  msize(1.2) mlwidth(0.3) color("`r(p5)'")) lag_ci_opt6(color("`r(p5)'") lw(0.15)) 	///	
			lag_opt7(msymbol(V)   msize(1.2) mlwidth(0.3) color("`r(p6)'")) lag_ci_opt7(color("`r(p6)'") lw(0.15)) 	///	
				graph_opt(																				///
								title("双重差分事件研究图") 								///
								xtitle("") 										///
								ytitle("平均效应") xlabel(-20(2)20)	///
								legend(order(1 "TWFE" 3 "csdid (CS 2020)" 5 "did_imputation (BJS 2021)" 7 "did_multiplegt (CD 2020)"  9 "eventstudyinteract (SA 2020)" 11 "stackedev (CDLZ 2019)" 13 "did2s (G 2021)") pos(6) rows(3) region(style(none)))	///
								xline(-0.5, lc(gs8) lp(dash)) ///
								yline(   0, lc(gs8) lp(dash)) ///
							 )
```

这给了我们这个数字：

<img src="../../../assets/images/allestimators2.png" width="100%">