# Functionals



## Exercise 9.2.6

**Q1.** Use `as_mapper()` to explore how `{purrr}` generates anonymous functions for the integer, character, and list helpers. What helper allows you to extract attributes? Read the documentation to find out.

**A1.**

- Experiments with `{purrr}`:


```r
library(purrr)

# mapping by position -----------------------

x <- list(1, list(2, 3, list(1, 2)))

map(x, 1)
#> [[1]]
#> [1] 1
#> 
#> [[2]]
#> [1] 2
as_mapper(1)
#> function (x, ...) 
#> pluck(x, 1, .default = NULL)
#> <environment: 0x000000001fcfdfb8>

map(x, list(2, 1))
#> [[1]]
#> NULL
#> 
#> [[2]]
#> [1] 3
as_mapper(list(2, 1))
#> function (x, ...) 
#> pluck(x, 2, 1, .default = NULL)
#> <environment: 0x000000001ff73848>

# mapping by name -----------------------

y <- list(
  list(m = "a", list(1, m = "mo")),
  list(n = "b", list(2, n = "no"))
)

map(y, "m")
#> [[1]]
#> [1] "a"
#> 
#> [[2]]
#> NULL
as_mapper("m")
#> function (x, ...) 
#> pluck(x, "m", .default = NULL)
#> <environment: 0x00000000202abce8>

# mixing position and name
map(y, list(2, "m"))
#> [[1]]
#> [1] "mo"
#> 
#> [[2]]
#> NULL
as_mapper(list(2, "m"))
#> function (x, ...) 
#> pluck(x, 2, "m", .default = NULL)
#> <environment: 0x000000002178f940>

# compact functions ----------------------------

map(y, ~ length(.x))
#> [[1]]
#> [1] 2
#> 
#> [[2]]
#> [1] 2
as_mapper(~ length(.x))
#> <lambda>
#> function (..., .x = ..1, .y = ..2, . = ..1) 
#> length(.x)
#> attr(,"class")
#> [1] "rlang_lambda_function" "function"
```

- You can extract attributes using `purrr::attr_getter()`:


```r
pluck(Titanic, attr_getter("class"))
#> [1] "table"
```

**Q2.** `map(1:3, ~ runif(2))` is a useful pattern for generating random numbers, but `map(1:3, runif(2))` is not. Why not? Can you explain why it returns the result that it does?

**A2.** 

As shown by `as_mapper()` outputs below, the second call is not appropriate for generating random numbers because it translates to `pluck()` function where the indices for plucking are taken to be randomly generated numbers.


```r
library(purrr)

map(1:3, ~ runif(2))
#> [[1]]
#> [1] 0.647805351 0.002043792
#> 
#> [[2]]
#> [1] 0.5644884 0.6899378
#> 
#> [[3]]
#> [1] 0.8824353 0.7136257
as_mapper(~ runif(2))
#> <lambda>
#> function (..., .x = ..1, .y = ..2, . = ..1) 
#> runif(2)
#> attr(,"class")
#> [1] "rlang_lambda_function" "function"

map(1:3, runif(2))
#> [[1]]
#> NULL
#> 
#> [[2]]
#> NULL
#> 
#> [[3]]
#> NULL
as_mapper(runif(2))
#> function (x, ...) 
#> pluck(x, 0.488565234933048, 0.282590016024187, .default = NULL)
#> <environment: 0x000000001fdf9830>
```

**Q3.** Use the appropriate `map()` function to:
    
    a) Compute the standard deviation of every column in a numeric data frame.

    a) Compute the standard deviation of every numeric column in a mixed data frame. (Hint: you'll need to do it in two steps.)

    a) Compute the number of levels for every factor in a data frame.

**A3.**

- Compute the standard deviation of every column in a numeric data frame:


```r
map_dbl(mtcars, sd)
#>         mpg         cyl        disp          hp        drat 
#>   6.0269481   1.7859216 123.9386938  68.5628685   0.5346787 
#>          wt        qsec          vs          am        gear 
#>   0.9784574   1.7869432   0.5040161   0.4989909   0.7378041 
#>        carb 
#>   1.6152000
```

