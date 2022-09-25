# Control flow



## Choices (Exercises 5.2.4)

**Q1.** What type of vector does each of the following calls to `ifelse()` return?


```r
ifelse(TRUE, 1, "no")
ifelse(FALSE, 1, "no")
ifelse(NA, 1, "no")
```

Read the documentation and write down the rules in your own words.

**A1.** Here are the rules about what a call to `ifelse()` might return: 

- It is type unstable, i.e. the type of return will depend on the type of which condition is true (`yes` or `no`, i.e.): 


```r
ifelse(TRUE, 1, "no") # `numeric` returned
#> [1] 1
ifelse(FALSE, 1, "no") # `character` returned
#> [1] "no"
```

- It works only for cases where `test` argument evaluates to a `logical` type:


```r
ifelse(NA_real_, 1, "no")
#> [1] NA
ifelse(NaN, 1, "no")
#> [1] NA
```

- If `test` is argument is of logical type, but `NA`, it will return `NA`:


```r
ifelse(NA, 1, "no")
#> [1] NA
```

- If the `test` argument doesn't resolve to `logical` type, it will try to coerce the output to a `logical` type:


```r
# will work
ifelse("TRUE", 1, "no")
#> [1] 1
ifelse("false", 1, "no")
#> [1] "no"

# won't work
ifelse("tRuE", 1, "no")
#> [1] NA
ifelse(NaN, 1, "no")
#> [1] NA
```

This is also clarified in the docs for this function:

> A vector of the same length and attributes (including dimensions and `"class"`) as `test` and data values from the values of `yes` or `no`. The mode of the answer will be coerced from logical to accommodate first any values taken from yes and then any values taken from `no`.

**Q2.** Why does the following code work?


```r
x <- 1:10
if (length(x)) "not empty" else "empty"
#> [1] "not empty"

x <- numeric()
if (length(x)) "not empty" else "empty"
#> [1] "empty"
```

**A2.** The code works because the conditional expressions in `if()` - even though of `numeric` type - can be successfully coerced to a `logical` type.


```r
as.logical(length(1:10))
#> [1] TRUE

as.logical(length(numeric()))
#> [1] FALSE
```

## Loops (Exercises 5.3.3)

**Q1.** Why does this code succeed without errors or warnings? 
    

```r
x <- numeric()
out <- vector("list", length(x))
for (i in 1:length(x)) {
  out[i] <- x[i]^2
}
out
```

**A1.** This works because `1:length(x)` works in both positive and negative directions.


```r
1:2
#> [1] 1 2
1:0
#> [1] 1 0
1:-3
#> [1]  1  0 -1 -2 -3
```

In this case, since `x` is of length `0`, `i` will go from `1` to `0`. 

Additionally, since out-of-bound (OOB) value for atomic vectors is `NA`, all related operations with OOB values will also produce `NA`.


```r
x <- numeric()
out <- vector("list", length(x))

for (i in 1:length(x)) {
  print(paste("i:", i, ", x[i]:", x[i], ", out[i]:", out[i]))

  out[i] <- x[i]^2
}
#> [1] "i: 1 , x[i]: NA , out[i]: NULL"
#> [1] "i: 0 , x[i]:  , out[i]: "

out
#> [[1]]
#> [1] NA
```

A way to do avoid this unintended behavior is to use `seq_along()` instead:


```r
x <- numeric()
out <- vector("list", length(x))

for (i in seq_along(x)) {
  out[i] <- x[i]^2
}

out
#> list()
```

**Q2.** When the following code is evaluated, what can you say about the vector being iterated?


```r
xs <- c(1, 2, 3)
for (x in xs) {
  xs <- c(xs, x * 2)
}
xs
#> [1] 1 2 3 2 4 6
```

**A2.** The iterator variable `x` initially takes all values of the vector `xs`. We can check this by printing `x` for each iteration:


```r
xs <- c(1, 2, 3)
for (x in xs) {
  cat("x:", x, "\n")
  xs <- c(xs, x * 2)
  cat("xs:", paste(xs), "\n")
}
#> x: 1 
#> xs: 1 2 3 2 
#> x: 2 
#> xs: 1 2 3 2 4 
#> x: 3 
#> xs: 1 2 3 2 4 6
```

It is worth noting that `x` is not updated *after* each iteration; otherwise, it will take increasingly bigger values of `xs`, and the loop will never end executing.

**Q3.** What does the following code tell you about when the index is updated?


```r
for (i in 1:3) {
  i <- i * 2
  print(i)
}
#> [1] 2
#> [1] 4
#> [1] 6
```

**A3.** In a `for()` loop the index is updated in the **beginning** of each iteration. Otherwise, we will encounter an infinite loop.


