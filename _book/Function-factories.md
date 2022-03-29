# Function factories

### Exercises 10.2.6

**Q1.** The definition of `force()` is simple:


```r
force
#> function (x) 
#> x
#> <bytecode: 0x138144a70>
#> <environment: namespace:base>
```

Why is it better to `force(x)` instead of just `x`?

**A1.** Because of lazy evaluation, argument to a function won't be evaluated until its value is needed, but sometimes we may want to have eager evaluation.

Using `force()` makes this intent clearer.

**Q2.** Base R contains two function factories, `approxfun()` and `ecdf()`. Read their documentation and experiment to figure out what the functions do and what they return.

**Q3.** Create a function `pick()` that takes an index, `i`, as an argument and returns a function with an argument `x` that subsets `x` with `i`.


```r
pick(1)(x)
# should be equivalent to
x[[1]]

lapply(mtcars, pick(5))
# should be equivalent to
lapply(mtcars, function(x) x[[5]])
```
    
**Q4.** Create a function that creates functions that compute the i^th^ [central moment](http://en.wikipedia.org/wiki/Central_moment) of a numeric vector. You can test it by running the following code:


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
