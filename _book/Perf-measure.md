# Measuring performance



Attaching the needed libraries:


```r
library(profvis, warn.conflicts = FALSE)
library(dplyr, warn.conflicts = FALSE)
```

## Profiling (Exercises 23.2.4)

---

**Q1.** Profile the following function with `torture = TRUE`. What is surprising? Read the source code of `rm()` to figure out what's going on.


```r
f <- function(n = 1e5) {
  x <- rep(1, n)
  rm(x)
}
```

**A1.** Let's first source the functions mentioned in exercises.


```r
source("profiling-exercises.R")
```

First, we try without `torture = TRUE`: it returns no meaningful results. 


```r
profvis(f())
#> Error in parse_rprof(prof_output, expr_source): No parsing data available. Maybe your function was too fast?
```

Maybe because the function runs too fast?


```r
bench::mark(f(), check = FALSE, iterations = 1000)
#> # A tibble: 1 x 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f()           199us    284us     3489.     801KB     49.5
```

As mentioned in the docs, setting `torture = TRUE`

> Triggers garbage collection after every torture memory allocation call.

This process somehow never seems to finish and crashes the RStudio session when it stops!


```r
profvis(f(), torture = TRUE)
```

The question says that documentation for `rm()` may provide clues:


```r
rm
#> function (..., list = character(), pos = -1, envir = as.environment(pos), 
#>     inherits = FALSE) 
#> {
#>     dots <- match.call(expand.dots = FALSE)$...
#>     if (length(dots) && !all(vapply(dots, function(x) is.symbol(x) || 
#>         is.character(x), NA, USE.NAMES = FALSE))) 
#>         stop("... must contain names or character strings")
#>     names <- vapply(dots, as.character, "")
#>     if (length(names) == 0L) 
#>         names <- character()
#>     list <- .Primitive("c")(list, names)
#>     .Internal(remove(list, envir, inherits))
#> }
#> <bytecode: 0x00000000172a15e0>
#> <environment: namespace:base>
```

I still couldn't figure out why. I would recommend checking out the [official answer](https://advanced-r-solutions.rbind.io/measuring-performance.html#profiling).

---

## Microbenchmarking (Exercises 23.3.3)

---

**Q1.** Instead of using `bench::mark()`, you could use the built-in function `system.time()`. But `system.time()` is much less precise, so you'll need to repeat each operation many times with a loop, and then divide to find the average time of each operation, as in the code below.


```r
n <- 1e6
system.time(for (i in 1:n) sqrt(x)) / n
system.time(for (i in 1:n) x^0.5) / n
```

How do the estimates from `system.time()` compare to those from `bench::mark()`? Why are they different?

**A1.** Let's benchmark first:


```r
n <- 1e6
x <- runif(100)

# bench -------------------

bench_df <- bench::mark(
  sqrt(x),
  x^0.5,
  iterations = n
)

t_bench_df <- bench_df %>%
  dplyr::select(expression, time) %>%
  dplyr::rowwise() %>%
  dplyr::mutate(mean = mean(unlist(time))) %>%
  dplyr::ungroup() %>%
  dplyr::select(-time)

# system.time -------------------

# garbage collection performed immediately before the timing
t1_systime_gc <- system.time(for (i in 1:n) sqrt(x), gcFirst = TRUE) / n
t2_systime_gc <- system.time(for (i in 1:n) x^0.5, gcFirst = TRUE) / n

# garbage collection not performed immediately before the timing
t1_systime_nogc <- system.time(for (i in 1:n) sqrt(x), gcFirst = FALSE) / n
t2_systime_nogc <- system.time(for (i in 1:n) x^0.5, gcFirst = FALSE) / n

t_systime_df <- tibble(
  "expression" = bench_df$expression,
  "systime_with_gc_us" = c(t1_systime_gc["elapsed"], t2_systime_gc["elapsed"]),
  "systime_with_nogc_us" = c(t1_systime_nogc["elapsed"], t2_systime_nogc["elapsed"])
) %>%
  dplyr::mutate(
    systime_with_gc_us = systime_with_gc_us * 1e6,
    systime_with_nogc_us = systime_with_nogc_us * 1e6
  )
```

