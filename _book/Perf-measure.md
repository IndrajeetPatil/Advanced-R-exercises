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

**A1.** Let's source the functions mentioned in exercises.


```r
source("profiling-exercises.R")
```

First, we try without `torture = TRUE`: it returns no meaningful results. 


```r
profvis(f())
#> Error in parse_rprof(prof_output, expr_source): No parsing data available. Maybe your function was too fast?
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
#> <bytecode: 0x11b929198>
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

**A1.** Let's benchmark first using these two approaches:


```r
n <- 1e6
x <- runif(100)

# bench -------------------

bench_df <- bench::mark(
  sqrt(x),
  x^0.5,
  iterations = n,
  time_unit = "us"
)

t_bench_df <- bench_df %>%
  select(expression, time) %>%
  rowwise() %>%
  mutate(bench_mean = mean(unlist(time))) %>%
  ungroup() %>%
  select(-time)

# system.time -------------------

# garbage collection performed immediately before the timing
t1_systime_gc <- system.time(for (i in 1:n) sqrt(x), gcFirst = TRUE) / n
t2_systime_gc <- system.time(for (i in 1:n) x^0.5, gcFirst = TRUE) / n

# garbage collection not performed immediately before the timing
t1_systime_nogc <- system.time(for (i in 1:n) sqrt(x), gcFirst = FALSE) / n
t2_systime_nogc <- system.time(for (i in 1:n) x^0.5, gcFirst = FALSE) / n

t_systime_df <- tibble(
  "expression" = bench_df$expression,
  "systime_with_gc" = c(t1_systime_gc["elapsed"], t2_systime_gc["elapsed"]),
  "systime_with_nogc" = c(t1_systime_nogc["elapsed"], t2_systime_nogc["elapsed"])
) %>%
  mutate(
    systime_with_gc = systime_with_gc * 1e6, # in microseconds
    systime_with_nogc = systime_with_nogc * 1e6 # in microseconds
  )
```

Now we can compare results from these alternatives:


```r
# note that system time columns report time in microseconds
full_join(t_bench_df, t_systime_df, by = "expression")
#> # A tibble: 2 × 4
#>   expression bench_mean systime_with_gc systime_with_nogc
#>   <bch:expr>   <bch:tm>           <dbl>             <dbl>
#> 1 sqrt(x)       749.5ns           0.703             0.726
#> 2 x^0.5          3.12µs           2.58              2.86
```

The comparison reveals that these two approaches yield quite similar results. Slight differences in exact values is possibly due to differences in the precision of timers used internally by these functions.

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
  select(expression, median) %>%
  arrange(median)
#> # A tibble: 4 × 2
#>   expression      median
#>   <bch:expr>    <bch:tm>
#> 1 sqrt(x)         2.87µs
#> 2 exp(log(x)/2)  13.16µs
#> 3 x^0.5          15.62µs
#> 4 x^(1/2)         16.4µs
```

The specialized primitive function `sqrt()` (written in `C`) is the fastest way to compute square root.

---

## Session information