- Compute the standard deviation of every numeric column in a mixed data frame:


```r
keep(iris, is.numeric) %>%
  map_dbl(sd)
#> Sepal.Length  Sepal.Width Petal.Length  Petal.Width 
#>    0.8280661    0.4358663    1.7652982    0.7622377
```

- Compute the number of levels for every factor in a data frame:


```r
modify_if(dplyr::starwars, is.character, as.factor) %>%
  keep(is.factor) %>%
  map_int(~ length(levels(.)))
#>       name hair_color skin_color  eye_color        sex 
#>         87         12         31         15          4 
#>     gender  homeworld    species 
#>          2         48         37
```

**Q4.** The following code simulates the performance of a *t*-test for non-normal data. Extract the *p*-value from each test, then visualise.


```r
trials <- map(1:100, ~ t.test(rpois(10, 10), rpois(7, 10)))
```

**A4.**

- Extract the *p*-value from each test:


```r
trials <- map(1:100, ~ t.test(rpois(10, 10), rpois(7, 10)))

(p <- map_dbl(trials, "p.value"))
#>   [1] 0.299971153 0.885656132 0.849705357 0.056676494
#>   [5] 0.394393273 0.736525502 0.804828295 0.468948769
#>   [9] 0.686015596 0.650053777 0.582390831 0.188410000
#>  [13] 0.900950044 0.273012054 0.970938031 0.304920193
#>  [17] 0.449001964 0.102450967 0.390957835 0.136883431
#>  [21] 0.660982014 0.122439418 0.093133656 0.727661904
#>  [25] 0.895080471 0.624895785 0.341671914 0.264785332
#>  [29] 0.735707127 0.112312893 0.441039382 1.000000000
#>  [33] 0.355426907 0.062549822 0.555917289 0.639464413
#>  [37] 0.006586251 0.633031198 0.647561764 0.537467178
#>  [41] 0.017158046 0.878423188 0.152574471 0.721141701
#>  [45] 0.208566128 0.040833492 0.007831456 0.797020213
#>  [49] 0.183921578 0.295253529 0.329881756 0.200029884
#>  [53] 0.268305809 0.424194863 0.274296962 0.729878485
#>  [57] 0.248290452 0.945859015 0.724685301 0.990775490
#>  [61] 0.227645554 0.397439640 0.227937355 0.451196286
#>  [65] 0.333827185 0.503555294 0.255475325 0.290271808
#>  [69] 0.624050855 0.469870344 0.758396401 0.410772925
#>  [73] 0.704272993 0.368755022 0.315412900 0.755285111
#>  [77] 0.073533607 0.855924386 0.948269115 0.049645144
#>  [81] 0.307038145 0.762683261 0.814836229 0.916515873
#>  [85] 0.604217643 0.252319342 0.501053478 0.031713667
#>  [89] 0.689218330 0.459138440 0.377097209 0.127690414
#>  [93] 0.361896716 0.294063220 0.850895113 0.060363348
#>  [97] 0.523671875 0.973473735 0.124535781 0.396329470
```

- Visualise the extracted *p*-values:


```r
plot(p)
```

<img src="Functionals_files/figure-html/unnamed-chunk-10-1.png" width="672" />

**Q5.** The following code uses a map nested inside another map to apply a function to every element of a nested list. Why does it fail, and  what do you need to do to make it work?


```r
x <- list(
  list(1, c(3, 9)),
  list(c(3, 6), 7, c(4, 7, 6))
)

triple <- function(x) x * 3
map(x, map, .f = triple)
#> Error in .f(.x[[i]], ...): unused argument (function (.x, .f, ...) 
#> {
#>     .f <- as_mapper(.f, ...)
#>     .Call(map_impl, environment(), ".x", ".f", "list")
#> })
```

**A5.** Here is the fixed version:


