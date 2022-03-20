# Control flow



## Exercise 5.2.4

**Q1.** What type of vector does each of the following calls to `ifelse()` return?


```r
ifelse(TRUE, 1, "no")
ifelse(FALSE, 1, "no")
ifelse(NA, 1, "no")
```

Read the documentation and write down the rules in your own words.

**A1.** Here are *da rulz*: 

- It's type unstable, i.e. the type of return will depend on the type of each condition (`yes` and `no`, i.e.): 


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

- If the `test` argument doesn't resolve to `logical` type, it will try to coerce the output to `logical` type:


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

To quote the docs for this function:

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

**A2.** The code works because the conditions - even though of `numeric` type - are successfully coerced to a `logical` type.


```r
as.logical(length(1:10))
#> [1] TRUE

as.logical(length(numeric()))
#> [1] FALSE
```

## Exercise 5.3.3

**Q1.** Why does this code succeed without errors or warnings? 
    

```r
x <- numeric()
out <- vector("list", length(x))
for (i in 1:length(x)) {
  out[i] <- x[i]^2
}
out
```

**A1.** This works because `1:length(x)` goes both ways; in this case, from 1 to 0. And, since out-of-bound values for atomic vectors is `NA`, all related operations with it also lead to `NA`.


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
  print(x)
  xs <- c(xs, x * 2)
}
#> [1] 1
#> [1] 2
#> [1] 3
```

It is worth noting that `x` is not updated after each iteration, otherwise it will take increasingly bigger values of `xs`, and the loop will never end executing.

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

**A3.** In a `for` loop the index is updated in the **beginning** of each iteration. Otherwise, we will encounter an infinite loop.


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

Also, worth contrasting the behavior of `for` loop with that of `while` loop:


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
