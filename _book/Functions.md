# Functions

## Exercise 6.2.5

Q1. Function names

Given a name, `match.fun()` lets you find a function.


```r
match.fun("mean")
#> function (x, ...) 
#> UseMethod("mean")
#> <bytecode: 0x0000000016486e80>
#> <environment: namespace:base>
```

But, given a function, it doesn't make sense to find its name in R because there can be multiple names bound to the same function.


```r
f1 <- function(x) mean(x)
f2 <- f1

match.fun("f1")
#> function(x) mean(x)

match.fun("f2")
#> function(x) mean(x)
```

Q2. Correct way to call anonymous functions

This is not correct since the function will evaluate `3()`, which is syntactically not allowed since literals can't be treated like functions.


```r
(function(x) 3())()
#> Error in (function(x) 3())(): attempt to apply non-function
```

This is correct.


```r
(function(x) 3)()
#> [1] 3
```

Q3. Scan code for opportunities to use anonymous function

Self activity.

Q4. Detecting functions and primitive functions

Use `is.function()` to check if an object is a function:


```r
# these are functions
f <- function(x) 3
is.function(mean)
#> [1] TRUE
is.function(f)
#> [1] TRUE

# these aren't
is.function("x")
#> [1] FALSE
is.function(new.env())
#> [1] FALSE
```

Use `is.primitive()` to check if a function is primitive:


```r
# primitive
is.primitive(sum)
#> [1] TRUE
is.primitive(`+`)
#> [1] TRUE

# not primitive
is.primitive(mean)
#> [1] FALSE
is.primitive(read.csv)
#> [1] FALSE
```

Q5. Detecting functions and primitive functions


```r
objs <- mget(ls("package:base", all = TRUE), inherits = TRUE)
funs <- Filter(is.function, objs)
```

> Which base function has the most arguments?

`scan()` function has the most arguments.


```r
library(tidyverse)

df_formals <- purrr::map_df(funs, ~ length(formals(.))) %>%
  tidyr::pivot_longer(
    cols = dplyr::everything(),
    names_to = "function",
    values_to = "argumentCount"
  ) %>%
  dplyr::arrange(desc(argumentCount))
```

> How many base functions have no arguments? What’s special about those functions?

At the time of writing, 253 base functions have no arguments. Most of these are primitive functions


```r
dplyr::filter(df_formals, argumentCount == 0)
#> # A tibble: 253 x 2
#>    `function` argumentCount
#>    <chr>              <int>
#>  1 -                      0
#>  2 !                      0
#>  3 !=                     0
#>  4 $                      0
#>  5 $<-                    0
#>  6 %%                     0
#>  7 %*%                    0
#>  8 %/%                    0
#>  9 &                      0
#> 10 &&                     0
#> # ... with 243 more rows
```

> How could you adapt the code to find all primitive functions?