```r
for (i in 1:3) {
  cat("before: ", i, "\n")
  i <- i * 2
  cat("after:  ", i, "\n")
}
#> before:  1 
#> after:   2 
#> before:  2 
#> after:   4 
#> before:  3 
#> after:   6
```

Also, worth contrasting the behavior of `for()` loop with that of `while()` loop:


```r
i <- 1
while (i < 4) {
  cat("before: ", i, "\n")
  i <- i * 2
  cat("after:  ", i, "\n")
}
#> before:  1 
#> after:   2 
#> before:  2 
#> after:   4
```

## Session information


```r
sessioninfo::session_info(include_base = TRUE)
#> ─ Session info ───────────────────────────────────────────
#>  setting  value
#>  version  R version 4.2.1 (2022-06-23)
#>  os       macOS Monterey 12.5.1
#>  system   aarch64, darwin20
#>  ui       X11
#>  language (EN)
#>  collate  en_US.UTF-8
#>  ctype    en_US.UTF-8
#>  tz       Europe/Berlin
#>  date     2022-09-25
#>  pandoc   2.19.2 @ /usr/local/bin/ (via rmarkdown)
#> 
#> ─ Packages ───────────────────────────────────────────────
#>  ! package     * version    date (UTC) lib source
#>    base        * 4.2.1      2022-06-24 [?] local
#>    bookdown      0.29       2022-09-12 [1] CRAN (R 4.2.1)
#>    bslib         0.4.0.9000 2022-08-20 [1] Github (rstudio/bslib@fa2e03c)
#>    cachem        1.0.6      2021-08-19 [1] CRAN (R 4.2.0)
#>    cli           3.4.1      2022-09-23 [1] CRAN (R 4.2.1)
#>  P compiler      4.2.1      2022-06-24 [1] local
#>  P datasets    * 4.2.1      2022-06-24 [1] local
#>    digest        0.6.29     2021-12-01 [1] CRAN (R 4.2.0)
#>    downlit       0.4.2      2022-07-05 [1] CRAN (R 4.2.1)
#>    evaluate      0.16       2022-08-09 [1] CRAN (R 4.2.1)
#>    fastmap       1.1.0      2021-01-25 [1] CRAN (R 4.2.0)
#>    fs            1.5.2      2021-12-08 [1] CRAN (R 4.2.0)
#>  P graphics    * 4.2.1      2022-06-24 [1] local
#>  P grDevices   * 4.2.1      2022-06-24 [1] local
#>    htmltools     0.5.3      2022-07-18 [1] CRAN (R 4.2.1)
#>    jquerylib     0.1.4      2021-04-26 [1] CRAN (R 4.2.0)
#>    jsonlite      1.8.0      2022-02-22 [1] CRAN (R 4.2.0)
#>    knitr         1.40       2022-08-24 [1] CRAN (R 4.2.1)
#>    magrittr    * 2.0.3      2022-03-30 [1] CRAN (R 4.2.0)
#>    memoise       2.0.1      2021-11-26 [1] CRAN (R 4.2.0)
#>  P methods     * 4.2.1      2022-06-24 [1] local
#>    R6            2.5.1.9000 2022-08-06 [1] Github (r-lib/R6@87d5e45)
#>    rlang         1.0.6      2022-09-24 [1] CRAN (R 4.2.1)
#>    rmarkdown     2.16       2022-08-24 [1] CRAN (R 4.2.1)
#>    rstudioapi    0.14       2022-08-22 [1] CRAN (R 4.2.1)
#>    sass          0.4.2      2022-07-16 [1] CRAN (R 4.2.1)
#>    sessioninfo   1.2.2      2021-12-06 [1] CRAN (R 4.2.0)
#>  P stats       * 4.2.1      2022-06-24 [1] local
#>    stringi       1.7.8      2022-07-11 [1] CRAN (R 4.2.1)
#>    stringr       1.4.1      2022-08-20 [1] CRAN (R 4.2.1)
#>  P tools         4.2.1      2022-06-24 [1] local
#>  P utils       * 4.2.1      2022-06-24 [1] local
#>    withr         2.5.0      2022-03-03 [1] CRAN (R 4.2.0)
#>    xfun          0.33       2022-09-12 [1] CRAN (R 4.2.1)
#>    xml2          1.3.3      2021-11-30 [1] CRAN (R 4.2.0)
#>    yaml          2.3.5      2022-02-21 [1] CRAN (R 4.2.0)
#> 
#>  [1] /Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library
#> 
#>  P ── Loaded and on-disk path mismatch.
#> 
#> ──────────────────────────────────────────────────────────
```
