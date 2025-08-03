---
layout: default
title: Bacon分解
parent: Stata代码
nav_order: 2
mathjax: true
image: "../../../assets/images/DiD.png"
---

# Bacon分解
{: .no_toc }

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

*本节已经更新并在很大程度上得到了[Daniel Sebastian Tello Trillo](https://sebastiantellotrillo.com/)的改进。*

*最后更新：2024年5月16日*

---

## 什么是Bacon分解？

如TWFE部分最后一个示例所讨论的，如果我们有不同的处理时机和不同的处理效应，那么什么前后期就不那么明显了。让我们再次说明这个例子：

```stata
clear
local units = 3
local start = 1
local end   = 10

local time = `end' - `start' + 1
local obsv = `units' * `time'
set obs `obsv'

egen id    = seq(), b(`time')  
egen t     = seq(), f(`start') t(`end') 

sort  id t
xtset id t

lab var id "面板变量"
lab var t  "时间变量"

gen D = 0
replace D = 1 if id==2 & t>=5
replace D = 1 if id==3 & t>=8
lab var D "已处理"

gen Y = 0
replace Y = D * 2 if id==2 & t>=5
replace Y = D * 4 if id==3 & t>=8

lab var Y "结果变量"
```

如果我们绘制这个：

```stata
twoway ///
	(connected Y t if id==1) ///
	(connected Y t if id==2) ///
	(connected Y t if id==3) ///
		, ///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(1 "id=1" 2 "id=2" 3 "id=3"))		

```

我们得到：

<img src="../../../assets/images/twfe5.png" width="100%">

在图中我们可以看到处理在两个不同点发生。对id=2的处理发生在$$ t $$=5，而对id=3的处理发生在$$ t $$=8。当第二次处理发生时，id=2已经被处理并且基本上是常数。所以对于id=3，id=2也是预处理组的一部分，特别是如果我们只考虑时间范围$$ 5 \leq t \leq 10 $$。从仅仅看图也不清楚在这种情况下ATT应该是什么，因为我们无法再像以前讨论的简单示例那样平均处理大小。

为了恢复这一点，我们可以运行一个简单的规范：

```stata
xtreg Y D i.t, fe 
reghdfe Y D, absorb(id t)   // 替代规范
```

这给了我们一个ATT的$$ \hat{\beta} $$ = 2.91。总而言之，这是考虑时间和面板固定效应后的平均处理大小。

回到图中，这种相对分组的处理和未处理，早期和晚期处理，是新双重差分论文的一部分，正是因为这些组合中的每一个都在整体平均$$ \hat{\beta} $$中发挥了自己的作用。这正是Bacon分解告诉我们的。它将$$ \hat{\beta} $$系数解包为加权平均$$ \hat{\beta} $$s系数，这些系数是从三个不同2×2组估计的：

1. **已处理($$ T $$)**与**从未处理($$ U $$)**
2. **早期处理($$ T^e $$)**与**晚期对照($$ C^l $$)**
3. **晚期处理($$ T^l $$)**与**早期对照($$ C^e $$)**

换句话说，面板id根据首次处理发生的时间以及它与其他面板id的处理关系被分成不同的时机队列。面板id越多，处理时机差异越大，上述组合就越多。

在我们的简单示例中，我们有两个处理过的面板id：id=2（早期处理$$ T^e $$）和id=3（晚期处理$$ T^l $$）。处理与从未处理可以进一步分为早期处理与从未处理($$ T^e $$ vs $$ U $$)和晚期处理与从未处理($$ T^l $$ vs $$ U $$)。总的来说，如果有三个组，估计四组值。Goodman-Bacon在论文中也使用了类似的示例。

每组值本质上是一个基本2×2 TWFE模型，我们从中恢复两件事：

* 使用经典TWFE的2×2 ($$ \hat{\beta} $$)参数
* 该参数对整体($$ \hat{\beta}^{DD} $$)的**权重**，由其*相对大小*在数据中决定

我们稍后回到这些。但首先，让我们看看`bacondecomp`命令给了我们什么：

```stata
bacondecomp Y D, ddetail
```

在没有控制的情况下，这是我们可以用于运行`bacondecomp`的唯一选项。在命令结束时，我们得到这个数字：

<img src="../../../assets/images/bacon1.png" width="100%">

该图显示了我们示例中三个组的四个点。处理与从未处理($$ T $$ vs $$ U $$)显示为三角形。叉表示晚期与早期处理($$ T^l $$ vs $$ T^e $$)组合。空心圆表示时机组或早期与晚期处理组($$ T^e $$ vs $$ T^l $$)。

图形信息显示在表格输出中：

```stata
Computing decomposition across 3 timing groups
including a never-treated group
------------------------------------------------------------------------------
           Y | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
           D |   2.909091   .3179908     9.15   0.000      2.28584    3.532341
------------------------------------------------------------------------------

Bacon Decomposition

+---------------------------------------------------+
|                      |         Beta   TotalWeight |
|----------------------+----------------------------|
|         Early_v_Late |            2   .1818181841 |
|         Late_v_Early |            4   .1363636317 |
|       Never_v_timing |  2.933333323   .6818181841 |
+---------------------------------------------------+

```

这里我们得到了我们的权重和每个组的2×2 $$ \beta $$。该表告诉我们($$ T $$ vs $$ U $$)，这是晚期和早期处理与从未处理的总和，具有最大的权重，其次是早期与晚期处理，最后是晚期与早期处理。

让我们看看存储的信息：

```stata
ereturn list
```

感兴趣的key矩阵是`e(summdd)`：

```stata
mat list e(sumdd)
```

这给了我们以下内容：

```stata
e(sumdd)[3,2]
                     Beta  TotalWeight
Early_v_Late            2    .18181818
Late_v_Early            4    .13636363
Never_v_ti~g    2.9333333    .68181818
```

从这个矩阵我们可以恢复$$ \beta $$：

```stata
display e(sumdd)[1,1]*e(sumdd)[1,2] + e(sumdd)[2,1]*e(sumdd)[2,2] + e(sumdd)[3,1]*e(sumdd)[3,2]
```

这给了我们$$ \beta $$ = 2.909的原始值，作为不同2×2处理、晚期和从未处理组组合的加权和。这种分解本质上是Bacon分解的核心点。

---

## 权重的逻辑

在本节中，我们将学习为我们的示例手动恢复权重。为了做到这一点，我们需要通过本文中定义的方程：

[Goodman-Bacon, A. (2021)。处理时机变化的双重差分](https://www.sciencedirect.com/science/article/pii/S0304407621001445)。计量经济学杂志。

如果你无法访问它，网上有工作论文版本（例如[NBER上的这个](https://www.nber.org/papers/w25018)）以及YouTube上的视频，例如[这里的](https://www.youtube.com/watch?v=m1xSMNTKoMs)。

让我们从论文中的方程3开始，它指出：

$$ \hat{\beta}^{DD} = \frac{\hat{C}(y_{it},\tilde{D}_{it})}{\hat{V}^D} = \frac{ \frac{1}{NT} \sum_i{\sum_t{y_{it}\tilde{D}_{it}}}}{ \frac{1}{NT} \sum_i{\sum_t{\tilde{D}^2_{it}}}}  $$ 

这基本上是一个带固定效应的标准面板回归（见Greene或Wooldridge关于面板估计的教科书）。在引擎盖下，符号方面发生了很多事情，我们需要定义。让我们从基本的开始：

*  $$ N $$ = 总面板，因为$$ i = 1\dots N $$
*  $$ T $$ = 总时间段，因为$$ t = 1\dots T $$

符号$$ \tilde{D}_{it} $$是$$ D_{it} $$的去均值值，它是一个虚拟变量，等于处理的观察值为1，否则为0。~符号告诉我们要按时间和面板均值去均值。换句话说：

$$ \tilde{D}_{it} = (D_{it} - D_i) - (D_{t} - \bar{\bar{D}})  $$ 

其中

$$ \bar{\bar{D}} = \frac{\sum_i{\sum_t{D_{it}}}}{NT}  $$

这只是所有观察值的均值。此规范用于去均值变量（以纳入固定效应）。如果我们对数据进行去均值或中心化，我们也可以使用标准的`reg`命令在Stata中恢复面板估计。在语法方面，这意味着`xtreg y i.t, fe`等价于`reg tildey` [check]（见Greene或Wooldridge）。

所以如果我们去$$ \hat{\beta}^{DD} $$方程，$$ \hat{V}^D $$本质上是$$ D_{it} $$的方差。对于我们的基本示例，我们可以手动计算均值（以双精度！）：

```stata
egen double d_barbar=mean(D)

bysort id: egen double d_meani=mean(D)

bysort t: egen double d_meant=mean(D)

gen double d_tilde=(d-d_meani)-(d_meant-d_barbar)

gen double d_tilde_sq=d_tilde^2

```

| $$ i $$ | $$ t $$ | $$ y $$ | $$ D $$ | $$ \bar{D}_i $$ | $$ \bar{D}_t $$ | $$ \bar{\bar{D}} $$ | $$ \tilde{D}_{it} $$ | $$ \tilde{D}^2_{it} $$ |
| - | - | - | - | -| - | - | - | - |
| 1 | 1  | 0 | 0     | 0       | 0       | 0.3     | 0.3        | 0.09        |
| 1 | 2  | 0 | 0     | 0       | 0       | 0.3     | 0.3        | 0.09        |
| 1 | 3  | 0 | 0     | 0       | 0       | 0.3     | 0.3        | 0.09        |
| 1 | 4  | 0 | 0     | 0       | 0       | 0.3     | 0.3        | 0.09        |
| 1 | 5  | 0 | 0     | 0       | 0.33    | 0.3     | \-0.03     | 0.0009      |
| 1 | 6  | 0 | 0     | 0       | 0.33    | 0.3     | \-0.03     | 0.0009      |
| 1 | 7  | 0 | 0     | 0       | 0.33    | 0.3     | \-0.03     | 0.0009      |
| 1 | 8  | 0 | 0     | 0       | 0.67    | 0.3     | \-0.37     | 0.1369      |
| 1 | 9  | 0 | 0     | 0       | 0.67    | 0.3     | \-0.37     | 0.1369      |
| 1 | 10 | 0 | 0     | 0       | 0.67    | 0.3     | \-0.37     | 0.1369      |
| 2 | 1  | 0 | 0     | 0.6     | 0       | 0.3     | \-0.3      | 0.09        |
| 2 | 2  | 0 | 0     | 0.6     | 0       | 0.3     | \-0.3      | 0.09        |
| 2 | 3  | 0 | 0     | 0.6     | 0       | 0.3     | \-0.3      | 0.09        |
| 2 | 4  | 0 | 0     | 0.6     | 0       | 0.3     | \-0.3      | 0.09        |
| 2 | 5  | 2 | 1     | 0.6     | 0.33    | 0.3     | 0.37       | 0.1369      |
| 2 | 6  | 2 | 1     | 0.6     | 0.33    | 0.3     | 0.37       | 0.1369      |
| 2 | 7  | 2 | 1     | 0.6     | 0.33    | 0.3     | 0.37       | 0.1369      |
| 2 | 8  | 2 | 1     | 0.6     | 0.67    | 0.3     | 0.03       | 0.0009      |
| 2 | 9  | 2 | 1     | 0.6     | 0.67    | 0.3     | 0.03       | 0.0009      |
| 2 | 10 | 2 | 1     | 0.6     | 0.67    | 0.3     | 0.03       | 0.0009      |
| 3 | 1  | 0 | 0     | 0.3     | 0       | 0.3     | 0          | 0           |
| 3 | 2  | 0 | 0     | 0.3     | 0       | 0.3     | 0          | 0           |
| 3 | 3  | 0 | 0     | 0.3     | 0       | 0.3     | 0          | 0           |
| 3 | 4  | 0 | 0     | 0.3     | 0       | 0.3     | 0          | 0           |
| 3 | 5  | 0 | 0     | 0.3     | 0.33    | 0.3     | \-0.33     | 0.1089      |
| 3 | 6  | 0 | 0     | 0.3     | 0.33    | 0.3     | \-0.33     | 0.1089      |
| 3 | 7  | 0 | 0     | 0.3     | 0.33    | 0.3     | \-0.33     | 0.1089      |
| 3 | 8  | 4 | 1     | 0.3     | 0.67    | 0.3     | 0.33       | 0.1089      |
| 3 | 9  | 4 | 1     | 0.3     | 0.67    | 0.3     | 0.33       | 0.1089      |
| 3 | 10 | 4 | 1     | 0.3     | 0.67    | 0.3     | 0.33       | 0.1089      |

其中$$ D $$ = 1如果处理，$$ \bar{D}_i $$是$$ D $$对每个面板id $$ i $$的平均值，$$ \bar{D}_t $$是$$ D $$对每个$$ t $$的平均值，$$ \bar{\bar{D}} $$是$$ D $$列的平均值。$$ \tilde{D}_{it} $$使用上述公式计算，$$ \tilde{D}^2_{it} $$只是其平方项。这里$$ \tilde{D}^2_{it} $$列的总和等于2.20，除以$$ NT $$，或3×10，等于0.0733，即方差$$ \hat{V}^D $$。

我们也可以在Stata中如下恢复$$ \hat{V}^D $$：

```stata
 xtreg D i.t , fe 
 
 cap drop Dtilde
 predict double Dtilde, e
 
 sum Dtilde
 scalar VD = (( r(N) - 1) / r(N) ) * r(Var) 
```

或使用标准方差/协方差方法手动：

```stata
gen double numerator_1=y*d_tilde
egen double numerator=mean(numerator_1)
egen double denominator=mean(d_tilde_square)

sum denominator 
```

我们可以通过键入`display VD`来查看值。这里我们应该得到0.0733，如预期。

在论文中，提供了三个额外公式来处理我们示例中的三个组。这些在方程10中定义如下：

*   早期处理与晚期对照($$ T^e $$ vs $$ C^l $$)

$$  s_{el} = \frac{((n_e + n_l)(1 - \bar{D}_l))^2  n_{el} (1 - n_{el}) \frac{\bar{D}_e - \bar{D}_l}{1 - \bar{D}_l} \frac{1 - \bar{D}_e}{1 - \bar{D}_l}  }{\hat{V}^D}  $$

*   晚期处理与早期对照($$ T^l $$ vs $$ C^e $$)

$$  s_{le} = \frac{ ((n_e + n_l)\bar{D}_e))^2  n_{el} (1 - n_{el}) \frac{\bar{D}_l}{\bar{D}_e} \frac{\bar{D}_e - \bar{D}_l}{1 - \bar{D}_e}  }{\hat{V}^D}  $$

*   处理与未处理($$ T $$ vs $$ U $$)：

$$  s_{jU} = \frac{ (n_j + n_U)^2 n_{jU} (1 - n_{jU}) \bar{D}_k (1 - \bar{D}_k)}{\hat{V}^D}  $$

其中$$ j = \{e,l\} $$或早期和晚期处理组。

$$ s $$基本上是命令`bacondecomp`恢复的权重，这些权重也显示在表中。由于每个2×2组也有一个2×2 $$ \hat{\beta} $$系数与之相关，权重有两个属性：

*    它们加起来等于1或：

$$ \sum_j{s_{jU}} + \sum_{e \neq U}{\sum_{l>e}{s_{el} + s_{le}}} = 1  $$

*    整体$$ \hat{\beta}^{DD} $$是2×2 $$ \hat{\beta} $$参数的加权和：

$$  \hat{\beta^{DD}} = \sum_j{s_{jU} \hat{\beta}_{jU}} + \sum_{e \neq U}{\sum_{l>e}{ ( s_{el} \hat{\beta}_{el} + s_{le} \hat{\beta}_{le}} ) } $$

下一步，我们需要定义所有新符号。但在我们这样做之前，我们需要把逻辑理顺。为此，我们从原始视觉开始：

<img src="../../../assets/images/twfe5.png" width="100%">

这里我们可以看到从未处理组，$$ U $$，即id=1，运行10个时期，并在零个时期接受处理。早期处理组（id=2），$$ T^e $$，运行6个时期，从5开始，结束于10，而晚期处理组（id=3），$$ T^l $$从8到10运行3个时期。这些数字告诉我们一个组保持处理的时间周期。这些值在总观察值$$ T $$中的份额给了我们$$ D^e = 6/10 $$和$$ De = 3/10 $$值。这告诉我们每个组在总观察值中施加多少权重。保持处理时间更长的组将（并且应该）对ATT有更大的影响。

下一组值是$$ n_e $$，$$ n_l $$，和$$ n_U $$，这些是组在总时间段中的样本大小。由于我们的面板完全平衡，有三个组，这些值等于$$ n_e = n_l = n_U = 1/3 $$（*检查这个*）。每个2×2包含一对$$ \{e,l,U\} $$组，$$ n $$份额的总和本质上权衡了组样本中两个面板id的相对大小在总观察值中。

最后一个未知值的形式为$$ n_{ab} $$，它是组时间内处理单元的份额，或

$$ n_{ab} = \frac{n_a}{n_a + n_b} $$ 

此值的目标是权衡每个组内的处理相对份额。如果处理发生在非常小的时间分数，或非常大的时间分数，那么它在整体$$ \hat{\beta} $$中的权重将减少。换句话说，在每个组中更均匀分布的处理被给予更高的偏好。

从上面的份额公式中，我们可以看到它都是关于计算所有类型的权重，这些权重然后应用于恢复的2×2 $$ \hat{beta} $$每个组。

---

## 手动恢复权重

让我们从手动恢复过程开始。

**晚期处理与早期对照**

为了可视化晚期处理与早期对照，我们生成以下控制并绘制图形：

```stata
cap drop tle
gen tle = .
replace tle = 0 if t>=5
replace tle = 1 if t>=8 & id==3

twoway ///
	(line Y t if id==1, lc(gs12)) ///
	(line Y t if id==2, lc(gs12)) ///
	(line Y t if id==3, lc(gs12)) ///
	(line Y t if id==3 & tle!=.) ///
	(line Y t if id==2 & tle!=.) ///
		, ///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(4 "晚期处理" 5 "早期对照"))	
```

我们得到这个数字：

<img src="../../../assets/images/bacon2.png" width="100%">

那么这个数字发生了什么？我们看到id=2变量，早期处理，是平的，而id=3变量得到处理。这里我们说，而不是计算整个样本的TWFE估计量，我们只生成id=3，并使用id=2作为控制，因为它在$$ t $$ = 5到10区间内稳定。

由于我们从上面知道，此设置的公式是：

$$  s_{le} = \frac{ ((n_e + n_l)\bar{D}_e))^2  n_{el} (1 - n_{el}) \frac{\bar{D}_l}{\bar{D}_e} \frac{\bar{D}_e - \bar{D}_l}{\bar{D}_e}  }{\hat{V}^D}  $$

我们可以如下手动定义值：

```stata
scalar De  = 6/10  // 早期处理在所有样本中的份额
scalar Dl  = 3/10  // 晚期处理在所有样本中的份额
scalar nl = 1/3    // 晚期的相对组大小
scalar ne = 1/3    // 早期的相对组大小
scalar nel = 3/6   // 组样本中处理时期的份额
```

其中最后一个标量`nel`是处理的份额，在总组时间范围6个时期内为3个时期。这里我们可以如下恢复权重：

```stata
display "weight_le = " (((ne + nl) * (De))^2 * nel * (1 - nel) * (Dl / De) * ((De - Dl)/(De)) ) / VD
```

这给了我们0.136的值。

由于我们已经定义了样本，我们也可以恢复2×2 TWFE参数：

```stata
xtreg Y D i.tle if (id==2 | id==3), fe robust
```

这给了我们一个$$ D $$ = 4的值。由于我们没有时间或面板固定效应或高斯误差，我们也可以从图中看到，id=3的变化是4个单位，而id=2保持恒定，所以变化是0。

将上述值与上面显示的`bacondecomp`表进行比较，你会发现这些值与表值完全匹配。

**早期处理与晚期对照**

现在让我们翻转这种情况。我们把晚期处理变量作为早期处理组的控制。

```stata
twoway ///
	(line Y t if id==1, lc(gs12)) ///
	(line Y t if id==2, lc(gs12)) ///
	(line Y t if id==3, lc(gs12)) ///
	(line Y t if id==3 & tel!=.) ///
	(line Y t if id==2 & tel!=.) ///
		, ///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(4 "早期处理" 5 "晚期对照"))
```

从图中，我们可以看到这属于这个范围：

<img src="../../../assets/images/bacon3.png" width="100%">

我们恢复份额的权重如下：

```stata
scalar De  = 6/10  // 晚期处理在所有样本中的份额
scalar Dl  = 3/10  // 早期处理在所有样本中的份额

scalar nl = 1/3    // 晚期的相对组大小
scalar ne = 1/3    // 早期的相对组大小		
scalar nle = 3/6   // 组样本中处理时期的份额。为什么它是3/6而不是3/7？		

display "weight_el = " (((ne + nl) * (1 - Dl))^2 * (nle * (1 - nle)) * ((De - Dl)/(1 - Dl)) * ((1 - De)/(1 - Dl))) / VD

xtreg Y D i.tel if (id==2 | id==3), fe robust
```

这给了我们0.182的值和2的$$ \beta $$系数。同样，这些值可以与上面的`bacondecomp`表进行比较。

**处理与未处理**

接下来我们将两个处理组（早期和晚期）与未处理组进行比较：

```stata
cap drop ten
gen ten = .
replace ten = 0 if id==1 
replace ten = 1 if id==2

twoway ///
	(line Y t if id==1, lc(gs12)) ///
	(line Y t if id==2, lc(gs12)) ///
	(line Y t if id==3, lc(gs12)) ///
	(line Y t if id==2 & ten!=.) ///
	(line Y t if id==1 & ten!=.) ///
		, ///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(4 "早期处理" 5 "从未处理"))
		
cap drop tln
gen tln = .
replace tln = 0 if id==1 
replace tln = 1 if id==3

twoway ///
	(line Y t if id==1, lc(gs12)) ///
	(line Y t if id==2, lc(gs12)) ///
	(line Y t if id==3, lc(gs12)) ///
	(line Y t if id==3 & tln!=.) ///
	(line Y t if id==1 & tln!=.) ///
		, ///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(4 "晚期处理" 5 "从未处理"))
```

<img src="../../../assets/images/bacon4.png" width="48%"><img src="../../../assets/images/bacon5.png" width="48%">

我们可以如下恢复系数：

```stata
xtreg Y D i.t if (id==1 | id==2), fe robust		// 早期
xtreg Y D i.t if (id==1 | id==3), fe robust		// 晚期
```

这给了我们早期和晚期分别为2和4。我们得到份额如下：

```stata
scalar Dl  = 3/10  // 晚期处理在所有样本中的份额
scalar De  = 6/10  // 早期处理在所有样本中的份额

scalar ne = 1/3    // 晚期的相对组大小
scalar nl = 1/3    // 晚期的相对组大小
scalar nU = 1/3    // 早期的相对组大小		

scalar nlU = 3/10   // 组样本中处理时期的份额。
scalar neU = 6/10   // 组样本中处理时期的份额。

display "weight_eU = " ((ne + nU)^2 * (neU * (1 - neU)) * (De * (1 - De))) / VD
display "weight_lU = " ((nl + nU)^2 * (nlU * (1 - nlU)) * (Dl * (1 - Dl))) / VD
```

其中份额分别等于0.3636和0.31818。如果我们把这些加起来，它们达到0.68181。这个数字与`bacondecomp`表中显示的数字不完全相同，但在这里我们可以看到这个组具有最高的权重，如预期。

我们也可以如下恢复各自的betas

```stata
// 早期与从未
xtreg Y D i.t if (id==1 | id==2), fe robust		

// 晚期与从未
xtreg Y D i.t if (id==1 | id==3), fe robust	
```

我们也可以手动检查beta系数的加权平均，并将其与回归系数进行比较：

```stata

// 手动
display 4*.31818182 + 2*.36363636 + 2*.18181818 + 4*.13636364

// 回归
reghdfe Y D, absorb(id t)
```

我们得到相同的2.909估计。

---

## 那么TWFE回归哪里出错了？

到目前为止，我们看过一些例子，我们在处理中有离散跳跃。在我们非常简单的例子中，我们运行了一些回归来估计我们可以手工恢复的几个观察的处理效应。我们还通过了Bacon分解，它告诉我们$$\hat{\beta}$$系数是各种2×2处理和未处理组的加权和。

但是TWFE模型哪里出错了？在这里，我们需要稍微改变处理效应。而不是离散跳跃，我们允许处理在一些时间点跨单元队列发生，我们让处理效应随时间逐渐增加。

而不是使用我们的简单例子，让我们通过添加多个面板id来稍微扩展问题集。

```stata
clear
local units = 30
local start = 1
local end   = 60

local time = `end' - `start' + 1
local obsv = `units' * `time'
set obs `obsv'

egen id    = seq(), b(`time')  
egen t     = seq(), f(`start') t(`end') 

sort  id t
xtset id t

lab var id "面板变量"
lab var t  "时间变量"

```

在这里，我们有30个单元（$$i$$）和60个时间段（$$t$$）。你可以增加到任何大小。我们稍后也会为此进行测试。

我们也可以固定种子，以防你想要完全复制我们在这里的内容：

```stata
set seed 13082021
```

你当然不需要这样做，但它有助于一些人遵循代码和脚本。我们稍后也会删除这个用于测试。

现在让我们生成一些虚拟变量：

```stata
cap drop Y
cap drop D
cap drop cohort
cap drop effect
cap drop timing

gen Y 	   = 0		// 结果变量	
gen D 	   = 0		// 干预变量
gen cohort = .  	// 总处理变量
gen effect = .		// 处理效应大小
gen timing = .		// 每个队列的处理发生时间
```

首先，我们需要定义队列。这些是$$i$$组，同时接受处理。例如，想想美国各州，一些州同时接受处理，然后是另一个队列，等等。

我们在这里做的是，我们随机分配一个队列。我们可以根据需要拥有尽可能多的队列（<$$i$$）。但我们添加了一个cohort=0，我们稍后将使用它作为从未处理的队列（我们现在不会这样做）。假设我们想要生成五个队列：

```stata
levelsof id, local(lvls)
foreach x of local lvls {
	local chrt = runiformint(0,5)	
	replace cohort = `chrt' if id==`x'
}
```

现在我们需要为每个队列定义两件事：（a），处理"效应"大小是多少，以及（b），处理何时发生，或"时机"变量。

让我们自动化这个：

```stata
levelsof cohort , local(lvls)  // 让所有队列现在都被处理
foreach x of local lvls {
	
	// (a) 效应
	
	local eff = runiformint(2,10)
		replace effect = `eff' if cohort==`x'
		
	// (b) 时机	
	
	local timing = runiformint(`start' + 5,`end' - 5)	
	replace timing = `timing' if cohort==`x'
		replace D = 1 if cohort==`x' & t>= `timing' 
}
```

在这里，我们为每个队列生成一个效应大小作为2到10之间的随机整数。可以是任何数字范围，也可以在连续范围内。

每个队列的时机也在t=5和t=55之间的间隔内随机生成。这只是为了确保处理队列不是非常占主导地位，只存在几个时期。

最后一步，产生结果效应：

```stata
replace Y = id + t + cond(D==1, effect * (t - timing), 0)
```

让我们绘制它，看看数据是什么样的：

```stata
levelsof cohort
local items = `r(r)'

local lines
levelsof id

forval x = 1/`r(r)' {
	
	qui summ cohort if id==`x'
	local color = `r(mean)' + 1
	colorpalette tableau, nograph
		
	local lines `lines' (line Y t if id==`x', lc("`r(p`color')'") lw(vthin))	||
}

twoway ///
	`lines', legend(off)
```

这给了我们：

<img src="../../../assets/images/TWFE_bashing1.png" width="100%">

每个队列都有不同的颜色。这通过`colorpalette`包传递到线图。

在图中我们看到绿色队列早期处理并包含很多id。橙色是下一个，但id很少。同样红色和紫色是最后处理的。无论处理是晚期还是早期，处理的效果都是积极的。但是当我们运行TWFE回归时会发生什么？

```stata
xtreg Y i.t D, fe
```

检查D系数。它是负的！我们也可以使用`reghdfe`包如下运行：

```stata
reghdfe Y D, absorb(id t)  
```

我在下面粘贴了`reghdfe`回归输出（`xtreg`输出太大）：

```stata
(MWFE estimator converged in 2 iterations)

HDFE Linear regression                            Number of obs   =      1,800
Absorbing 2 HDFE groups                           F(   1,   1710) =      59.04
                                                  Prob > F        =     0.0000
                                                  R-squared       =     0.8359
                                                  Adj R-squared   =     0.8273
                                                  Within R-sq.    =     0.0334
                                                  Root MSE        =    39.7334

------------------------------------------------------------------------------
           Y | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
           D |  -25.93176   3.374793    -7.68   0.000    -32.55092    -19.3126
       _cons |   114.9349   1.997427    57.54   0.000     111.0172    118.8525
------------------------------------------------------------------------------

Absorbed degrees of freedom:
-----------------------------------------------------+
 Absorbed FE | Categories  - Redundant  = Num. Coefs |
-------------+---------------------------------------|
          id |        30           0          30     |
           t |        60           1          59     |
-----------------------------------------------------+

```

这显然是错误的，因为我们确定处理是积极的。那么发生了什么？让我们使用Bacon分解检查：

```stata
bacondecomp Y D, ddetail
```

这给了我们这个数字：

<img src="../../../assets/images/TWFE_bashing2.png" width="100%">

详细信息在以下输出中提供：

```stata
Computing decomposition across 6 timing groups
------------------------------------------------------------------------------
           Y | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
           D |  -25.93176   3.374793    -7.68   0.000    -32.54623   -19.31729
------------------------------------------------------------------------------

Bacon Decomposition

+---------------------------------------------------+
|                      |         Beta   TotalWeight |
|----------------------+----------------------------|
|         Early_v_Late |           51   .0123657302 |
|         Late_v_Early |         -127   .0741943846 |
|         Early_v_Late |           75   .0357232214 |
|         Late_v_Early |       -121.5   .1667083601 |
|         Early_v_Late |            7   .0146556807 |
|         Late_v_Early |          4.5   .0170982933 |
|         Early_v_Late |           84   .0332042752 |
|         Late_v_Early |          -78   .1383511554 |
|         Early_v_Late |           10   .0167929674 |
|         Late_v_Early |           48   .0174926737 |
|         Early_v_Late |            3   .0122130672 |
|         Late_v_Early |           42   .0095414589 |
|         Early_v_Late |          132   .0412191018 |
|         Late_v_Early |         -134   .0618286496 |
|         Early_v_Late |           26   .0329752828 |
|         Late_v_Early |           -8   .0123657302 |
|         Early_v_Late |           27   .0618795396 |
|         Late_v_Early |          -14   .0174036209 |
|         Early_v_Late |         52.5   .0474952625 |
|         Late_v_Early |        -59.5   .0122130672 |
|         Early_v_Late |  60.01138465   .1642784771 |
+---------------------------------------------------+
```

正是这种分解和负权重构成了以下部分中讨论的新双重差分包中估计器的基础。










