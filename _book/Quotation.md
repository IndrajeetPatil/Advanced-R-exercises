# Quasiquotation



Attaching the needed libraries:


```r
library(rlang)
library(dplyr)
library(ggplot2)
```

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

**A1.** To identify which arguments are quoted and which are evaluated, we can use the trick mentioned in the book:

> If you’re ever unsure about whether an argument is quoted or evaluated, try executing the code outside of the function. If it doesn’t work or does something different, then that argument is quoted.

- `library(MASS)`

The `package` argument in `library()` is quoted:


```r
library(MASS)

MASS
#> Error in eval(expr, envir, enclos): object 'MASS' not found
```

- `subset(mtcars, cyl == 4)`

The argument `x` is evaluated, while the argument `subset` is quoted.


```r
mtcars2 <- subset(mtcars, cyl == 4)

mtcars
#>                      mpg cyl  disp  hp drat    wt  qsec vs
#> Mazda RX4           21.0   6 160.0 110 3.90 2.620 16.46  0
#> Mazda RX4 Wag       21.0   6 160.0 110 3.90 2.875 17.02  0
#> Datsun 710          22.8   4 108.0  93 3.85 2.320 18.61  1
#> Hornet 4 Drive      21.4   6 258.0 110 3.08 3.215 19.44  1
#> Hornet Sportabout   18.7   8 360.0 175 3.15 3.440 17.02  0
#> Valiant             18.1   6 225.0 105 2.76 3.460 20.22  1
#> Duster 360          14.3   8 360.0 245 3.21 3.570 15.84  0
#> Merc 240D           24.4   4 146.7  62 3.69 3.190 20.00  1
#> Merc 230            22.8   4 140.8  95 3.92 3.150 22.90  1
#> Merc 280            19.2   6 167.6 123 3.92 3.440 18.30  1
#> Merc 280C           17.8   6 167.6 123 3.92 3.440 18.90  1
#> Merc 450SE          16.4   8 275.8 180 3.07 4.070 17.40  0
#> Merc 450SL          17.3   8 275.8 180 3.07 3.730 17.60  0
#> Merc 450SLC         15.2   8 275.8 180 3.07 3.780 18.00  0
#> Cadillac Fleetwood  10.4   8 472.0 205 2.93 5.250 17.98  0
#> Lincoln Continental 10.4   8 460.0 215 3.00 5.424 17.82  0
#> Chrysler Imperial   14.7   8 440.0 230 3.23 5.345 17.42  0
#> Fiat 128            32.4   4  78.7  66 4.08 2.200 19.47  1
#> Honda Civic         30.4   4  75.7  52 4.93 1.615 18.52  1
#> Toyota Corolla      33.9   4  71.1  65 4.22 1.835 19.90  1
#> Toyota Corona       21.5   4 120.1  97 3.70 2.465 20.01  1
#> Dodge Challenger    15.5   8 318.0 150 2.76 3.520 16.87  0
#> AMC Javelin         15.2   8 304.0 150 3.15 3.435 17.30  0
#> Camaro Z28          13.3   8 350.0 245 3.73 3.840 15.41  0
#> Pontiac Firebird    19.2   8 400.0 175 3.08 3.845 17.05  0
#> Fiat X1-9           27.3   4  79.0  66 4.08 1.935 18.90  1
#> Porsche 914-2       26.0   4 120.3  91 4.43 2.140 16.70  0
#> Lotus Europa        30.4   4  95.1 113 3.77 1.513 16.90  1
#> Ford Pantera L      15.8   8 351.0 264 4.22 3.170 14.50  0
#> Ferrari Dino        19.7   6 145.0 175 3.62 2.770 15.50  0
#> Maserati Bora       15.0   8 301.0 335 3.54 3.570 14.60  0
#> Volvo 142E          21.4   4 121.0 109 4.11 2.780 18.60  1
#>                     am gear carb
#> Mazda RX4            1    4    4
#> Mazda RX4 Wag        1    4    4
#> Datsun 710           1    4    1
#> Hornet 4 Drive       0    3    1
#> Hornet Sportabout    0    3    2
#> Valiant              0    3    1
#> Duster 360           0    3    4
#> Merc 240D            0    4    2
#> Merc 230             0    4    2
#> Merc 280             0    4    4
#> Merc 280C            0    4    4
#> Merc 450SE           0    3    3
#> Merc 450SL           0    3    3
#> Merc 450SLC          0    3    3
#> Cadillac Fleetwood   0    3    4
#> Lincoln Continental  0    3    4
#> Chrysler Imperial    0    3    4
#> Fiat 128             1    4    1
#> Honda Civic          1    4    2
#> Toyota Corolla       1    4    1
#> Toyota Corona        0    3    1
#> Dodge Challenger     0    3    2
#> AMC Javelin          0    3    2
#> Camaro Z28           0    3    4
#> Pontiac Firebird     0    3    2
#> Fiat X1-9            1    4    1
#> Porsche 914-2        1    5    2
#> Lotus Europa         1    5    2
#> Ford Pantera L       1    5    4
#> Ferrari Dino         1    5    6
#> Maserati Bora        1    5    8
#> Volvo 142E           1    4    2

cyl == 4
#> Error in eval(expr, envir, enclos): object 'cyl' not found
```