```r
objs <- mget(ls("package:base", all = TRUE), inherits = TRUE)
funs <- Filter(is.function, objs)
primitives <- Filter(is.primitive, funs)

names(primitives)
#>   [1] "-"                    "!"                   
#>   [3] "!="                   "$"                   
#>   [5] "$<-"                  "%%"                  
#>   [7] "%*%"                  "%/%"                 
#>   [9] "&"                    "&&"                  
#>  [11] "("                    "*"                   
#>  [13] "...elt"               "...length"           
#>  [15] "...names"             ".C"                  
#>  [17] ".cache_class"         ".Call"               
#>  [19] ".Call.graphics"       ".class2"             
#>  [21] ".External"            ".External.graphics"  
#>  [23] ".External2"           ".Fortran"            
#>  [25] ".Internal"            ".isMethodsDispatchOn"
#>  [27] ".Primitive"           ".primTrace"          
#>  [29] ".primUntrace"         ".subset"             
#>  [31] ".subset2"             "/"                   
#>  [33] ":"                    "::"                  
#>  [35] ":::"                  "@"                   
#>  [37] "@<-"                  "["                   
#>  [39] "[["                   "[[<-"                
#>  [41] "[<-"                  "^"                   
#>  [43] "{"                    "|"                   
#>  [45] "||"                   "~"                   
#>  [47] "+"                    "<"                   
#>  [49] "<-"                   "<<-"                 
#>  [51] "<="                   "="                   
#>  [53] "=="                   ">"                   
#>  [55] ">="                   "abs"                 
#>  [57] "acos"                 "acosh"               
#>  [59] "all"                  "any"                 
#>  [61] "anyNA"                "Arg"                 
#>  [63] "as.call"              "as.character"        
#>  [65] "as.complex"           "as.double"           
#>  [67] "as.environment"       "as.integer"          
#>  [69] "as.logical"           "as.numeric"          
#>  [71] "as.raw"               "asin"                
#>  [73] "asinh"                "atan"                
#>  [75] "atanh"                "attr"                
#>  [77] "attr<-"               "attributes"          
#>  [79] "attributes<-"         "baseenv"             
#>  [81] "break"                "browser"             
#>  [83] "c"                    "call"                
#>  [85] "ceiling"              "class"               
#>  [87] "class<-"              "Conj"                
#>  [89] "cos"                  "cosh"                
#>  [91] "cospi"                "cummax"              
#>  [93] "cummin"               "cumprod"             
#>  [95] "cumsum"               "digamma"             
#>  [97] "dim"                  "dim<-"               
#>  [99] "dimnames"             "dimnames<-"          
#> [101] "emptyenv"             "enc2native"          
#> [103] "enc2utf8"             "environment<-"       
#> [105] "exp"                  "expm1"               
#> [107] "expression"           "floor"               
#> [109] "for"                  "forceAndCall"        
#> [111] "function"             "gamma"               
#> [113] "gc.time"              "globalenv"           
#> [115] "if"                   "Im"                  
#> [117] "interactive"          "invisible"           
#> [119] "is.array"             "is.atomic"           
#> [121] "is.call"              "is.character"        
#> [123] "is.complex"           "is.double"           
#> [125] "is.environment"       "is.expression"       
#> [127] "is.finite"            "is.function"         
#> [129] "is.infinite"          "is.integer"          
#> [131] "is.language"          "is.list"             
#> [133] "is.logical"           "is.matrix"           
#> [135] "is.na"                "is.name"             
#> [137] "is.nan"               "is.null"             
#> [139] "is.numeric"           "is.object"           
#> [141] "is.pairlist"          "is.raw"              
#> [143] "is.recursive"         "is.single"           
#> [145] "is.symbol"            "isS4"                
#> [147] "lazyLoadDBfetch"      "length"              
#> [149] "length<-"             "levels<-"            
#> [151] "lgamma"               "list"                
#> [153] "log"                  "log10"               
#> [155] "log1p"                "log2"                
#> [157] "max"                  "min"                 
#> [159] "missing"              "Mod"                 
#> [161] "names"                "names<-"             
#> [163] "nargs"                "next"                
#> [165] "nzchar"               "oldClass"            
#> [167] "oldClass<-"           "on.exit"             
#> [169] "pos.to.env"           "proc.time"           
#> [171] "prod"                 "quote"               
#> [173] "range"                "Re"                  
#> [175] "rep"                  "repeat"              
#> [177] "retracemem"           "return"              
#> [179] "round"                "seq.int"             
#> [181] "seq_along"            "seq_len"             
#> [183] "sign"                 "signif"              
#> [185] "sin"                  "sinh"                
#> [187] "sinpi"                "sqrt"                
#> [189] "standardGeneric"      "storage.mode<-"      
#> [191] "substitute"           "sum"                 
#> [193] "switch"               "tan"                 
#> [195] "tanh"                 "tanpi"               
#> [197] "tracemem"             "trigamma"            
#> [199] "trunc"                "unclass"             
#> [201] "untracemem"           "UseMethod"           
#> [203] "while"                "xtfrm"
```

Q6. Important components of a function

Except for primitive functions, all functions have 3 important components:

* `formals()`
* `body()`
* `environment()`

Q7. Printing of function environment

All package functions print their environment:


```r
# base
mean
#> function (x, ...) 
#> UseMethod("mean")
#> <bytecode: 0x0000000016486e80>
#> <environment: namespace:base>

# other package function
purrr::map
#> function (.x, .f, ...) 
#> {
#>     .f <- as_mapper(.f, ...)
#>     .Call(map_impl, environment(), ".x", ".f", "list")
#> }
#> <bytecode: 0x0000000031a721a0>
#> <environment: namespace:purrr>
```

There are two exceptions to this rule:

* primitive functions:


```r
sum
#> function (..., na.rm = FALSE)  .Primitive("sum")
```

* functions created in the global environment:


```r
f <- function(x) mean(x)
f
#> function(x) mean(x)
```

## Exercise 6.4.5

Q1. All about *c*

In `c(c = c)`:
* first *c* is interpreted as a function `c()`
* second *c* as a name for the vector element
* third *c* as a variable with value `10`