```r
x <- list(
  list(1, c(3, 9)),
  list(c(3, 6), 7, c(4, 7, 6))
)

triple <- function(x) x * 3
map(x, .f = ~ map(., ~ triple(.)))
#> [[1]]
#> [[1]][[1]]
#> [1] 3
#> 
#> [[1]][[2]]
#> [1]  9 27
#> 
#> 
#> [[2]]
#> [[2]][[1]]
#> [1]  9 18
#> 
#> [[2]][[2]]
#> [1] 21
#> 
#> [[2]][[3]]
#> [1] 12 21 18
```

**Q6.** Use `map()` to fit linear models to the `mtcars` dataset using the formulas stored in this list:


```r
formulas <- list(
  mpg ~ disp,
  mpg ~ I(1 / disp),
  mpg ~ disp + wt,
  mpg ~ I(1 / disp) + wt
)
```

**A6.** Fitting linear models to the `mtcars` dataset using the provided formulas:


```r
formulas <- list(
  mpg ~ disp,
  mpg ~ I(1 / disp),
  mpg ~ disp + wt,
  mpg ~ I(1 / disp) + wt
)

map(formulas, ~ lm(formula = ., data = mtcars))
#> [[1]]
#> 
#> Call:
#> lm(formula = ., data = mtcars)
#> 
#> Coefficients:
#> (Intercept)         disp  
#>    29.59985     -0.04122  
#> 
#> 
#> [[2]]
#> 
#> Call:
#> lm(formula = ., data = mtcars)
#> 
#> Coefficients:
#> (Intercept)    I(1/disp)  
#>       10.75      1557.67  
#> 
#> 
#> [[3]]
#> 
#> Call:
#> lm(formula = ., data = mtcars)
#> 
#> Coefficients:
#> (Intercept)         disp           wt  
#>    34.96055     -0.01772     -3.35083  
#> 
#> 
#> [[4]]
#> 
#> Call:
#> lm(formula = ., data = mtcars)
#> 
#> Coefficients:
#> (Intercept)    I(1/disp)           wt  
#>      19.024     1142.560       -1.798
```

**Q7.** Fit the model `mpg ~ disp` to each of the bootstrap replicates of `mtcars` in the list below, then extract the $R^2$ of the model fit (Hint: you can compute the $R^2$ with `summary()`.)


```r
bootstrap <- function(df) {
  df[sample(nrow(df), replace = TRUE), , drop = FALSE]
}

bootstraps <- map(1:10, ~ bootstrap(mtcars))
```

**A7.** This can be done using `map_dbl()`:


```r
bootstrap <- function(df) {
  df[sample(nrow(df), replace = TRUE), , drop = FALSE]
}

bootstraps <- map(1:10, ~ bootstrap(mtcars))

map_dbl(
  bootstraps,
  ~ summary(lm(formula = mpg ~ disp, data = .))$r.squared
)
#>  [1] 0.7398167 0.8035412 0.7980222 0.7626201 0.6347321
#>  [6] 0.7136730 0.7773232 0.6105269 0.7117854 0.7412714
```

## Exercise 9.4.6

**Q1.** Explain the results of `modify(mtcars, 1)`.

**A1.** `modify()` returns the object of type same as the input. Since the input here is a data frame of certain dimensions and `.f = 1` translates to plucking the first element in each column, it returns a data frames with the same dimensions with the plucked element recycled across rows.


```r
head(modify(mtcars, 1))
#>                   mpg cyl disp  hp drat   wt  qsec vs am
#> Mazda RX4          21   6  160 110  3.9 2.62 16.46  0  1
#> Mazda RX4 Wag      21   6  160 110  3.9 2.62 16.46  0  1
#> Datsun 710         21   6  160 110  3.9 2.62 16.46  0  1
#> Hornet 4 Drive     21   6  160 110  3.9 2.62 16.46  0  1
#> Hornet Sportabout  21   6  160 110  3.9 2.62 16.46  0  1
#> Valiant            21   6  160 110  3.9 2.62 16.46  0  1
#>                   gear carb
#> Mazda RX4            4    4
#> Mazda RX4 Wag        4    4
#> Datsun 710           4    4
#> Hornet 4 Drive       4    4
#> Hornet Sportabout    4    4
#> Valiant              4    4
```

