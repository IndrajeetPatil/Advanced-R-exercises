# Measuring performance



## Exercise 23.2.4

**Q1.** Profile the following function with `torture = TRUE`. What is surprising? Read the source code of `rm()` to figure out what's going on.


```r
f <- function(n = 1e5) {
  x <- rep(1, n)
  rm(x)
}
```

**A1.** 

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
<div id="htmlwidget-94d039c1239af5e90704" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-94d039c1239af5e90704">{"x":{"message":{"prof":{"time":[1,1,1,1,1],"depth":[5,4,3,2,1],"label":["profvis","eval","eval","eval.parent","local"],"filenum":[null,null,null,null,null],"linenum":[null,null,null,null,null],"memalloc":[14.3287506103516,14.3287506103516,14.3287506103516,14.3287506103516,14.3287506103516],"meminc":[0,0,0,0,0],"filename":[null,null,null,null,null]},"interval":10,"files":[],"prof_output":"C:\\Users\\INDRAJ~1\\AppData\\Local\\Temp\\RtmpaqrZT7\\file39fc55742c9.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script>
```

Maybe because the function runs too fast?


```r
bench::mark(f(), check = FALSE, iterations = 1000)
#> # A tibble: 1 x 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f()           221us    254us     3894.     792KB     59.3
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
#> <bytecode: 0x000000001822bb30>
#> <environment: namespace:base>
```

I still couldn't figure out why. I would recommend checking out the [official answer](https://advanced-r-solutions.rbind.io/measuring-performance.html#profiling).

## Exercise 23.3.3

**Q1.** Instead of using `bench::mark()`, you could use the built-in function `system.time()`. But `system.time()` is much less precise, so you'll need to repeat each operation many times with a loop, and then divide to find the average time of each operation, as in the code below.


```r
n <- 1e6
system.time(for (i in 1:n) sqrt(x)) / n
system.time(for (i in 1:n) x^0.5) / n
```
    
How do the estimates from `system.time()` compare to those from `bench::mark()`? Why are they different?

**A1.** 


```r
library(dplyr)

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
#> 1 sqrt(x)      1.05us
#> 2 x^0.5        3.88us

t_systime_df
#> # A tibble: 2 x 3
#>   expression systime_with_gc_us systime_with_nogc_us
#>   <bch:expr>              <dbl>                <dbl>
#> 1 sqrt(x)                 0.980                0.690
#> 2 x^0.5                   3.32                 3.24
```

The comparison reveals that these two approaches yield quite similar results.

**Q2.** Here are two other ways to compute the square root of a vector. Which
    do you think will be fastest? Which will be slowest? Use microbenchmarking
    to test your answers.


```r
x^(1 / 2)
exp(log(x) / 2)
```

**A2.**

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
#> 1 sqrt(x)          4.7us   8.55us   120494.    7.86KB
#> 2 x^0.5           29.8us  34.15us    27072.    7.86KB
#> 3 x^(1/2)         31.7us   35.1us    26620.    7.86KB
#> 4 exp(log(x)/2)   76.7us   85.7us    11445.    7.86KB
#>   `gc/sec`
#>      <dbl>
#> 1        0
#> 2        0
#> 3        0
#> 4        0
```

The specialized primitive function `sqrt()` (written in `C`) is the fastest way to compute square root.
