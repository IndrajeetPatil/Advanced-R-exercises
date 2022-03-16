# Control flow

## Exercise 5.2.4

Q1. `ifelse()` return type

It's type unstable, i.e. the type of return will depend on the type of each condition (`yes` and `no`, i.e.), and works only for cases where `test` argument evaluated to a `logical` type.


```r
ifelse(TRUE, 1, "no") # numeric returned
#> [1] 1
ifelse(FALSE, 1, "no") # character returned
#> [1] "no"
ifelse(NA, 1, "no")
#> [1] NA
```

Additionally, if the test doesn't resolve to `logical` type, it will try to coerce whatever the resulting type to `logical`:


```r
# will work
ifelse("TRUE", 1, "no")
#> [1] 1
ifelse("true", 1, "no")
#> [1] 1

# won't work
ifelse("tRuE", 1, "no")
#> [1] NA
ifelse(NaN, 1, "no")
#> [1] NA
```

Q2. Why does the following code work?

As can be seen, the code works because the tests are successfully coerced to a logical type.


```r
x <- 1:10
as.logical(length(1:10))
#> [1] TRUE
if (length(x)) "not empty" else "empty"
#> [1] "not empty"

x <- numeric()
as.logical(length(numeric()))
#> [1] FALSE
if (length(x)) "not empty" else "empty"
#> [1] "empty"
```

## Exercise 5.3.3

Q1. Why does this work?

This works because `1:length(x)` goes both ways; in this case, from 1 to 0. And, since out-of-bound values for atomic vectors is `NA`, all related operations with it also lead to `NA`.


```r
x <- numeric()
out <- vector("list", length(x))

for (i in 1:length(x)) {
  print(x[i])
  print(out[i])

  out[i] <- x[i]^2
}
#> [1] NA
#> [[1]]
#> NULL
#> 
#> numeric(0)
#> list()

out
#> [[1]]
#> [1] NA
```

A way to do avoid this unintended behavior would be:


```r
x <- numeric()
out <- vector("list", length(x))

for (i in 1:seq_along(x)) {
  out[i] <- x[i]^2
}
#> Error in 1:seq_along(x): argument of length 0

out
#> list()
```

Q2. Index vectors

Surprisingly (at least to me), `x` takes all values of the vector `xs`:


```r
# xs <- c(1, 2, 3)
xs <- c(4, 5, 6)
for (x in xs) {
  print(x)
  xs <- c(xs, x * 2)
}
#> [1] 4
#> [1] 5
#> [1] 6

xs
#> [1]  4  5  6  8 10 12
```

Q3. Index increase

In a `for` loop - like in a `while` loop - the index is updated in the beginning of each iteration.


```r
for (i in 1:3) {
  cat("before: ", i, "\n")
  i <- i * 2
  cat("after: ", i, "\n")
}
#> before:  1 
#> after:  2 
#> before:  2 
#> after:  4 
#> before:  3 
#> after:  6

i <- 1
while (i < 3) {
  cat("before: ", i, "\n")
  i <- i * 2
  cat("after: ", i, "\n")
}
#> before:  1 
#> after:  2 
#> before:  2 
#> after:  4
```
