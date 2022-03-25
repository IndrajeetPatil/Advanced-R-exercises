# Improving performance

### Exercises 24.3.1

**Q1.** What are faster alternatives to `lm()`? Which are specifically designed to work with larger datasets?

**A1.** Faster alternatives to `lm()` can be found by visiting [CRAN Task View: High-Performance and Parallel Computing with R](https://cran.r-project.org/web/views/HighPerformanceComputing.html) page.

Here are some of the available options:

- `speedglm::speedlm()` (for large datasets)

- `biglm::biglm()` (specifically designed for data too large to fit in memory)

- `RcppEigen::fastLm()` (using the `Eigen` linear algebra library)

High performances can be obtained with these packages especially if R is linked against an optimized BLAS, such as ATLAS. You can check this information using `sessionInfo()`:


```r
sessInfo <- sessionInfo()
sessInfo$matprod
#> [1] "default"
sessInfo$LAPACK
#> [1] ""
```

Comparing performance of different alternatives:


```r
library(gapminder)

# having a look at the data
dplyr::glimpse(gapminder)
#> Rows: 1,704
#> Columns: 6
#> $ country   <fct> "Afghanistan", "Afghanistan", "Afghanist~
#> $ continent <fct> Asia, Asia, Asia, Asia, Asia, Asia, Asia~
#> $ year      <int> 1952, 1957, 1962, 1967, 1972, 1977, 1982~
#> $ lifeExp   <dbl> 28.801, 30.332, 31.997, 34.020, 36.088, ~
#> $ pop       <int> 8425333, 9240934, 10267083, 11537966, 13~
#> $ gdpPercap <dbl> 779.4453, 820.8530, 853.1007, 836.1971, ~

bench::mark(
  "lm"       = stats::lm(lifeExp ~ continent * gdpPercap, gapminder),
  "speedglm" = speedglm::speedlm(lifeExp ~ continent * gdpPercap, gapminder),
  "biglm"    = biglm::biglm(lifeExp ~ continent * gdpPercap, gapminder),
  "fastLm"   = RcppEigen::fastLm(lifeExp ~ continent * gdpPercap, gapminder),
  check      = FALSE,
  iterations = 1000
)[1:5]
#> # A tibble: 4 x 5
#>   expression      min   median `itr/sec` mem_alloc
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>
#> 1 lm           1.01ms    1.3ms      707.    1.25MB
#> 2 speedglm     1.23ms   1.38ms      692.   61.29MB
#> 3 biglm       847.8us   1.01ms      946.  944.81KB
#> 4 fastLm        1.2ms   1.49ms      649.  992.86KB
```

The results might change depending on the size of the dataset, so you will have to experiment with different algorithms and find the one that fits the needs of your dataset the best.

**Q2.** What package implements a version of `match()` that's faster for repeated look ups? How much faster is it?

**A2.** The package (and the respective function) is `fastmatch::fmatch()`^[In addition to Google search, you can also try [packagefinder](https://www.zuckarelli.de/packagefinder/tutorial.html) to search for CRAN packages.].

The documentation for this function notes:

> It is slightly faster than the built-in version because it uses more specialized code, but in addition it retains the hash table within the table object such that it can be re-used, dramatically reducing the look-up time especially for large table.

Let's try. 

With a small vector, `fmatch()` is only slightly faster, but of the same order of magnitude.


```r
library(fastmatch, warn.conflicts = FALSE)

small_vec <- c("a", "b", "x", "m", "n", "y")

length(small_vec)
#> [1] 6

bench::mark(
  "base" = match(c("x", "y"), small_vec),
  "fastmatch" = fmatch(c("x", "y"), small_vec)
)[1:5]
#> # A tibble: 2 x 5
#>   expression      min   median `itr/sec` mem_alloc
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>
#> 1 base            1us    2.1us   450651.        0B
#> 2 fastmatch     900ns    1.8us   500293.    2.66KB
```

But, with a larger vector, `fmatch()` is only orders of magnitude faster! ⚡


```r
large_vec <- c(rep(c("a", "b"), 1e4), "x", rep(c("m", "n"), 1e6), "y")

length(large_vec)
#> [1] 2020002

bench::mark(
  "base" = match(c("x", "y"), large_vec),
  "fastmatch" = fmatch(c("x", "y"), large_vec)
)[1:5]
#> # A tibble: 2 x 5
#>   expression      min   median `itr/sec` mem_alloc
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>
#> 1 base         26.5ms   32.8ms      30.5    31.4MB
#> 2 fastmatch     1.5us      2us  480095.         0B
```

We can also look at the hash table:


```r
fmatch.hash(c("x", "y"), small_vec)
#> [1] "a" "b" "x" "m" "n" "y"
#> attr(,".match.hash")
#> <hash table>
```

Additionally, `{fastmatch}` also provides a similar infix operator:


```r
library(fastmatch)

small_vec <- c("a", "b", "x", "m", "n", "y")

c("x", "y") %in% small_vec
#> [1] TRUE TRUE

c("x", "y") %fin% small_vec
#> [1] TRUE TRUE
```

**Q3.** List four functions (not just those in base R) that convert a string into a date time object. What are their strengths and weaknesses?

**Q4.** Which packages provide the ability to compute a rolling mean?

**A4.** Here are a few packages and respective functions that provide a way to compute a rolling mean:

- `RcppRoll::roll_mean()`
- `data.table::frollmean()`
- `roll::roll_mean()`
- `zoo::rollmean()`
- `slider::slide_dbl()`

**Q5.** What are the alternatives to `optim()`?

### Exercises 24.4.3

**Q1.** What's the difference between `rowSums()` and `.rowSums()`?

**A1.** The documentation for these functions state:

> The versions with an initial dot in the name (.colSums() etc) are ‘bare-bones’ versions for use in programming: they apply only to numeric (like) matrices and do not name the result.

Looking at the source code,

- `rowSums()` function does a number of checks to validate if the arguments are acceptable


```r
rowSums
#> function (x, na.rm = FALSE, dims = 1L) 
#> {
#>     if (is.data.frame(x)) 
#>         x <- as.matrix(x)
#>     if (!is.array(x) || length(dn <- dim(x)) < 2L) 
#>         stop("'x' must be an array of at least two dimensions")
#>     if (dims < 1L || dims > length(dn) - 1L) 
#>         stop("invalid 'dims'")
#>     p <- prod(dn[-(id <- seq_len(dims))])
#>     dn <- dn[id]
#>     z <- if (is.complex(x)) 
#>         .Internal(rowSums(Re(x), prod(dn), p, na.rm)) + (0+1i) * 
#>             .Internal(rowSums(Im(x), prod(dn), p, na.rm))
#>     else .Internal(rowSums(x, prod(dn), p, na.rm))
#>     if (length(dn) > 1L) {
#>         dim(z) <- dn
#>         dimnames(z) <- dimnames(x)[id]
#>     }
#>     else names(z) <- dimnames(x)[[1L]]
#>     z
#> }
#> <bytecode: 0x0000000034f10ee8>
#> <environment: namespace:base>
```

- `.rowSums()` directly proceeds to computation using an internal code which is built in to the R interpreter


```r
.rowSums
#> function (x, m, n, na.rm = FALSE) 
#> .Internal(rowSums(x, m, n, na.rm))
#> <bytecode: 0x0000000034e05270>
#> <environment: namespace:base>
```

But they have comparable performance:


```r
x <- cbind(x1 = 3, x2 = c(4:1e4, 2:1e5))

bench::mark(
  rowSums(x),
  .rowSums(x, dim(x)[[1]], dim(x)[[2]])
)[1:5]
#> # A tibble: 2 x 5
#>   expression                                 min   median
#>   <bch:expr>                            <bch:tm> <bch:tm>
#> 1 rowSums(x)                               833us   1.05ms
#> 2 .rowSums(x, dim(x)[[1]], dim(x)[[2]])    914us   1.14ms
#>   `itr/sec` mem_alloc
#>       <dbl> <bch:byt>
#> 1      919.     859KB
#> 2      829.     859KB
```

**Q2.** Make a faster version of `chisq.test()` that only computes the chi-square test statistic when the input is two numeric vectors with no missing values. You can try simplifying `chisq.test()` or by coding from the [mathematical definition](http://en.wikipedia.org/wiki/Pearson%27s_chi-squared_test).

**A2.** If the function is supposed to accept only two numeric vectors without missing values, then we can make `chisq.test()` do less work by removing code corresponding to the following :

- checks for data frame and matrix inputs
- goodness-of-fit test
- simulating *p*-values
- checking for missing values

This leaves us with a much simpler, bare bones implementation:


```r
my_chisq_test <- function(x, y) {
  x <- table(x, y)
  n <- sum(x)

  nr <- as.integer(nrow(x))
  nc <- as.integer(ncol(x))

  sr <- rowSums(x)
  sc <- colSums(x)
  E <- outer(sr, sc, "*") / n
  v <- function(r, c, n) c * r * (n - r) * (n - c) / n^3
  V <- outer(sr, sc, v, n)
  dimnames(E) <- dimnames(x)

  STATISTIC <- sum((abs(x - E))^2 / E)
  PARAMETER <- (nr - 1L) * (nc - 1L)
  PVAL <- pchisq(STATISTIC, PARAMETER, lower.tail = FALSE)

  names(STATISTIC) <- "X-squared"
  names(PARAMETER) <- "df"

  structure(
    list(
      statistic = STATISTIC,
      parameter = PARAMETER,
      p.value = PVAL,
      method = "Pearson's Chi-squared test",
      observed = x,
      expected = E,
      residuals = (x - E) / sqrt(E),
      stdres = (x - E) / sqrt(V)
    ),
    class = "htest"
  )
}
```

And, indeed, this custom function performs slightly better^[Deliberately choosing a larger dataset to stress test the new function.] than its base equivalent:


```r
m <- c(rep("a", 1000), rep("b", 9000))
n <- c(rep(c("x", "y"), 5000))

bench::mark(
  "base" = chisq.test(m, n)$statistic[[1]],
  "custom" = my_chisq_test(m, n)$statistic[[1]]
)[1:5]
#> # A tibble: 2 x 5
#>   expression      min   median `itr/sec` mem_alloc
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>
#> 1 base          808us   1.29ms      776.    1.57MB
#> 2 custom        663us   1.11ms      986.    1.12MB
```

**Q3.** Can you make a faster version of `table()` for the case of an input of two integer vectors with no missing values? Can you use it to speed up your chi-square test?

**A3.** In order to make a leaner version of `table()`, we can take a similar approach and trim the unnecessary fat in light of our new API of accepting just two vectors without missing values. We can remove the following components from the code:

- extracting data from objects entered in `...` argument
- dealing with missing values
- other input validation checks

In addition to this removal, we can also use `fastmatch::fmatch()` instead of `match()`:


```r
my_table <- function(x, y) {
  x_sorted <- sort(unique(x))
  y_sorted <- sort(unique(y))

  x_length <- length(x_sorted)
  y_length <- length(y_sorted)

  bin <- fastmatch::fmatch(x, x_sorted) + x_length * fastmatch::fmatch(y, y_sorted) - x_length

  y <- tabulate(bin, x_length * y_length)

  y <- array(
    y,
    dim = c(x_length, y_length),
    dimnames = list(x = x_sorted, y = y_sorted)
  )

  class(y) <- "table"
  y
}
```

The custom does perform slightly better:


```r
x <- c(rep("a", 1000), rep("b", 9000))
y <- c(rep(c("x", "y"), 5000))

# check is set to FALSE because the custom function has an additional attribute: `'.match.hash'`
bench::mark(
  "base" = table(x, y),
  "custom" = my_table(x, y),
  check = FALSE
)[1:5]
#> # A tibble: 2 x 5
#>   expression      min   median `itr/sec` mem_alloc
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>
#> 1 base          554us   1.05ms     1053.     960KB
#> 2 custom        313us  525.6us     1983.     475KB
```

We can also use this function in our custom chi-squared test function and see if the performance improves any further:


```r
my_chisq_test2 <- function(x, y) {
  x <- my_table(x, y)
  n <- sum(x)

  nr <- as.integer(nrow(x))
  nc <- as.integer(ncol(x))

  sr <- rowSums(x)
  sc <- colSums(x)
  E <- outer(sr, sc, "*") / n
  v <- function(r, c, n) c * r * (n - r) * (n - c) / n^3
  V <- outer(sr, sc, v, n)
  dimnames(E) <- dimnames(x)

  STATISTIC <- sum((abs(x - E))^2 / E)
  PARAMETER <- (nr - 1L) * (nc - 1L)
  PVAL <- pchisq(STATISTIC, PARAMETER, lower.tail = FALSE)

  names(STATISTIC) <- "X-squared"
  names(PARAMETER) <- "df"

  structure(
    list(
      statistic = STATISTIC,
      parameter = PARAMETER,
      p.value = PVAL,
      method = "Pearson's Chi-squared test",
      observed = x,
      expected = E,
      residuals = (x - E) / sqrt(E),
      stdres = (x - E) / sqrt(V)
    ),
    class = "htest"
  )
}
```

And, indeed, this new version of the custom function performs even better than it previously did:


```r
m <- c(rep("a", 1000), rep("b", 9000))
n <- c(rep(c("x", "y"), 5000))

bench::mark(
  "base" = chisq.test(m, n)$statistic[[1]],
  "custom" = my_chisq_test2(m, n)$statistic[[1]]
)[1:5]
#> # A tibble: 2 x 5
#>   expression      min   median `itr/sec` mem_alloc
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>
#> 1 base          789us   1.59ms      677.    1.28MB
#> 2 custom        389us  686.2us     1583.  594.98KB
```

### Exercises 24.5.1

**Q1.** The density functions, e.g., `dnorm()`, have a common interface. Which arguments are vectorised over? What does `rnorm(10, mean = 10:1)` do?

**Q2.** Compare the speed of `apply(x, 1, sum)` with `rowSums(x)` for varying sizes of `x`.

**Q3.** How can you use `crossprod()` to compute a weighted sum? How much faster is it than the naive `sum(x * w)`?
