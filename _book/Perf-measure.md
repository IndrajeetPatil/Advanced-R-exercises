# Measuring performance

## Exercise 23.2.4

Q1. Profiling function with `torture = TRUE`

Let's first source the functions mentioned in exercises.


```r
library(profvis)

source("profiling-exercises.R")
```

First, we try without `torture = TRUE`: it returns no meaningful results. 


```r
profvis(f())
```

```{=html}
<div id="htmlwidget-fc6d83d60c5694e4adb2" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-fc6d83d60c5694e4adb2">{"x":{"message":{"prof":{"time":[1,1,1,1,1,1,1,1,1],"depth":[9,8,7,6,5,4,3,2,1],"label":["doTryCatch","tryCatchOne","tryCatchList","tryCatch","profvis","eval","eval","eval.parent","local"],"filenum":[null,null,null,null,null,null,null,null,null],"linenum":[null,null,null,null,null,null,null,null,null],"memalloc":[7.66445922851562,7.66445922851562,7.66445922851562,7.66445922851562,7.66445922851562,7.66445922851562,7.66445922851562,7.66445922851562,7.66445922851562],"meminc":[0,0,0,0,0,0,0,0,0],"filename":[null,null,null,null,null,null,null,null,null]},"interval":10,"files":[],"prof_output":"C:\\Users\\INDRAJ~1\\AppData\\Local\\Temp\\RtmpmCyf0Z\\file882c6a335ee.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script>
```

Maybe because the function runs too fast?


```r
bench::mark(f(), check = FALSE, iterations = 1000)
#> # A tibble: 1 x 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f()           212us    288us     3329.    4.64MB     47.3
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
#> <bytecode: 0x000000001541ed58>
#> <environment: namespace:base>
```

I still couldn't figure out why. I would recommend checking out the [official answer](https://advanced-r-solutions.rbind.io/measuring-performance.html#profiling).

## Exercise 23.3.3

Q1. Differences between `system.time()` and `bench::mark()`


```r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

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
#> 1 sqrt(x)      1.11us
#> 2 x^0.5        3.72us

t_systime_df
#> # A tibble: 2 x 3
#>   expression systime_with_gc_us systime_with_nogc_us
#>   <bch:expr>              <dbl>                <dbl>
#> 1 sqrt(x)                 0.890                0.640
#> 2 x^0.5                   3.52                 3.43
```

The comparison reveals that these two approaches yield quite similar results.

Q2. Microbenchmarking ways to compute square root

Microbenchmarking all ways to compute square root of a vector mentioned in this chapter.


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
#> 1 sqrt(x)          4.8us      6us   108356.    7.86KB
#> 2 x^0.5           34.3us   35.8us    24416.    7.86KB
#> 3 x^(1/2)         33.7us     36us    22763.    7.86KB
#> 4 exp(log(x)/2)   85.6us   88.5us    10744.    7.86KB
#>   `gc/sec`
#>      <dbl>
#> 1     108.
#> 2       0 
#> 3       0 
#> 4       0
```

The specialized primitive function `sqrt()` (written in `C`) is the fastest way to compute square root.