```r
sessioninfo::session_info(include_base = TRUE)
#> ─ Session info ───────────────────────────────────────────
#>  setting  value
#>  version  R version 4.2.2 (2022-10-31)
#>  os       macOS Ventura 13.0
#>  system   aarch64, darwin20
#>  ui       X11
#>  language (EN)
#>  collate  en_US.UTF-8
#>  ctype    en_US.UTF-8
#>  tz       Europe/Berlin
#>  date     2022-11-12
#>  pandoc   2.19.2 @ /Applications/RStudio.app/Contents/MacOS/quarto/bin/tools/ (via rmarkdown)
#> 
#> ─ Packages ───────────────────────────────────────────────
#>  ! package     * version    date (UTC) lib source
#>    assertthat    0.2.1      2019-03-21 [1] CRAN (R 4.2.0)
#>    base        * 4.2.2      2022-10-31 [?] local
#>    bench         1.1.2      2021-11-30 [1] CRAN (R 4.2.0)
#>    bookdown      0.30       2022-11-09 [1] CRAN (R 4.2.2)
#>    bslib         0.4.1      2022-11-02 [1] CRAN (R 4.2.2)
#>    cachem        1.0.6      2021-08-19 [1] CRAN (R 4.2.0)
#>    cli           3.4.1      2022-09-23 [1] CRAN (R 4.2.0)
#>  P compiler      4.2.2      2022-10-31 [1] local
#>  P datasets    * 4.2.2      2022-10-31 [1] local
#>    DBI           1.1.3.9002 2022-10-17 [1] Github (r-dbi/DBI@2aec388)
#>    digest        0.6.30     2022-10-18 [1] CRAN (R 4.2.1)
#>    downlit       0.4.2      2022-07-05 [1] CRAN (R 4.2.1)
#>    dplyr       * 1.0.10     2022-09-01 [1] CRAN (R 4.2.1)
#>    evaluate      0.18       2022-11-07 [1] CRAN (R 4.2.2)
#>    fansi         1.0.3      2022-03-24 [1] CRAN (R 4.2.0)
#>    fastmap       1.1.0      2021-01-25 [1] CRAN (R 4.2.0)
#>    fs            1.5.2      2021-12-08 [1] CRAN (R 4.2.0)
#>    generics      0.1.3      2022-07-05 [1] CRAN (R 4.2.1)
#>    glue          1.6.2      2022-02-24 [1] CRAN (R 4.2.0)
#>  P graphics    * 4.2.2      2022-10-31 [1] local
#>  P grDevices   * 4.2.2      2022-10-31 [1] local
#>    htmltools     0.5.3      2022-07-18 [1] CRAN (R 4.2.1)
#>    htmlwidgets   1.5.4      2021-09-08 [1] CRAN (R 4.2.0)
#>    jquerylib     0.1.4      2021-04-26 [1] CRAN (R 4.2.0)
#>    jsonlite      1.8.3      2022-10-21 [1] CRAN (R 4.2.1)
#>    knitr         1.40       2022-08-24 [1] CRAN (R 4.2.1)
#>    lifecycle     1.0.3      2022-10-07 [1] CRAN (R 4.2.1)
#>    magrittr    * 2.0.3      2022-03-30 [1] CRAN (R 4.2.0)
#>    memoise       2.0.1      2021-11-26 [1] CRAN (R 4.2.0)
#>  P methods     * 4.2.2      2022-10-31 [1] local
#>    pillar        1.8.1      2022-08-19 [1] CRAN (R 4.2.1)
#>    pkgconfig     2.0.3      2019-09-22 [1] CRAN (R 4.2.0)
#>    profmem       0.6.0      2020-12-13 [1] CRAN (R 4.2.0)
#>    profvis     * 0.3.7      2020-11-02 [1] CRAN (R 4.2.0)
#>    R6            2.5.1.9000 2022-10-27 [1] local
#>    rlang         1.0.6      2022-09-24 [1] CRAN (R 4.2.1)
#>    rmarkdown     2.18       2022-11-09 [1] CRAN (R 4.2.2)
#>    rstudioapi    0.14       2022-08-22 [1] CRAN (R 4.2.1)
#>    sass          0.4.2      2022-07-16 [1] CRAN (R 4.2.1)
#>    sessioninfo   1.2.2      2021-12-06 [1] CRAN (R 4.2.0)
#>  P stats       * 4.2.2      2022-10-31 [1] local
#>    stringi       1.7.8      2022-07-11 [1] CRAN (R 4.2.1)
#>    stringr       1.4.1      2022-08-20 [1] CRAN (R 4.2.1)
#>    tibble        3.1.8.9002 2022-10-16 [1] local
#>    tidyselect    1.2.0      2022-10-10 [1] CRAN (R 4.2.1)
#>  P tools         4.2.2      2022-10-31 [1] local
#>    utf8          1.2.2      2021-07-24 [1] CRAN (R 4.2.0)
#>  P utils       * 4.2.2      2022-10-31 [1] local
#>    vctrs         0.5.0      2022-10-22 [1] CRAN (R 4.2.1)
#>    withr         2.5.0      2022-03-03 [1] CRAN (R 4.2.0)
#>    xfun          0.34       2022-10-18 [1] CRAN (R 4.2.1)
#>    xml2          1.3.3.9000 2022-10-10 [1] local
#>    yaml          2.3.6      2022-10-18 [1] CRAN (R 4.2.1)
#> 
#>  [1] /Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library
#> 
#>  P ── Loaded and on-disk path mismatch.
#> 
#> ──────────────────────────────────────────────────────────
```