Compare results from these alternatives:


```r
t_bench_df
#> # A tibble: 2 x 2
#>   expression     mean
#>   <bch:expr> <bch:tm>
#> 1 sqrt(x)      1.06us
#> 2 x^0.5        3.64us

t_systime_df
#> # A tibble: 2 x 3
#>   expression systime_with_gc_us systime_with_nogc_us
#>   <bch:expr>              <dbl>                <dbl>
#> 1 sqrt(x)                  0.98                0.640
#> 2 x^0.5                    3.42                3.36
```

The comparison reveals that these two approaches yield quite similar results.

---

**Q2.** Here are two other ways to compute the square root of a vector. Which do you think will be fastest? Which will be slowest? Use microbenchmarking to test your answers.


```r
x^(1 / 2)
exp(log(x) / 2)
```

---

**A2.** Microbenchmarking all ways to compute square root of a vector mentioned in this chapter.


```r
x <- runif(1000)

bench::mark(
  sqrt(x),
  x^0.5,
  x^(1 / 2),
  exp(log(x) / 2),
  iterations = 1000
) %>%
  dplyr::arrange(median)
#> # A tibble: 4 x 6
#>   expression         min   median `itr/sec` mem_alloc
#>   <bch:expr>    <bch:tm> <bch:tm>     <dbl> <bch:byt>
#> 1 sqrt(x)          4.5us      5us   152987.    7.86KB
#> 2 x^(1/2)         25.2us   29.4us    28902.    7.86KB
#> 3 x^0.5           27.5us     30us    32539.    7.86KB
#> 4 exp(log(x)/2)   77.4us   96.6us    10477.    7.86KB
#>   `gc/sec`
#>      <dbl>
#> 1        0
#> 2        0
#> 3        0
#> 4        0
```

The specialized primitive function `sqrt()` (written in `C`) is the fastest way to compute square root.

---

## Session information


