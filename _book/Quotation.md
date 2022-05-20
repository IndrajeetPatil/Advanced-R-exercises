# Quotation

### Exercises 19.2.2

**Q1.** For each function in the following base R code, identify which arguments are quoted and which are evaluated.


```r
library(MASS)
#> 
#> Attaching package: 'MASS'
#> The following object is masked from 'package:dplyr':
#> 
#>     select

mtcars2 <- subset(mtcars, cyl == 4)

with(mtcars2, sum(vs))
sum(mtcars2$am)

rm(mtcars2)
```

**Q2.** For each function in the following tidyverse code, identify which arguments are quoted and which are evaluated.


```r
library(dplyr)
library(ggplot2)

by_cyl <- mtcars %>%
  group_by(cyl) %>%
  summarise(mean = mean(mpg))

ggplot(by_cyl, aes(cyl, mean)) +
  geom_point()
```

### Exercises 19.3.6

**Q1.** How is `expr()` implemented? Look at its source code.

**Q2.** Compare and contrast the following two functions. Can you predict the output before running them?


```r
f1 <- function(x, y) {
  exprs(x = x, y = y)
}
f2 <- function(x, y) {
  enexprs(x = x, y = y)
}
f1(a + b, c + d)
f2(a + b, c + d)
```

**Q3.**  What happens if you try to use `enexpr()` with an expression (i.e. `enexpr(x + y)`? What happens if `enexpr()` is passed a missing argument?

**Q4.** How are `exprs(a)` and `exprs(a = )` different? Think about both the input and the output.

**Q5.** What are other differences between `exprs()` and `alist()`? Read the  documentation for the named arguments of `exprs()` to find out.

**Q6.** The documentation for `substitute()` says:

    > Substitution takes place by examining each component of the parse tree 
    > as follows: 
    > 
    > * If it is not a bound symbol in `env`, it is unchanged. 
    > * If it is a promise object (i.e., a formal argument to a function) 
    >   the expression slot of the promise replaces the symbol. 
    > * If it is an ordinary variable, its value is substituted, unless 
    > `env` is .GlobalEnv in which case the symbol is left unchanged.
  
Create examples that illustrate each of the above cases.

### Exercises 19.4.8

**Q1.** Given the following components:


```r
xy <- expr(x + y)
xz <- expr(x + z)
yz <- expr(y + z)
abc <- exprs(a, b, c)
```

Use quasiquotation to construct the following calls:


```r
(x + y) / (y + z)
-(x + z)^(y + z)
(x + y) + (y + z) - (x + y)
atan2(x + y, y + z)
sum(x + y, x + y, y + z)
sum(a, b, c)
mean(c(a, b, c), na.rm = TRUE)
foo(a = x + y, b = y + z)
```

**Q2.** The following two calls print the same, but are actually different:


```r
(a <- expr(mean(1:10)))
#> mean(1:10)
(b <- expr(mean(!!(1:10))))
#> mean(1:10)
identical(a, b)
#> [1] FALSE
```

What's the difference? Which one is more natural?

### Exercises 19.6.5

**Q1.** One way to implement `exec()` is shown below. Describe how it works. What are the key ideas?


```r
exec <- function(f, ..., .env = caller_env()) {
  args <- list2(...)
  do.call(f, args, envir = .env)
}
```

**Q2.** Carefully read the source code for `interaction()`, `expand.grid()`, and `par()`. Compare and contrast the techniques they use for switching between dots and list behaviour.

**Q3.**  Explain the problem with this definition of `set_attr()`


```r
set_attr <- function(x, ...) {
  attr <- rlang::list2(...)
  attributes(x) <- attr
  x
}
set_attr(1:10, x = 10)
#> Error in attributes(x) <- attr: attributes must be named
```

### Exercises 19.7.5

**Q1.** In the linear-model example, we could replace the `expr()` in `reduce(summands, ~ expr(!!.x + !!.y))` with `call2()`: `reduce(summands, call2, "+")`. Compare and contrast the two approaches. Which do you think is easier to read?

**Q2.** Re-implement the Box-Cox transform defined below using unquoting and `new_function()`:


```r
bc <- function(lambda) {
  if (lambda == 0) {
    function(x) log(x)
  } else {
    function(x) (x^lambda - 1) / lambda
  }
}
```

**Q3.**  Re-implement the simple `compose()` defined below using quasiquotation and `new_function()`:


```r
compose <- function(f, g) {
  function(...) f(g(...))
}
```
