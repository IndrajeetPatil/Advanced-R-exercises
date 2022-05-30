# Evaluation



Attaching the needed libraries:


```r
library(rlang)
```

### Exercises 20.2.4

**Q1.** Carefully read the documentation for `source()`. What environment does it use by default? What if you supply `local = TRUE`? How do you provide a custom environment?

**Q2.** Predict the results of the following lines of code:


```r
eval(expr(eval(expr(eval(expr(2 + 2))))))
eval(eval(expr(eval(expr(eval(expr(2 + 2)))))))
expr(eval(expr(eval(expr(eval(expr(2 + 2)))))))
```

**Q3.** Fill in the function bodies below to re-implement `get()` using `sym()` and `eval()`, and`assign()` using `sym()`, `expr()`, and `eval()`. Don't worry about the multiple ways of choosing an environment that `get()` and `assign()` support; assume that the user supplies it explicitly.


```r
# name is a string
get2 <- function(name, env) {}
assign2 <- function(name, value, env) {}
```

**Q4.** Modify `source2()` so it returns the result of *every* expression, not just the last one. Can you eliminate the for loop?

**Q5.** We can make `base::local()` slightly easier to understand by spreading out over multiple lines:


```r
local3 <- function(expr, envir = new.env()) {
  call <- substitute(eval(quote(expr), envir))
  eval(call, envir = parent.frame())
}
```

Explain how `local()` works in words. (Hint: you might want to `print(call)` to help understand what `substitute()` is doing, and read the documentation to remind yourself what environment `new.env()` will inherit from.)

### Exercises 20.3.6

**Q1.** Predict what each of the following quosures will return if evaluated.


```r
q1 <- new_quosure(expr(x), env(x = 1))
q1
#> <quosure>
#> expr: ^x
#> env:  0x1119e85c0
q2 <- new_quosure(expr(x + !!q1), env(x = 10))
q2
#> <quosure>
#> expr: ^x + (^x)
#> env:  0x112b4b708
q3 <- new_quosure(expr(x + !!q2), env(x = 100))
q3
#> <quosure>
#> expr: ^x + (^x + (^x))
#> env:  0x112eb1708
```

**Q2.** Write an `enenv()` function that captures the environment associated with an argument. (Hint: this should only require two function calls.)

### Exercises 20.4.6

**Q1.** Why did I use a for loop in `transform2()` instead of `map()`? Consider `transform2(df, x = x * 2, x = x * 2)`.

**Q2.** Here's an alternative implementation of `subset2()`:


```r
subset3 <- function(data, rows) {
  rows <- enquo(rows)
  eval_tidy(expr(data[!!rows, , drop = FALSE]), data = data)
}
df <- data.frame(x = 1:3)
subset3(df, x == 1)
```

Compare and contrast `subset3()` to `subset2()`. What are its advantages and disadvantages?

**Q3.** The following function implements the basics of `dplyr::arrange()`. Annotate each line with a comment explaining what it does. Can you explain why `!!.na.last` is strictly correct, but omitting the `!!` is unlikely to cause problems?


```r
arrange2 <- function(.df, ..., .na.last = TRUE) {
  args <- enquos(...)
  order_call <- expr(order(!!!args, na.last = !!.na.last))
  ord <- eval_tidy(order_call, .df)
  stopifnot(length(ord) == nrow(.df))
  .df[ord, , drop = FALSE]
}
```

### Exercises 20.5.4

**Q1.** I've included an alternative implementation of `threshold_var()` below. What makes it different to the approach I used above? What makes it harder?


```r
threshold_var <- function(df, var, val) {
  var <- ensym(var)
  subset2(df, `$`(.data, !!var) >= !!val)
}
```

### Exercises 20.6.3

**Q1.** Why does this function fail?


```r
lm3a <- function(formula, data) {
  formula <- enexpr(formula)
  lm_call <- expr(lm(!!formula, data = data))
  eval(lm_call, caller_env())
}

lm3a(mpg ~ disp, mtcars)$call
#> Error in as.data.frame.default(data, optional = TRUE):
#> cannot coerce class ‘"function"’ to a data.frame
```

**Q2.** When model building, typically the response and data are relatively constant while you rapidly experiment with different predictors. Write a small wrapper that allows you to reduce duplication in the code below.


```r
lm(mpg ~ disp, data = mtcars)
lm(mpg ~ I(1 / disp), data = mtcars)
lm(mpg ~ disp * cyl, data = mtcars)
```

**Q3.** Another way to write `resample_lm()` would be to include the resample expression (`data[sample(nrow(data), replace = TRUE), , drop = FALSE]`) in the data argument. Implement that approach. What are the advantages? What are the disadvantages?
