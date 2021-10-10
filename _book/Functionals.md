# Functionals

## Exercise 9.2.6 {-}

### Q1. Study `as_mapper()` {-}


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
#> <environment: 0x0000000012cf6368>

map(x, list(2, 1))
#> [[1]]
#> NULL
#> 
#> [[2]]
#> [1] 3
as_mapper(list(2, 1))
#> function (x, ...) 
#> pluck(x, 2, 1, .default = NULL)
#> <environment: 0x0000000012daf518>

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
#> <environment: 0x0000000012eba320>

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
#> <environment: 0x0000000012f66b18>

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

You can extract attributes using `purrr::attr_getter()`:


```r
pluck(Titanic, attr_getter("class"))
#> [1] "table"
```

### Q2. Properly specifying anonymous functions {-}

As shown by `as_mapper()` outputs below, the second call is not appropriate for generating random numbers because it translates to `pluck()` function where the indices for plucking are taken to be randomly generated numbers.


```r
library(purrr)

map(1:3, ~ runif(2))
#> [[1]]
#> [1] 0.5033113 0.8831831
#> 
#> [[2]]
#> [1] 0.6396661 0.1980272
#> 
#> [[3]]
#> [1] 0.8668740 0.4659268
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
#> pluck(x, 0.140431632753462, 0.824880666797981, .default = NULL)
#> <environment: 0x00000000136f5f78>
```

### Q3. Use the appropriate `map()` function {-}

Compute the standard deviation of every column in a numeric data frame.


```r
map_dbl(mtcars, sd)
#>         mpg         cyl        disp          hp        drat 
#>   6.0269481   1.7859216 123.9386938  68.5628685   0.5346787 
#>          wt        qsec          vs          am        gear 
#>   0.9784574   1.7869432   0.5040161   0.4989909   0.7378041 
#>        carb 
#>   1.6152000
```

Compute the standard deviation of every numeric column in a mixed data frame. 


```r
keep(iris, is.numeric) %>%
  map_dbl(sd)
#> Sepal.Length  Sepal.Width Petal.Length  Petal.Width 
#>    0.8280661    0.4358663    1.7652982    0.7622377
```

Compute the number of levels for every factor in a data frame.


```r
modify_if(dplyr::starwars, is.character, as.factor) %>%
  keep(is.factor) %>%
  map_int(~ length(levels(.)))
#>       name hair_color skin_color  eye_color        sex 
#>         87         12         31         15          4 
#>     gender  homeworld    species 
#>          2         48         37
```

### Q4. Statistics and visualization with `{purrr}` {-}

Extract the *p*-value from each test, then visualise.


```r
trials <- map(1:100, ~ t.test(rpois(10, 10), rpois(7, 10)))

p <- map_dbl(trials, "p.value")

plot(p)
```

<img src="Functionals_files/figure-html/unnamed-chunk-7-1.png" width="672" />

### Q5. Fixing non-functioning code {-}


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

### Q6. Use `map()` to fit linear models to the `mtcars` dataset {-}


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

### Q7. Computing R-squared {-}


```r
bootstrap <- function(df) {
  df[sample(nrow(df), replace = TRUE), , drop = FALSE]
}

bootstraps <- map(1:10, ~ bootstrap(mtcars))

map_dbl(
  bootstraps,
  ~ summary(lm(formula = mpg ~ disp, data = .))$r.squared
)
#>  [1] 0.7709812 0.5880121 0.7399332 0.8257437 0.7064241
#>  [6] 0.5695829 0.7289304 0.7578368 0.6953068 0.6120790
```

## Exercise 9.4.6 {-}

### Q1. Explain the results {-}

`modify()` returns the object of type same as the input. Since the input here is a dataframe of certain dimensions and `.f = 1` translates to plucking the first element in each column, it returns a dataframes with the same dimensions with the plucked element recycled across rows.


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

### Q2. Use `iwalk()` instead of `walk2()` {-}


```r
# with walk2() -----------------------

cyls <- split(mtcars, mtcars$cyl)
paths <- file.path(temp, paste0("cyl-", names(cyls), ".csv"))
walk2(.x = cyls, .y = paths, .f = write.csv)

# with iwalk --------------------------

cyls <- split(mtcars, mtcars$cyl)
names(cyls) <- file.path(temp, paste0("cyl-", names(cyls), ".csv"))
iwalk(cyls, ~ write.csv(.x, .y))
```

