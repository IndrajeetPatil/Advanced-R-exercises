# Function factories

### Exercises 10.2.6

**Q1.** The definition of `force()` is simple:


```r
force
#> function (x) 
#> x
#> <bytecode: 0x15214a708>
#> <environment: namespace:base>
```

Why is it better to `force(x)` instead of just `x`?

**A1.** Because of lazy evaluation, argument to a function won't be evaluated until its value is needed, but sometimes we may want to have eager evaluation.

Using `force()` makes this intent clearer.

**Q2.** Base R contains two function factories, `approxfun()` and `ecdf()`. Read their documentation and experiment to figure out what the functions do and what they return.

**A2.** About the two function factories-

- `approxfun()`

This function factory returns a function performing the linear (or constant) interpolation.


```r
x <- 1:10
y <- rnorm(10)
f <- approxfun(x, y)
f
#> function (v) 
#> .approxfun(x, y, v, method, yleft, yright, f, na.rm)
#> <bytecode: 0x133462b00>
#> <environment: 0x133463468>
f(x)
#>  [1] -0.7786629 -0.3894764 -2.0337983 -0.9823731  0.2478901
#>  [6] -2.1038646 -0.3814180  2.0749198  1.0271384  0.4730142
curve(f(x), 0, 11)
```

<img src="Function-factories_files/figure-html/unnamed-chunk-2-1.png" width="672" />

- `ecdf()`

This function factory computes an empirical cumulative distribution function.


```r
x <- rnorm(12)
f <- ecdf(x)
f
#> Empirical CDF 
#> Call: ecdf(x)
#>  x[1:12] = -1.8793, -1.3221, -1.2392,  ..., 1.1604, 1.7956
f(seq(-2, 2, by = 0.1))
#>  [1] 0.00000000 0.00000000 0.08333333 0.08333333 0.08333333
#>  [6] 0.08333333 0.08333333 0.16666667 0.25000000 0.25000000
#> [11] 0.33333333 0.33333333 0.33333333 0.41666667 0.41666667
#> [16] 0.41666667 0.41666667 0.50000000 0.58333333 0.58333333
#> [21] 0.66666667 0.75000000 0.75000000 0.75000000 0.75000000
#> [26] 0.75000000 0.75000000 0.75000000 0.75000000 0.83333333
#> [31] 0.83333333 0.83333333 0.91666667 0.91666667 0.91666667
#> [36] 0.91666667 0.91666667 0.91666667 1.00000000 1.00000000
#> [41] 1.00000000
```

**Q3.** Create a function `pick()` that takes an index, `i`, as an argument and returns a function with an argument `x` that subsets `x` with `i`.


```r
pick(1)(x)
# should be equivalent to
x[[1]]

lapply(mtcars, pick(5))
# should be equivalent to
lapply(mtcars, function(x) x[[5]])
```

**A3.** The desired function:


```r
pick <- function(i) {
  force(i)
  function(x) x[[i]]
}
```

Testing it with specified test cases:


```r
x <- list("a", "b", "c")
identical(x[[1]], pick(1)(x))
#> [1] TRUE

identical(
  lapply(mtcars, pick(5)),
  lapply(mtcars, function(x) x[[5]])
)
#> [1] TRUE
```

**Q4.** Create a function that creates functions that compute the i^th^ [central moment](http://en.wikipedia.org/wiki/Central_moment) of a numeric vector. You can test it by running the following code:


```r
m1 <- moment(1)
m2 <- moment(2)
x <- runif(100)
stopifnot(all.equal(m1(x), 0))
stopifnot(all.equal(m2(x), var(x) * 99 / 100))
```

**A4.** The desired function:


```r
moment <- function(k) {
  force(k)

  function(x) (sum((x - mean(x))^k)) / length(x)
}
```

Testing it with specified test cases:


```r
m1 <- moment(1)
m2 <- moment(2)
x <- runif(100)
stopifnot(all.equal(m1(x), 0))
stopifnot(all.equal(m2(x), var(x) * 99 / 100))
```

**Q5.** What happens if you don't use a closure? Make predictions, then verify with the code below.


```r
i <- 0
new_counter2 <- function() {
  i <<- i + 1
  i
}
```

**Q6.** What happens if you use `<-` instead of `<<-`? Make predictions, then verify with the code below.


```r
new_counter3 <- function() {
  i <- 0
  function() {
    i <- i + 1
    i
  }
}
```

**A6.**  In this case, the function will always return 1.


```r
new_counter3()
#> function() {
#>     i <- i + 1
#>     i
#>   }
#> <environment: 0x12361a4b0>

new_counter3()
#> function() {
#>     i <- i + 1
#>     i
#>   }
#> <bytecode: 0x12380f430>
#> <environment: 0x1236991e8>
```

### Exercises 10.3.4

**Q1.** Compare and contrast `ggplot2::label_bquote()` with `scales::number_format()`.

### Exercises 10.4.4

**Q1.** In `boot_model()`, why don't I need to force the evaluation of `df` or `model`?

**Q2.** Why might you formulate the Box-Cox transformation like this?


```r
boxcox3 <- function(x) {
  function(lambda) {
    if (lambda == 0) {
      log(x)
    } else {
      (x^lambda - 1) / lambda
    }
  }
}
```

**Q3.** Why don't you need to worry that `boot_permute()` stores a copy of the data inside the function that it generates?

**Q4.** How much time does `ll_poisson2()` save compared to `ll_poisson1()`? Use `bench::mark()` to see how much faster the optimisation occurs. How does changing the length of `x` change the results?

### Exercises 10.5.1

**Q1.** Which of the following commands is equivalent to `with(x, f(z))`?

    (a) `x$f(x$z)`.
    (b) `f(x$z)`.
    (c) `x$f(z)`.
    (d) `f(z)`.
    (e) It depends.

**Q2.** Compare and contrast the effects of `env_bind()` vs. `attach()` for the 
   following code.
   

```r
funs <- list(
  mean = function(x) mean(x, na.rm = TRUE),
  sum = function(x) sum(x, na.rm = TRUE)
)

attach(funs)
#> The following objects are masked from package:base:
#> 
#>     mean, sum
mean <- function(x) stop("Hi!")
detach(funs)

env_bind(globalenv(), !!!funs)
mean <- function(x) stop("Hi!")
env_unbind(globalenv(), names(funs))
```
