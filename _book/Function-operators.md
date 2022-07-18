# Function operators



Attaching the needed libraries:


```r
library(purrr, warn.conflicts = FALSE)
```

### Exercises 11.2.3

---

**Q1.** Base R provides a function operator in the form of `Vectorize()`. What does it do? When might you use it?

**A1.** `Vectorize()` function creates a function that vectorizes the action of the provided function over specified arguments. We will see its utility by solving a problem that otherwise couldn't be solved.

The problem is to build a hybrid between the following functions:

- `%in%` (which doesn't provide any way to provide tolerance when comparing numeric values),
- `dplyr::near()` (which is vectorized element-wise and thus expects two vectors of equal length)

in order to find indices of matching numeric values for the given threshold.


```r
which_near <- function(x, y, tolerance) {
  # Vectorize `dplyr::near()` function only over the `y` argument.
  # Note that that `Vectorize()` is a function operator and will return a function.
  customNear <- Vectorize(dplyr::near, vectorize.args = c("y"), SIMPLIFY = FALSE)

  # Apply the vectorized function to the two vectors and then check where the
  # comparisons are equal (i.e. `TRUE`) using `which()`.
  #
  # Use `compact()` to remove empty elements from the resulting list.
  index_list <- purrr::compact(purrr::map(customNear(x, y, tol = tolerance), which))

  # If there are any matches, return the indices as an atomic vector of integers.
  if (length(index_list) > 0L) {
    index_vector <- purrr::simplify(index_list, "integer")
    return(index_vector)
  }

  # If there are no matches
  return(integer(0L))
}
```
 
Let's use it:


```r
x1 <- c(2.1, 3.3, 8.45, 8, 6)
x2 <- c(6, 8.40, 3)

which(x1 %in% x2)
#> [1] 5

which(dplyr::near(x1, x2, tol = 0.1))
#> Warning in x - y: longer object length is not a multiple of
#> shorter object length
#> integer(0)

which_near(x1, x2, tolerance = 0.1)
#> [1] 5 3
```

We solved a complex task here using the `Vectorize()` function!

---

**Q2.** Read the source code for `possibly()`. How does it work?

**A2.** Let's have a look at the source code for this function:


```r
possibly
#> function (.f, otherwise, quiet = TRUE) 
#> {
#>     .f <- as_mapper(.f)
#>     force(otherwise)
#>     function(...) {
#>         tryCatch(.f(...), error = function(e) {
#>             if (!quiet) 
#>                 message("Error: ", e$message)
#>             otherwise
#>         }, interrupt = function(e) {
#>             stop("Terminated by user", call. = FALSE)
#>         })
#>     }
#> }
#> <bytecode: 0x10c0ecfd0>
#> <environment: namespace:purrr>
```

Looking at this code, we can see that `possibly()`:

- uses `tryCatch()` for error handling
- has a parameter `otherwise` to specify default value in case an error occurs
- has a parameter `quiet` to suppress error message (if needed)

---

**Q3.** Read the source code for `safely()`. How does it work?

**A3.** Let's have a look at the source code for this function:


```r
safely
#> function (.f, otherwise = NULL, quiet = TRUE) 
#> {
#>     .f <- as_mapper(.f)
#>     function(...) capture_error(.f(...), otherwise, quiet)
#> }
#> <bytecode: 0x10c28b668>
#> <environment: namespace:purrr>

purrr:::capture_error
#> function (code, otherwise = NULL, quiet = TRUE) 
#> {
#>     tryCatch(list(result = code, error = NULL), error = function(e) {
#>         if (!quiet) 
#>             message("Error: ", e$message)
#>         list(result = otherwise, error = e)
#>     }, interrupt = function(e) {
#>         stop("Terminated by user", call. = FALSE)
#>     })
#> }
#> <bytecode: 0x10c2eef28>
#> <environment: namespace:purrr>
```

Looking at this code, we can see that `safely()`:

- uses a list to save both the results (if the function executes successfully) and the error (if it fails)
- uses `tryCatch()` for error handling
- has a parameter `otherwise` to specify default value in case an error occurs
- has a parameter `quiet` to suppress error message (if needed)

---

### Exercises 11.3.1

---

**Q1.** Weigh the pros and cons of `download.file %>% dot_every(10) %>% delay_by(0.1)` versus `download.file %>% delay_by(0.1) %>% dot_every(10)`.

---

**Q2.** Should you memoise `download.file()`? Why or why not?

---

**Q3.** Create a function operator that reports whenever a file is created or deleted in the working directory, using `dir()` and `setdiff()`. What other global function effects might you want to track?

---

**Q4.** Write a function operator that logs a timestamp and message to a file every time a function is run.

---

**Q5.** Modify `delay_by()` so that instead of delaying by a fixed amount of time, it ensures that a certain amount of time has elapsed since the function was last called. That is, if you called `g <- delay_by(1, f); g(); Sys.sleep(2); g()` there shouldn't be an extra delay.

---