- `with(mtcars2, sum(vs))`

The argument `data` is evaluated, while `expr` argument is quoted.


```r
with(mtcars2, sum(vs))
#> [1] 10

mtcars2
#>                 mpg cyl  disp  hp drat    wt  qsec vs am
#> Datsun 710     22.8   4 108.0  93 3.85 2.320 18.61  1  1
#> Merc 240D      24.4   4 146.7  62 3.69 3.190 20.00  1  0
#> Merc 230       22.8   4 140.8  95 3.92 3.150 22.90  1  0
#> Fiat 128       32.4   4  78.7  66 4.08 2.200 19.47  1  1
#> Honda Civic    30.4   4  75.7  52 4.93 1.615 18.52  1  1
#> Toyota Corolla 33.9   4  71.1  65 4.22 1.835 19.90  1  1
#> Toyota Corona  21.5   4 120.1  97 3.70 2.465 20.01  1  0
#> Fiat X1-9      27.3   4  79.0  66 4.08 1.935 18.90  1  1
#> Porsche 914-2  26.0   4 120.3  91 4.43 2.140 16.70  0  1
#> Lotus Europa   30.4   4  95.1 113 3.77 1.513 16.90  1  1
#> Volvo 142E     21.4   4 121.0 109 4.11 2.780 18.60  1  1
#>                gear carb
#> Datsun 710        4    1
#> Merc 240D         4    2
#> Merc 230          4    2
#> Fiat 128          4    1
#> Honda Civic       4    2
#> Toyota Corolla    4    1
#> Toyota Corona     3    1
#> Fiat X1-9         4    1
#> Porsche 914-2     5    2
#> Lotus Europa      5    2
#> Volvo 142E        4    2

sum(vs)
#> Error in eval(expr, envir, enclos): object 'vs' not found
```

- `sum(mtcars2$am)`

The argument `...` is evaluated.


```r
sum(mtcars2$am)
#> [1] 8

mtcars2$am
#>  [1] 1 0 0 1 1 1 0 1 1 1 1
```

- `rm(mtcars2)`

The trick we are using so far won't work here since trying to print `mtcars2` will always fail after `rm()` has made a pass at it.


```r
rm(mtcars2)
```

We can instead look at the docs for `...`:

> ... the objects to be removed, as names (unquoted) or character strings (quoted).

Thus, this argument is not evaluated, but rather quoted.

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

**A2.** As seen in the answer for **Q1.**, `library()` quotes its first argument:


```r
library(dplyr)
library(ggplot2)
```

In the following code:

- `%>%` (lazily) evaluates its argument
- `group_by()` and `summarise()` quote their arguments