```r
c <- 10
c(c = c)
#>  c 
#> 10
```

Q2. Four principles that govern how R looks for values

1. Name masking (names defined inside a function mask names defined outside a function)

2. Functions vs. variables (the rule above also applies to function names) 

3. A fresh start (every time a function is called a new environment is created to host its execution)

4. Dynamic look-up (R looks for values when the function is run, not when the function is created)

Q3. Predict the return

Correctly predicted 😉😉


```r
f <- function(x) {
  f <- function(x) {
    f <- function() {
      x^2
    }
    f() + 1
  }
  f(x) * 2
}

f(10)
#> [1] 202
```


## Exercise 6.5.4 

Q1. Property of `&&`

`&&` evaluates left to right and short-circuit evaluation, i.e., if the first operand is `TRUE`, R will short-circuit and not even look at the second operand.


```r
x_ok <- function(x) {
  !is.null(x) && length(x) == 1 && x > 0
}

x_ok(NULL)
#> [1] FALSE

x_ok(1)
#> [1] TRUE

x_ok(1:3)
#> [1] FALSE
```

Replacing `&&` is `&` is undesirable because it performs element-wise logical comparisons and returns a vector of values that is not always useful for decision (`TRUE`, `FALSE`, or `NA`).


```r
x_ok <- function(x) {
  !is.null(x) & length(x) == 1 & x > 0
}

x_ok(NULL)
#> logical(0)

x_ok(1)
#> [1] TRUE

x_ok(1:3)
#> [1] FALSE FALSE FALSE
```

Q2. Principle behind return

The function returns `100`, and the principle at work here is lazy evaluation. When function environment encounters `x`, it evaluates argument `x = z` and since the name `z` is already bound to value 100, `x` is also bound to the same value.

We can check this by looking at the memory addresses:


```r
f2 <- function(x = z) {
  z <- 100
  print(x)

  print(lobstr::obj_addrs(list(x, z)))
}

f2()
#> [1] 100
#> [1] "0x31ad14b8" "0x31ad14b8"
```

Q3. Principle behind return

TODO:


```r
y <- 10
f1 <- function(x =
                 {
                   y <- 1
                   2
                 },
               y = 0)
{
  c(x, y)
}

f1()
#> [1] 2 1

y
#> [1] 10
```

## Exercise 6.6.1

Q1. Explain results


```r
sum(1, 2, 3)
#> [1] 6

mean(1, 2, 3)
#> [1] 1

sum(1, 2, 3, na.omit = TRUE)
#> [1] 7

mean(1, 2, 3, na.omit = TRUE)
#> [1] 1
```

Let's look at arguments for these functions:


```r
str(sum)
#> function (..., na.rm = FALSE)
str(mean)
#> function (x, ...)
```

As can be seen, `sum()` function doesn't have `na.omit` argument. So, the input `na.omit = TRUE` is treated as `1` (logical implicitly coerced to numeric), and thus the results. So, the expression evaluates to `sum(1, 2, 3, 1)`.

For `mean()` function, there is only one parameter (`x`) and it's matched by the first argument (`1`). So, the expression evaluates to `mean(1)`.

Q2. Finding documentation for `plot` arguments

First, check documentation for `plot()`:


```r
str(plot)
#> function (x, y, ...)
```

Since `...` are passed to `par()`, we can look at its documentation:


```r
str(par)
#> function (..., no.readonly = FALSE)
```

The docs for all parameters of interest [reside there](https://rdrr.io/r/graphics/par.html).

Q3. Reading source code for `plot.default`

Source code can be found [here](https://github.com/wch/r-source/blob/79e73dba5259b25ec30118d45fea64aeac0f41dc/src/library/graphics/R/plot.R#L51-L84).

`plot.default()` passes `...` to `localTitle()`, which passes it to `title()`.

`title()` has four parts: `main`, `sub`, `xlab`, `ylab`.

So having a single argument `col` would not work as it will be ambiguous as to which element to apply this argument to.


```r
localTitle <- function(..., col, bg, pch, cex, lty, lwd) title(...)

title <- function(main = NULL, sub = NULL, xlab = NULL, ylab = NULL,
                  line = NA, outer = FALSE, ...) {
  main <- as.graphicsAnnot(main)
  sub <- as.graphicsAnnot(sub)
  xlab <- as.graphicsAnnot(xlab)
  ylab <- as.graphicsAnnot(ylab)
  .External.graphics(C_title, main, sub, xlab, ylab, line, outer, ...)
  invisible()
}
```