**Q2.** Rewrite the following code to use `iwalk()` instead of `walk2()`. What are the advantages and disadvantages?


```r
cyls <- split(mtcars, mtcars$cyl)
paths <- file.path(temp, paste0("cyl-", names(cyls), ".csv"))
walk2(cyls, paths, write.csv)
```

**A2.** Rewritten versions are below:

- with `walk2()`


```r
cyls <- split(mtcars, mtcars$cyl)
paths <- file.path(temp, paste0("cyl-", names(cyls), ".csv"))
walk2(.x = cyls, .y = paths, .f = write.csv)
```

- with `iwalk()`


```r
cyls <- split(mtcars, mtcars$cyl)
names(cyls) <- file.path(temp, paste0("cyl-", names(cyls), ".csv"))
iwalk(cyls, ~ write.csv(.x, .y))
```

**Q3.** Explain how the following code transforms a data frame using functions stored in a list.


```r
trans <- list(
  disp = function(x) x * 0.0163871,
  am = function(x) factor(x, labels = c("auto", "manual"))
)

nm <- names(trans)
mtcars[nm] <- map2(trans, mtcars[nm], function(f, var) f(var))
```
    
Compare and contrast the `map2()` approach to this `map()` approach:
    

```r
mtcars[nm] <- map(nm, ~ trans[[.x]](mtcars[[.x]]))
```

**A3.** `map2()` supplies the functions defined in `.x = trans` as `f` in the anonymous functions, while the names of the columns defined in  `.y = mtcars[nm]` are picked up by `var` in the anonymous function. Note that the function is iterating over indices for vectors of transformations and column names.


```r
trans <- list(
  disp = function(x) x * 0.0163871,
  am = function(x) factor(x, labels = c("auto", "manual"))
)

nm <- names(trans)
mtcars[nm] <- map2(trans, mtcars[nm], function(f, var) f(var))
```

In the `map()` approach, the function is iterating over indices for vectors of column names.


```r
mtcars[nm] <- map(nm, ~ trans[[.x]](mtcars[[.x]]))
```

**Q4.** What does `write.csv()` return, i.e. what happens if you use it with `map2()` instead of `walk2()`?

**A4.** If we use `map2()`, it will work, but it will print `NULL`s to the terminal for every list element.


```r
bods <- split(BOD, BOD$Time)
nm <- names(bods)
map2(bods, nm, write.csv)
```

## Exercise 9.6.3

**Q1.** Why isn't `is.na()` a predicate function? What base R function is closest to being a predicate version of `is.na()`?

**A1.** As mentioned in the docs:

> A predicate is a function that returns a **single** `TRUE` or `FALSE`.

The `is.na()` function does not return a `logical` scalar, but instead returns a vector and thus isn't a predicate function.


```r
# contrast the following behavior of predicate functions
is.character(c("x", 2))
#> [1] TRUE
is.null(c(3, NULL))
#> [1] FALSE

# with this behavior
is.na(c(NA, 1))
#> [1]  TRUE FALSE
```

The closest equivalent of a predicate function in base-R is `anyNA()` function.


```r
anyNA(c(NA, 1))
#> [1] TRUE
```

**Q2.** `simple_reduce()` has a problem when `x` is length 0 or length 1. Describe the source of the problem and how you might go about fixing it.


```r
simple_reduce <- function(x, f) {
  out <- x[[1]]
  for (i in seq(2, length(x))) {
    out <- f(out, x[[i]])
  }
  out
}
```

**A2.**  Supplied function:


```r
simple_reduce <- function(x, f) {
  out <- x[[1]]
  for (i in seq(2, length(x))) {
    out <- f(out, x[[i]])
  }
  out
}
```

This function struggles with inputs of length 0 and 1 because function tries to access out-of-bound values.


```r
simple_reduce(numeric(), sum)
#> Error in x[[1]]: subscript out of bounds
simple_reduce(1, sum)
#> Error in x[[i]]: subscript out of bounds
simple_reduce(1:3, sum)
#> [1] 6
```

