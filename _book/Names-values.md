# Names and values

## 2.2.2 Exercises 

Q1. Explain the relationship


```r
a <- 1:10
b <- a
c <- b
d <- 1:10
```

All of these variable names are actively bound to the same value.


```r
library(lobstr)

obj_addr(a)
#> [1] "0x14b1d820"
obj_addr(b)
#> [1] "0x14b1d820"
obj_addr(c)
#> [1] "0x14b1d820"
obj_addr(d)
#> [1] "0x16b42fa0"
```

Q2. Function object address

Following code verifies that indeed these calls all point to the same underlying function object.


```r
obj_addr(mean)
#> [1] "0x16486ea8"
obj_addr(base::mean)
#> [1] "0x16486ea8"
obj_addr(get("mean"))
#> [1] "0x16486ea8"
obj_addr(evalq(mean))
#> [1] "0x16486ea8"
obj_addr(match.fun("mean"))
#> [1] "0x16486ea8"
```

Q3. Converting non-syntactic names 

The conversion of non-syntactic names to syntactic ones can sometimes corrupt the data. Some datasets may require non-syntactic names.

To suppress this behavior, one can set `check.names = FALSE`.

Q4. Behavior of `make.names()` 

It just prepends `X` in non-syntactic names and invalid characters (like `@`) are translated to `.`.


```r
make.names(c("123abc", "@me", "_yu", "  gh", "else"))
#> [1] "X123abc" "X.me"    "X_yu"    "X..gh"   "else."
```

Q5. Why is `.123e1` not a syntactic name? 

Because it is parsed as a number.


```r
.123e1 < 1
#> [1] FALSE
```

## 2.3.6 Exercises 

Q1. Usefulness of `tracemem()`

`tracemem()` traces copying of objects in R, but since the object created here is not assigned a name, there is nothing to trace. 


```r
tracemem(1:10)
#> [1] "<000000002ED559E8>"
```

Q2. Why two copies when you run this code?

Were it not for `4` being a double - and not an integer (`4L`) - this would have been modified in place.


```r
x <- c(1L, 2L, 3L)
tracemem(x)
#> [1] "<000000002EF022A0>"

x[[3]] <- 4
#> tracemem[0x000000002ef022a0 -> 0x000000002efa7580]: eval eval eval_with_user_handlers withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir eng_r block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> do.call eval eval eval eval eval.parent local 
#> tracemem[0x000000002efa7580 -> 0x000000002efe0220]: eval eval eval_with_user_handlers withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir eng_r block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> do.call eval eval eval eval eval.parent local
```

Try with integer:


```r
x <- c(1L, 2L, 3L)
tracemem(x)
#> [1] "<000000002F2067F0>"

x[[3]] <- 4L
#> tracemem[0x000000002f2067f0 -> 0x000000002f2a3fd0]: eval eval eval_with_user_handlers withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir eng_r block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> do.call eval eval eval eval eval.parent local
```

As for why this still produces a copy, this is from Solutions manual:

> Please be aware that running this code in RStudio will result in additional copies because of the reference from the environment pane.

Q3. Study relationship


```r
a <- 1:10
b <- list(a, a)
c <- list(b, a, 1:10)

ref(a)
#> [1:0x2f5a9330] <int>

ref(b)
#> o [1:0x2f5fb940] <list> 
#> +-[2:0x2f5a9330] <int> 
#> \-[2:0x2f5a9330]

ref(c)
#> o [1:0x2f65eb90] <list> 
#> +-o [2:0x2f5fb940] <list> 
#> | +-[3:0x2f5a9330] <int> 
#> | \-[3:0x2f5a9330] 
#> +-[3:0x2f5a9330] 
#> \-[4:0x2f667120] <int>
```

Q4. List inside another list


```r
x <- list(1:10)
x
#> [[1]]
#>  [1]  1  2  3  4  5  6  7  8  9 10
obj_addr(x)
#> [1] "0x309d8fc0"

x[[2]] <- x
x
#> [[1]]
#>  [1]  1  2  3  4  5  6  7  8  9 10
#> 
#> [[2]]
#> [[2]][[1]]
#>  [1]  1  2  3  4  5  6  7  8  9 10
obj_addr(x)
#> [1] "0x30e421a0"

ref(x)
#> o [1:0x30e421a0] <list> 
#> +-[2:0x30494788] <int> 
#> \-o [3:0x309d8fc0] <list> 
#>   \-[2:0x30494788]
```

Figure here:
<https://advanced-r-solutions.rbind.io/images/names_values/copy_on_modify_fig2.png>

