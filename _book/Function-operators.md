# Function operators



Attaching the needed libraries:


```r
library(purrr, warn.conflicts = FALSE)
```

## Existing function operators (Exercises 11.2.3)

---

**Q1.** Base R provides a function operator in the form of `Vectorize()`. What does it do? When might you use it?

**A1.** `Vectorize()` function creates a function that vectorizes the action of the provided function over specified arguments (i.e., it acts on each element of the vector). We will see its utility by solving a problem that otherwise would be difficult to solve.

The problem is to find indices of matching numeric values for the given threshold by creating a hybrid of the following functions:

- `%in%` (which doesn't provide any way to provide tolerance when comparing numeric values),
- `dplyr::near()` (which is vectorized element-wise and thus expects two vectors of equal length)


```r
which_near <- function(x, y, tolerance) {
  # Vectorize `dplyr::near()` function only over the `y` argument.
  # `Vectorize()` is a function operator and will return a function.
  customNear <- Vectorize(dplyr::near, vectorize.args = c("y"), SIMPLIFY = FALSE)

  # Apply the vectorized function to vector arguments and then check where the
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

which_near(x1, x2, tolerance = 0.1)
#> [1] 5 3
```

Note that we needed to create a new function for this because neither of the existing functions do what we want.


```r
which(x1 %in% x2)
#> [1] 5

which(dplyr::near(x1, x2, tol = 0.1))
#> Warning in x - y: longer object length is not a multiple of
#> shorter object length
#> integer(0)
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
#> <bytecode: 0x133be7b68>
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
#> <bytecode: 0x1243b3f68>
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
#> <bytecode: 0x124c0bfd8>
#> <environment: namespace:purrr>
```

Looking at this code, we can see that `safely()`:

- uses a list to save both the results (if the function executes successfully) and the error (if it fails)
- uses `tryCatch()` for error handling
- has a parameter `otherwise` to specify default value in case an error occurs
- has a parameter `quiet` to suppress error message (if needed)

---

## Case study: Creating your own function operators (Exercises 11.3.1)

---

**Q1.** Weigh the pros and cons of `download.file %>% dot_every(10) %>% delay_by(0.1)` versus `download.file %>% delay_by(0.1) %>% dot_every(10)`.

**A1.** Although both of these chains of piped operations produce the same number of dots and would need the same amount of time, there is a subtle difference in how they do this.

- `download.file %>% dot_every(10) %>% delay_by(0.1)`

Here, the printing of the dot is also delayed, and the first dot is printed when the 10th URL download starts.

- `download.file %>% delay_by(0.1) %>% dot_every(10)`

Here, the first dot is printed after the 9th download is finished, and the 10th download starts after a short delay.

---

**Q2.** Should you memoise `download.file()`? Why or why not?

**A2.** Since `download.file()` is meant to download files from the Internet, memoising it is not recommended for the following reasons:

- Memoization is helpful when giving the same input the function returns the same output. This is not necessarily the case for webpages since they constantly change, and you may continue to "download" an outdated version of the webpage.

- Memoization works by caching results, which can take up a significant amount of memory. 

---

**Q3.** Create a function operator that reports whenever a file is created or deleted in the working directory, using `dir()` and `setdiff()`. What other global function effects might you want to track?

**A3.** First, let's create helper functions to compare and print added or removed filenames:


```r
print_multiple_entries <- function(header, entries) {
  message(paste0(header, ":\n"), paste0(entries, collapse = "\n"))
}

file_comparator <- function(old, new) {
  if (setequal(old, new)) {
    return()
  }

  removed <- setdiff(old, new)
  added <- setdiff(new, old)

  if (length(removed) > 0L) print_multiple_entries("- File removed", removed)
  if (length(added) > 0L) print_multiple_entries("- File added", added)
}
```

We can then write a function operator and use it to create functions that will do the necessary tracking:


```r
dir_tracker <- function(f) {
  force(f)
  function(...) {
    old_files <- dir()
    on.exit(file_comparator(old_files, dir()), add = TRUE)

    f(...)
  }
}

file_creation_tracker <- dir_tracker(file.create)
file_deletion_tracker <- dir_tracker(file.remove)
```

Let's try it out:


```r
file_creation_tracker(c("a.txt", "b.txt"))
#> - File added:
#> a.txt
#> b.txt
#> [1] TRUE TRUE

file_deletion_tracker(c("a.txt", "b.txt"))
#> - File removed:
#> a.txt
#> b.txt
#> [1] TRUE TRUE
```

Other global function effects we might want to track:

- working directory
- environment variables
- connections
- library paths
- graphics devices
- [etc.](https://withr.r-lib.org/reference/index.html)

---

**Q4.** Write a function operator that logs a timestamp and message to a file every time a function is run.

**A4.** The following function operator logs a timestamp and message to a file every time a function is run:


```r
# helper function to write to a file connection
write_line <- function(filepath, ...) {
  cat(..., "\n", sep = "", file = filepath, append = TRUE)
}

# function operator
logger <- function(f, filepath) {
  force(f)
  force(filepath)

  write_line(filepath, "Function created at: ", as.character(Sys.time()))

  function(...) {
    write_line(filepath, "Function called at:  ", as.character(Sys.time()))
    f(...)
  }
}

# check that the function works as expected with a tempfile
withr::with_tempfile("logfile", code = {
  logged_runif <- logger(runif, logfile)

  Sys.sleep(sample.int(10, 1))
  logged_runif(1)

  Sys.sleep(sample.int(10, 1))
  logged_runif(2)

  Sys.sleep(sample.int(10, 1))
  logged_runif(3)

  cat(readLines(logfile), sep = "\n")
})
#> Function created at: 2022-11-12 11:27:07
#> Function called at:  2022-11-12 11:27:12
#> Function called at:  2022-11-12 11:27:17
#> Function called at:  2022-11-12 11:27:25
```

---

**Q5.** Modify `delay_by()` so that instead of delaying by a fixed amount of time, it ensures that a certain amount of time has elapsed since the function was last called. That is, if you called `g <- delay_by(1, f); g(); Sys.sleep(2); g()` there shouldn't be an extra delay.

**A5.** Modified version of the function meeting the specified requirements:


```r
delay_by_atleast <- function(f, amount) {
  force(f)
  force(amount)

  # the last time the function was run
  last_time <- NULL

  function(...) {
    if (!is.null(last_time)) {
      wait <- (last_time - Sys.time()) + amount
      if (wait > 0) Sys.sleep(wait)
    }

    # update the time in the parent frame for the next run when the function finishes
    on.exit(last_time <<- Sys.time())

    f(...)
  }
}
```

---

## Session information


```r
sessioninfo::session_info(include_base = TRUE)
#> ─ Session info ───────────────────────────────────────────
#>  setting  value
#>  version  R version 4.2.2 (2022-10-31)
#>  os       macOS Ventura 13.0
#>  system   aarch64, darwin20
#>  ui       X11
#>  language (EN)
#>  collate  en_US.UTF-8
#>  ctype    en_US.UTF-8
#>  tz       Europe/Berlin
#>  date     2022-11-12
#>  pandoc   2.19.2 @ /Applications/RStudio.app/Contents/MacOS/quarto/bin/tools/ (via rmarkdown)
#> 
#> ─ Packages ───────────────────────────────────────────────
#>  ! package     * version    date (UTC) lib source
#>    assertthat    0.2.1      2019-03-21 [1] CRAN (R 4.2.0)
#>    base        * 4.2.2      2022-10-31 [?] local
#>    bookdown      0.30       2022-11-09 [1] CRAN (R 4.2.2)
#>    bslib         0.4.1      2022-11-02 [1] CRAN (R 4.2.2)
#>    cachem        1.0.6      2021-08-19 [1] CRAN (R 4.2.0)
#>    cli           3.4.1      2022-09-23 [1] CRAN (R 4.2.0)
#>  P compiler      4.2.2      2022-10-31 [1] local
#>  P datasets    * 4.2.2      2022-10-31 [1] local
#>    DBI           1.1.3.9002 2022-10-17 [1] Github (r-dbi/DBI@2aec388)
#>    digest        0.6.30     2022-10-18 [1] CRAN (R 4.2.1)
#>    downlit       0.4.2      2022-07-05 [1] CRAN (R 4.2.1)
#>    dplyr         1.0.10     2022-09-01 [1] CRAN (R 4.2.1)
#>    evaluate      0.18       2022-11-07 [1] CRAN (R 4.2.2)
#>    fansi         1.0.3      2022-03-24 [1] CRAN (R 4.2.0)
#>    fastmap       1.1.0      2021-01-25 [1] CRAN (R 4.2.0)
#>    fs            1.5.2      2021-12-08 [1] CRAN (R 4.2.0)
#>    generics      0.1.3      2022-07-05 [1] CRAN (R 4.2.1)
#>    glue          1.6.2      2022-02-24 [1] CRAN (R 4.2.0)
#>  P graphics    * 4.2.2      2022-10-31 [1] local
#>  P grDevices   * 4.2.2      2022-10-31 [1] local
#>    htmltools     0.5.3      2022-07-18 [1] CRAN (R 4.2.1)
#>    jquerylib     0.1.4      2021-04-26 [1] CRAN (R 4.2.0)
#>    jsonlite      1.8.3      2022-10-21 [1] CRAN (R 4.2.1)
#>    knitr         1.40       2022-08-24 [1] CRAN (R 4.2.1)
#>    lifecycle     1.0.3      2022-10-07 [1] CRAN (R 4.2.1)
#>    magrittr    * 2.0.3      2022-03-30 [1] CRAN (R 4.2.0)
#>    memoise       2.0.1      2021-11-26 [1] CRAN (R 4.2.0)
#>  P methods     * 4.2.2      2022-10-31 [1] local
#>    pillar        1.8.1      2022-08-19 [1] CRAN (R 4.2.1)
#>    pkgconfig     2.0.3      2019-09-22 [1] CRAN (R 4.2.0)
#>    purrr       * 0.3.5      2022-10-06 [1] CRAN (R 4.2.1)
#>    R6            2.5.1.9000 2022-10-27 [1] local
#>    rlang         1.0.6      2022-09-24 [1] CRAN (R 4.2.1)
#>    rmarkdown     2.18       2022-11-09 [1] CRAN (R 4.2.2)
#>    rstudioapi    0.14       2022-08-22 [1] CRAN (R 4.2.1)
#>    sass          0.4.2      2022-07-16 [1] CRAN (R 4.2.1)
#>    sessioninfo   1.2.2      2021-12-06 [1] CRAN (R 4.2.0)
#>  P stats       * 4.2.2      2022-10-31 [1] local
#>    stringi       1.7.8      2022-07-11 [1] CRAN (R 4.2.1)
#>    stringr       1.4.1      2022-08-20 [1] CRAN (R 4.2.1)
#>    tibble        3.1.8.9002 2022-10-16 [1] local
#>    tidyselect    1.2.0      2022-10-10 [1] CRAN (R 4.2.1)
#>  P tools         4.2.2      2022-10-31 [1] local
#>    utf8          1.2.2      2021-07-24 [1] CRAN (R 4.2.0)
#>  P utils       * 4.2.2      2022-10-31 [1] local
#>    vctrs         0.5.0      2022-10-22 [1] CRAN (R 4.2.1)
#>    withr         2.5.0      2022-03-03 [1] CRAN (R 4.2.0)
#>    xfun          0.34       2022-10-18 [1] CRAN (R 4.2.1)
#>    xml2          1.3.3.9000 2022-10-10 [1] local
#>    yaml          2.3.6      2022-10-18 [1] CRAN (R 4.2.1)
#> 
#>  [1] /Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library
#> 
#>  P ── Loaded and on-disk path mismatch.
#> 
#> ──────────────────────────────────────────────────────────
```