```r
by_cyl <- mtcars %>% 
  group_by(cyl) %>%
  summarise(mean = mean(mpg))
```

In the following code:

- `ggplot()` evaluates the `data` argument
- `aes()` quotes its arguments


```r
ggplot(by_cyl, aes(cyl, mean)) +
  geom_point()
```

<img src="Quotation_files/figure-html/unnamed-chunk-12-1.png" width="100%" />

### Exercises 19.3.6

**Q1.** How is `expr()` implemented? Look at its source code.

**A1.** Looking at the source code, we can see that `expr()` is a simple wrapper around `enexpr()`, and captures and returns the user-entered expressions:


```r
rlang::expr
#> function (expr) 
#> {
#>     enexpr(expr)
#> }
#> <bytecode: 0x104f1f400>
#> <environment: namespace:rlang>
```

For example:


```r
x <- expr(x <- 1)
x
#> x <- 1
```

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

**A2.** The `exprs()` captures and returns the expressions specified by the developer instead of their values:


```r
f1 <- function(x, y) {
  exprs(x = x, y = y)
}

f1(a + b, c + d)
#> $x
#> x
#> 
#> $y
#> y
```

On the other hand, `enexprs()` captures the user-entered expressions and returns their values:


```r
f2 <- function(x, y) {
  enexprs(x = x, y = y)
}

f2(a + b, c + d)
#> $x
#> a + b
#> 
#> $y
#> c + d
```

**Q3.** What happens if you try to use `enexpr()` with an expression (i.e. `enexpr(x + y)`? What happens if `enexpr()` is passed a missing argument?

**A3.** If you try to use `enexpr()` with an expression, it fails because it works only with types `symbol` and `character` (which is converted to `symbol`).


```r
enexpr(x + y)
#> Error in `enexpr()`:
#> ! `arg` must be a symbol
```

If `enexpr()` is passed a missing argument, it returns a missing argument:


```r
arg <- missing_arg()

enexpr(arg)

is_missing(enexpr(arg))
#> [1] TRUE
```

**Q4.** How are `exprs(a)` and `exprs(a = )` different? Think about both the input and the output.

**A4.** The key difference here is that the former will return an unnamed list, while the latter will return a named list. This is because the former is interpreted as an unnamed argument, while the latter a named argument.


```r
exprs(a)
#> [[1]]
#> a

exprs(a = )
#> $a
```

In both cases, `a` is treated as a symbol:


```r
purrr::map_lgl(exprs(a), is_symbol)
#>      
#> TRUE

purrr::map_lgl(exprs(a = ), is_symbol)
#>    a 
#> TRUE
```

But, the argument is missing only in the latter case, since only the name but no corresponding value is provided:


```r
purrr::map_lgl(exprs(a), is_missing)
#>       
#> FALSE

purrr::map_lgl(exprs(a = ), is_missing)
#>    a 
#> TRUE
```

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

**A1.** Using quasiquotation to construct the specified calls:


```r
xy <- expr(x + y)
xz <- expr(x + z)
yz <- expr(y + z)
abc <- exprs(a, b, c)

expr((!!xy) / (!! yz))
#> (x + y)/(y + z)

expr(-(!!xz) ^ (!!yz))
#> -(x + z)^(y + z)

expr(((!!xy)) + (!!yz) - (!!xy))
#> (x + y) + (y + z) - (x + y)

call2("atan2", expr(!!xy), expr(!!yz))
#> atan2(x + y, y + z)

call2("sum", expr(!!xy), expr(!!xy), expr(!!yz))
#> sum(x + y, x + y, y + z)

call2("sum", !!!abc)
#> sum(a, b, c)

expr(mean(c(!!!abc), na.rm = TRUE))
#> mean(c(a, b, c), na.rm = TRUE)

call2("foo", a = expr(!!xy), b = expr(!!yz))
#> foo(a = x + y, b = y + z)
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
