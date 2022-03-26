# Conditions



### Exercises 8.2.4

**Q1.** Write a wrapper around `file.remove()` that throws an error if the file to be deleted does not exist.

**Q2.** What does the `appendLF` argument to `message()` do? How is it related to `cat()`?

### Exercises 8.4.5

**Q1.** What extra information does the condition generated by `abort()` contain compared to the condition generated by `stop()` i.e. what's the difference between these two objects? Read the help for `?abort` to learn more.


```r
catch_cnd(stop("An error"))
catch_cnd(abort("An error"))
```

**Q2.** Predict the results of evaluating the following code


```r
show_condition <- function(code) {
  tryCatch(
    error = function(cnd) "error",
    warning = function(cnd) "warning",
    message = function(cnd) "message",
    {
      code
      NULL
    }
  )
}

show_condition(stop("!"))
show_condition(10)
show_condition(warning("?!"))
show_condition({
  10
  message("?")
  warning("?!")
})
```

**Q3.** Explain the results of running this code:


```r
withCallingHandlers(
  message = function(cnd) message("b"),
  withCallingHandlers(
    message = function(cnd) message("a"),
    message("c")
  )
)
#> b
#> a
#> b
#> c
```

**Q4.** Read the source code for `catch_cnd()` and explain how it works.

**Q5.** How could you rewrite `show_condition()` to use a single handler?

### Exercises 8.5.4

**Q1.** Inside a package, it's occasionally useful to check that a package is installed before using it. Write a function that checks if a package is installed (with `requireNamespace("pkg", quietly = FALSE))` and if not, throws a custom condition that includes the package name in the metadata.

**Q2.** Inside a package you often need to stop with an error when something is not right. Other packages that depend on your package might be tempted to check these errors in their unit tests. How could you help these packages to avoid relying on the error message which is part of the user interface rather than the API and might change without notice?

### Exercises 8.6.6

**Q1.** Create `suppressConditions()` that works like `suppressMessages()` and  `suppressWarnings()` but suppresses everything. Think carefully about how you should handle errors.

**Q2.** Compare the following two implementations of `message2error()`. What is the main advantage of `withCallingHandlers()` in this scenario? (Hint: look carefully at the traceback.)


```r
message2error <- function(code) {
  withCallingHandlers(code, message = function(e) stop(e))
}
message2error <- function(code) {
  tryCatch(code, message = function(e) stop(e))
}
```

**Q3.** How would you modify the `catch_cnds()` definition if you wanted to recreate the original intermingling of warnings and messages?

**Q4.**  Why is catching interrupts dangerous? Run this code to find out.


```r
bottles_of_beer <- function(i = 99) {
  message(
    "There are ", i, " bottles of beer on the wall, ",
    i, " bottles of beer."
  )
  while (i > 0) {
    tryCatch(
      Sys.sleep(1),
      interrupt = function(err) {
        i <<- i - 1
        if (i > 0) {
          message(
            "Take one down, pass it around, ", i,
            " bottle", if (i > 1) "s", " of beer on the wall."
          )
        }
      }
    )
  }
  message(
    "No more bottles of beer on the wall, ",
    "no more bottles of beer."
  )
}
```