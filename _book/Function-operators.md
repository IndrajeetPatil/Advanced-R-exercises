# Function operators



Attaching the needed libraries:


```r
library(purrr, warn.conflicts = FALSE)
```

### Exercises 11.2.3

**Q1.** Base R provides a function operator in the form of `Vectorize()`. What does it do? When might you use it?

**A1.** `Vectorize()` function creates a function that vectorizes the action of the provided function.

For example, the function `rep.int()` repeats a vector of integers `times` number of times, but there is no way to specify each element to be repeated a specific number of times. That is, the `times` argument is not vectorized.


```r
rep.int(1:4, 4:1)
#>  [1] 1 1 1 1 2 2 2 3 3 4
```

Contrast this output with the vectorized version of this function:


```r
vrep <- Vectorize(rep.int)
vrep(1:4, 4:1)
#> [[1]]
#> [1] 1 1 1 1
#> 
#> [[2]]
#> [1] 2 2 2
#> 
#> [[3]]
#> [1] 3 3
#> 
#> [[4]]
#> [1] 4
```


**Q2.** Read the source code for `possibly()`. How does it work?


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
#> <bytecode: 0x11f21df58>
#> <environment: namespace:purrr>
```

**Q3.** Read the source code for `safely()`. How does it work?


```r
safely
#> function (.f, otherwise = NULL, quiet = TRUE) 
#> {
#>     .f <- as_mapper(.f)
#>     function(...) capture_error(.f(...), otherwise, quiet)
#> }
#> <bytecode: 0x11fe23880>
#> <environment: namespace:purrr>
```

### Exercises 11.3.1

**Q1.** Weigh the pros and cons of `download.file %>% dot_every(10) %>% delay_by(0.1)` versus `download.file %>% delay_by(0.1) %>% dot_every(10)`.

**Q2.** Should you memoise `file.download()`? Why or why not?

**Q3.** Create a function operator that reports whenever a file is created or deleted in the working directory, using `dir()` and `setdiff()`. What other global function effects might you want to track?

**Q4.** Write a function operator that logs a timestamp and message to a file every time a function is run.

**Q5.** Modify `delay_by()` so that instead of delaying by a fixed amount of time, it ensures that a certain amount of time has elapsed since the function was last called. That is, if you called `g <- delay_by(1, f); g(); Sys.sleep(2); g()` there shouldn't be an extra delay.