## 2.4.1 Exercises 

Q1. Object size difference between `{base}` and `{lobstr}`

> This function...does not detect if elements of a list are shared.


```r
y <- rep(list(runif(1e4)), 100)

object.size(y)
#> 8005648 bytes

obj_size(y)
#> 80,896 B
```

Q2. Misleading object size

These functions are not externally created objects in R, but are always available, so doesn't make much sense to measure their size.


```r
funs <- list(mean, sd, var)
obj_size(funs)
#> 17,608 B
```

Nevertheless, it's still interesting that the addition is not the same as size of list of those objects.


```r
obj_size(mean)
#> 1,184 B
obj_size(sd)
#> 4,480 B
obj_size(var)
#> 12,472 B

obj_size(mean) + obj_size(sd) + obj_size(var)
#> 18,136 B
```

Q3. Predict object sizes


```r
a <- runif(1e6)
obj_size(a)
#> 8,000,048 B

b <- list(a, a)
obj_size(b)
#> 8,000,112 B
obj_size(a, b)
#> 8,000,112 B

b[[1]][[1]] <- 10
obj_size(b)
#> 16,000,160 B
obj_size(a, b)
#> 16,000,160 B

b[[2]][[1]] <- 10
obj_size(b)
#> 16,000,160 B
obj_size(a, b)
#> 24,000,208 B
```

## 2.5.3 Exercises

Q1. Why not a circular list?

Copy-on-modify prevents the creation of a circular list.


```r
x <- list()

obj_addr(x)
#> [1] "0x2f9e5c88"

tracemem(x)
#> [1] "<000000002F9E5C88>"

x[[1]] <- x
#> tracemem[0x000000002f9e5c88 -> 0x000000002fb251f0]: eval eval eval_with_user_handlers withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir eng_r block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> do.call eval eval eval eval eval.parent local

obj_addr(x[[1]])
#> [1] "0x2f9e5c88"
```

Q2. Performance of `for` loops with and without creating copies

Let's first microbenchmark functions that does and does not create copies for varying lengths of number of columns.


```r
library(bench)
library(tidyverse)
#> -- Attaching packages ------------------- tidyverse 1.3.1 --
#> v ggplot2 3.3.5.9000     v purrr   0.3.4     
#> v tibble  3.1.6          v dplyr   1.0.8     
#> v tidyr   1.2.0          v stringr 1.4.0     
#> v readr   2.1.2          v forcats 0.5.1
#> -- Conflicts ---------------------- tidyverse_conflicts() --
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()

generateDataFrame <- function(ncol) {
  as.data.frame(matrix(runif(100 * ncol), nrow = 100))
}

withCopy <- function(ncol) {
  x <- generateDataFrame(ncol)
  medians <- vapply(x, median, numeric(1))

  for (i in seq_along(medians)) {
    x[[i]] <- x[[i]] - medians[[i]]
  }

  return(x)
}

withoutCopy <- function(ncol) {
  x <- generateDataFrame(ncol)
  medians <- vapply(x, median, numeric(1))

  y <- as.list(x)

  for (i in seq_along(medians)) {
    y[[i]] <- y[[i]] - medians[[i]]
  }

  return(y)
}

benchComparison <- function(ncol) {
  bench::mark(
    withCopy(ncol),
    withoutCopy(ncol),
    iterations = 100,
    check = FALSE
  ) %>%
    dplyr::select(expression:total_time)
}

nColList <- list(1, 10, 50, 100, 250, 500, 1000)

names(nColList) <- as.character(nColList)

benchDf <- purrr::map_dfr(
  .x = nColList,
  .f = benchComparison,
  .id = "nColumns"
)
```

Plotting these benchmarks reveals how the performance gets increasingly worse as the number of dataframes increases:


```r
ggplot(benchDf,
       aes(
         x = as.numeric(nColumns),
         y = median,
         group = as.character(expression),
         color = as.character(expression)
       )) +
  geom_line() +
  labs(
    x = "Number of Columns",
    y = "Median Execution Time (ms)",
    colour = "Type of function"
  )
```

<img src="Names-values_files/figure-html/unnamed-chunk-17-1.png" width="672" />


Q3. `tracemem()` on an environment

It doesn't work and the documentation makes it clear as to why:

> It is not useful to trace NULL, environments, promises, weak references, or external pointer objects, as these are not duplicated


```r
e <- rlang::env(a = 1, b = "3")
tracemem(e)
#> Error in tracemem(e): 'tracemem' is not useful for promise and environment objects
```