```r
sessioninfo::session_info(include_base = TRUE)
#> - Session info -------------------------------------------
#>  setting  value
#>  version  R version 4.1.3 (2022-03-10)
#>  os       Windows 10 x64 (build 22000)
#>  system   x86_64, mingw32
#>  ui       RTerm
#>  language (EN)
#>  collate  English_United Kingdom.1252
#>  ctype    English_United Kingdom.1252
#>  tz       Europe/Berlin
#>  date     2022-08-29
#>  pandoc   2.19 @ C:/PROGRA~1/Pandoc/ (via rmarkdown)
#> 
#> - Packages -----------------------------------------------
#>  ! package     * version    date (UTC) lib source
#>    assertthat    0.2.1      2019-03-21 [1] CRAN (R 4.1.1)
#>    base        * 4.1.3      2022-03-10 [?] local
#>    bench         1.1.2      2021-11-30 [1] CRAN (R 4.1.2)
#>    bookdown      0.28       2022-08-09 [1] CRAN (R 4.1.3)
#>    bslib         0.4.0      2022-07-16 [1] CRAN (R 4.1.3)
#>    cachem        1.0.6      2021-08-19 [1] CRAN (R 4.1.1)
#>    cli           3.3.0      2022-04-25 [1] CRAN (R 4.1.3)
#>  P compiler      4.1.3      2022-03-10 [2] local
#>  P datasets    * 4.1.3      2022-03-10 [2] local
#>    DBI           1.1.3      2022-06-18 [1] CRAN (R 4.1.3)
#>    digest        0.6.29     2021-12-01 [1] CRAN (R 4.1.2)
#>    downlit       0.4.2      2022-07-05 [1] CRAN (R 4.1.3)
#>    dplyr       * 1.0.9      2022-04-28 [1] CRAN (R 4.1.3)
#>    ellipsis      0.3.2      2021-04-29 [1] CRAN (R 4.1.0)
#>    evaluate      0.16       2022-08-09 [1] CRAN (R 4.1.3)
#>    fansi         1.0.3      2022-03-24 [1] CRAN (R 4.1.3)
#>    fastmap       1.1.0      2021-01-25 [1] CRAN (R 4.1.1)
#>    fs            1.5.2      2021-12-08 [1] CRAN (R 4.1.2)
#>    generics      0.1.3      2022-07-05 [1] CRAN (R 4.1.3)
#>    glue          1.6.2      2022-02-24 [1] CRAN (R 4.1.2)
#>  P graphics    * 4.1.3      2022-03-10 [2] local
#>  P grDevices   * 4.1.3      2022-03-10 [2] local
#>    htmltools     0.5.3      2022-07-18 [1] CRAN (R 4.1.3)
#>    htmlwidgets   1.5.4      2021-09-08 [1] CRAN (R 4.1.1)
#>    jquerylib     0.1.4      2021-04-26 [1] CRAN (R 4.1.1)
#>    jsonlite      1.8.0      2022-02-22 [1] CRAN (R 4.1.2)
#>    knitr         1.40       2022-08-24 [1] CRAN (R 4.1.3)
#>    lifecycle     1.0.1      2021-09-24 [1] CRAN (R 4.1.1)
#>    magrittr    * 2.0.3      2022-03-30 [1] CRAN (R 4.1.3)
#>    memoise       2.0.1      2021-11-26 [1] CRAN (R 4.1.2)
#>  P methods     * 4.1.3      2022-03-10 [2] local
#>    pillar        1.8.1      2022-08-19 [1] CRAN (R 4.1.3)
#>    pkgconfig     2.0.3      2019-09-22 [1] CRAN (R 4.1.1)
#>    profmem       0.6.0      2020-12-13 [1] CRAN (R 4.1.1)
#>    profvis     * 0.3.7      2020-11-02 [1] CRAN (R 4.1.2)
#>    purrr         0.3.4      2020-04-17 [1] CRAN (R 4.1.1)
#>    R6            2.5.1.9000 2022-08-04 [1] Github (r-lib/R6@87d5e45)
#>    rlang         1.0.4      2022-07-12 [1] CRAN (R 4.1.3)
#>    rmarkdown     2.16       2022-08-24 [1] CRAN (R 4.1.3)
#>    rstudioapi    0.14       2022-08-22 [1] CRAN (R 4.1.3)
#>    sass          0.4.2      2022-07-16 [1] CRAN (R 4.1.3)
#>    sessioninfo   1.2.2      2021-12-06 [1] CRAN (R 4.1.2)
#>  P stats       * 4.1.3      2022-03-10 [2] local
#>    stringi       1.7.8      2022-07-11 [1] CRAN (R 4.1.3)
#>    stringr       1.4.1      2022-08-20 [1] CRAN (R 4.1.3)
#>    tibble        3.1.8      2022-07-22 [1] CRAN (R 4.1.3)
#>    tidyselect    1.1.2      2022-02-21 [1] CRAN (R 4.1.2)
#>  P tools         4.1.3      2022-03-10 [2] local
#>    utf8          1.2.2      2021-07-24 [1] CRAN (R 4.1.1)
#>  P utils       * 4.1.3      2022-03-10 [2] local
#>    vctrs         0.4.1      2022-04-13 [1] CRAN (R 4.1.3)
#>    withr         2.5.0      2022-03-03 [1] CRAN (R 4.1.2)
#>    xfun          0.32       2022-08-10 [1] CRAN (R 4.1.3)
#>    xml2          1.3.3      2021-11-30 [1] CRAN (R 4.1.2)
#>    yaml          2.3.5      2022-02-21 [1] CRAN (R 4.1.2)
#> 
#>  [1] C:/Users/IndrajeetPatil/Documents/R/win-library/4.1
#>  [2] C:/Program Files/R/R-4.1.3/library
#> 
#>  P -- Loaded and on-disk path mismatch.
#> 
#> ----------------------------------------------------------
```