This problem can be solved by adding `init` argument, which supplies the default or initial value for the function to operate on:


```r
simple_reduce2 <- function(x, f, init = 0) {
  # initializer will become the first value
  if (length(x) == 0L) {
    return(init)
  }

  if (length(x) == 1L) {
    return(x[[1L]])
  }

  out <- x[[1]]

  for (i in seq(2, length(x))) {
    out <- f(out, x[[i]])
  }
  out
}
```

Let's try it out:


```r
simple_reduce2(numeric(), sum)
#> [1] 0
simple_reduce2(1, sum)
#> [1] 1
simple_reduce2(1:3, sum)
#> [1] 6
```

With a different kind of function:


```r
simple_reduce2(numeric(), `*`, init = 1)
#> [1] 1
simple_reduce2(1, `*`, init = 1)
#> [1] 1
simple_reduce2(1:3, `*`, init = 1)
#> [1] 6
```

And another one:


```r
simple_reduce2(numeric(), `%/%`)
#> [1] 0
simple_reduce2(1, `%/%`)
#> [1] 1
simple_reduce2(1:3, `%/%`)
#> [1] 0
```

**Q3.** Implement the `span()` function from Haskell: given a list `x` and a predicate function `f`, `span(x, f)` returns the location of the longest sequential run of elements where the predicate is true. (Hint: you might find `rle()` helpful.)

**Q4.**  Implement `arg_max()`. It should take a function and a vector of inputs, and return the elements of the input where the function returns the highest value. For example, `arg_max(-10:5, function(x) x ^ 2)` should return -10. `arg_max(-5:5, function(x) x ^ 2)` should return `c(-5, 5)`. Also implement the matching `arg_min()` function.

**Q5.**  The function below scales a vector so it falls in the range [0, 1]. How would you apply it to every column of a data frame? How would you apply it to every numeric column in a data frame?


```r
scale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
```

## Exercise 9.7.3

**Q1.** How does `apply()` arrange the output? Read the documentation and perform some experiments.

**Q2.** What do `eapply()` and `rapply()` do? Does purrr have equivalents?

**A2.** As mentioned in the documentation:

- `eapply()` 

> `eapply()` applies FUN to the named values from an environment and returns the results as a list.

Here is an example:


```r
library(rlang)
#> 
#> Attaching package: 'rlang'
#> The following objects are masked from 'package:purrr':
#> 
#>     %@%, as_function, flatten, flatten_chr,
#>     flatten_dbl, flatten_int, flatten_lgl,
#>     flatten_raw, invoke, splice

e <- env("x" = 1, "y" = 2)
rlang::env_print(e)
#> <environment: 0x0000000034f26868>
#> Parent: <environment: global>
#> Bindings:
#> * x: <dbl>
#> * y: <dbl>

eapply(e, as.character)
#> $x
#> [1] "1"
#> 
#> $y
#> [1] "2"
```

`{purrr}` doesn't have any function to iterate over environments.

- `rapply()` 

> `rapply()` is a recursive version of lapply with flexibility in how the result is structured (how = "..").

Here is an example:


```r
X <- list(list(a = TRUE, b = list(c = c(4L, 3.2))), d = 9.0)

rapply(X, as.character, classes = "numeric", how = "replace")
#> [[1]]
#> [[1]]$a
#> [1] TRUE
#> 
#> [[1]]$b
#> [[1]]$b$c
#> [1] "4"   "3.2"
#> 
#> 
#> 
#> $d
#> [1] "9"
```

`{purrr}` has something similar in `modify_depth()`.


```r
X <- list(list(a = TRUE, b = list(c = c(4L, 3.2))), d = 9.0)

purrr::modify_depth(X, .depth = 2L, .f = length)
#> [[1]]
#> [[1]]$a
#> [1] 1
#> 
#> [[1]]$b
#> [1] 1
#> 
#> 
#> $d
#> [1] 1
```

**Q3.**  Challenge: read about the [fixed point algorithm](https://mitpress.mit.edu/sites/default/files/sicp/full-text/book/book-Z-H-12.html#%25_idx_1096). Complete the exercises using R.
