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
#> Error in parse_rprof_lines(lines, expr_source): No parsing data available. Maybe your function was too fast?
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
#>     if (...length()) {
#>         dots <- match.call(expand.dots = FALSE)$...
#>         if (!all(vapply(dots, function(x) is.symbol(x) || is.character(x), 
#>             NA, USE.NAMES = FALSE))) 
#>             stop("... must contain names or character strings")
#>         list <- .Primitive("c")(list, vapply(dots, as.character, 
#>             ""))
#>     }
#>     .Internal(remove(list, envir, inherits))
#> }
#> <bytecode: 0x55b7a84b5ed8>
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
#> 1 sqrt(x)      833.99ns            0.68             0.433
#> 2 x^0.5          2.17µs            2.02             2
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
#> 1 sqrt(x)         3.12µs
#> 2 exp(log(x)/2)  12.59µs
#> 3 x^0.5          18.86µs
#> 4 x^(1/2)           19µs
```

The specialized primitive function `sqrt()` (written in `C`) is the fastest way to compute square root.

---

## Session information


```r
sessioninfo::session_info(include_base = TRUE)
#> ─ Session info ───────────────────────────────────────────
#>  setting  value
#>  version  R version 4.3.2 (2023-10-31)
#>  os       Ubuntu 22.04.3 LTS
#>  system   x86_64, linux-gnu
#>  ui       X11
#>  language (EN)
#>  collate  C.UTF-8
#>  ctype    C.UTF-8
#>  tz       UTC
#>  date     2024-02-18
#>  pandoc   3.1.8 @ /usr/bin/ (via rmarkdown)
#> 
#> ─ Packages ───────────────────────────────────────────────
#>  package     * version date (UTC) lib source
#>  base        * 4.3.2   2023-11-01 [3] local
#>  bench         1.1.3   2023-05-04 [1] RSPM
#>  bookdown      0.37    2023-12-01 [1] RSPM
#>  bslib         0.6.1   2023-11-28 [1] RSPM
#>  cachem        1.0.8   2023-05-01 [1] RSPM
#>  cli           3.6.2   2023-12-11 [1] RSPM
#>  compiler      4.3.2   2023-11-01 [3] local
#>  datasets    * 4.3.2   2023-11-01 [3] local
#>  digest        0.6.34  2024-01-11 [1] RSPM
#>  downlit       0.4.3   2023-06-29 [1] RSPM
#>  dplyr       * 1.1.4   2023-11-17 [1] RSPM
#>  evaluate      0.23    2023-11-01 [1] RSPM
#>  fansi         1.0.6   2023-12-08 [1] RSPM
#>  fastmap       1.1.1   2023-02-24 [1] RSPM
#>  fs            1.6.3   2023-07-20 [1] RSPM
#>  generics      0.1.3   2022-07-05 [1] RSPM
#>  glue          1.7.0   2024-01-09 [1] RSPM
#>  graphics    * 4.3.2   2023-11-01 [3] local
#>  grDevices   * 4.3.2   2023-11-01 [3] local
#>  htmltools     0.5.7   2023-11-03 [1] RSPM
#>  htmlwidgets   1.6.4   2023-12-06 [1] RSPM
#>  jquerylib     0.1.4   2021-04-26 [1] RSPM
#>  jsonlite      1.8.8   2023-12-04 [1] RSPM
#>  knitr         1.45    2023-10-30 [1] RSPM
#>  lifecycle     1.0.4   2023-11-07 [1] RSPM
#>  magrittr    * 2.0.3   2022-03-30 [1] RSPM
#>  memoise       2.0.1   2021-11-26 [1] RSPM
#>  methods     * 4.3.2   2023-11-01 [3] local
#>  pillar        1.9.0   2023-03-22 [1] RSPM
#>  pkgconfig     2.0.3   2019-09-22 [1] RSPM
#>  profmem       0.6.0   2020-12-13 [1] RSPM
#>  profvis     * 0.3.8   2023-05-02 [1] RSPM
#>  purrr         1.0.2   2023-08-10 [1] RSPM
#>  R6            2.5.1   2021-08-19 [1] RSPM
#>  rlang         1.1.3   2024-01-10 [1] RSPM
#>  rmarkdown     2.25    2023-09-18 [1] RSPM
#>  sass          0.4.8   2023-12-06 [1] RSPM
#>  sessioninfo   1.2.2   2021-12-06 [1] RSPM
#>  stats       * 4.3.2   2023-11-01 [3] local
#>  stringi       1.8.3   2023-12-11 [1] RSPM
#>  stringr       1.5.1   2023-11-14 [1] RSPM
#>  tibble        3.2.1   2023-03-20 [1] RSPM
#>  tidyselect    1.2.0   2022-10-10 [1] RSPM
#>  tools         4.3.2   2023-11-01 [3] local
#>  utf8          1.2.4   2023-10-22 [1] RSPM
#>  utils       * 4.3.2   2023-11-01 [3] local
#>  vctrs         0.6.5   2023-12-01 [1] RSPM
#>  withr         3.0.0   2024-01-16 [1] RSPM
#>  xfun          0.42    2024-02-08 [1] RSPM
#>  xml2          1.3.6   2023-12-04 [1] RSPM
#>  yaml          2.3.8   2023-12-11 [1] RSPM
#> 
#>  [1] /home/runner/work/_temp/Library
#>  [2] /opt/R/4.3.2/lib/R/site-library
#>  [3] /opt/R/4.3.2/lib/R/library
#> 
#> ──────────────────────────────────────────────────────────
```
