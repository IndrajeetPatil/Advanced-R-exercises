# Environments

<!-- ```{r, include = FALSE, eval=FALSE} -->
<!-- # don't include because otherwise all loaded packages will  -->
<!-- # show up in search path for environments -->
<!-- source("common.R") -->
<!-- ``` -->

Loading the needed libraries:


```r
library(rlang, warn.conflicts = FALSE)
```

## Environment basics (Exercises 7.2.7)

**Q1.** List three ways in which an environment differs from a list.

**A1.** As mentioned in the book, here are a few ways in which environments differ from lists:

|      Property       |  List   | Environment |
| :-----------------: | :-----: | :---------: |
|      semantics      |  value  |  reference  |
|   data structure    | linear  | non-linear  |
|  duplicated names   | allowed | not allowed |
|  can have parents?  |  false  |    true     |
| can contain itself? |  false  |    true     |

**Q2.** Create an environment as illustrated by this picture.

<img src="diagrams/environments/recursive-1.png" width="177" />

**A2.** Creating the environment illustrated in the picture:


```r
library(rlang)

e <- env()
e$loop <- e
env_print(e)
#> <environment: 0x104844f10>
#> Parent: <environment: global>
#> Bindings:
#> • loop: <env>
```

The binding `loop` should have the same memory address as the environment `e`:


```r
lobstr::ref(e$loop)
#> █ [1:0x104844f10] <env> 
#> └─loop = [1:0x104844f10]
```

**Q3.** Create a pair of environments as illustrated by this picture.

<img src="diagrams/environments/recursive-2.png" width="307" />

**A3.** Creating the specified environment:


```r
e1 <- env()
e2 <- env()

e1$loop <- e2
e2$deloop <- e1

# following should be the same
lobstr::obj_addrs(list(e1, e2$deloop))
#> [1] "0x1075daa18" "0x1075daa18"
lobstr::obj_addrs(list(e2, e1$loop))
#> [1] "0x107dca038" "0x107dca038"
```

**Q4.** Explain why `e[[1]]` and `e[c("a", "b")]` don't make sense when `e` is an environment.

**A4.** An environment is a non-linear data structure, and has no concept of ordered elements. Therefore, indexing it (e.g. `e[[1]]`) doesn't make sense.

Subsetting a list or a vector returns a subset of the underlying data structure. For example, subsetting a vector returns another vector. But it's unclear what subsetting an environment (e.g. `e[c("a", "b")]`) should return because there is no data structure to contain its returns. It can't be another environment since environments have reference semantics.

**Q5.** Create a version of `env_poke()` that will only bind new names, never re-bind old names. Some programming languages only do this, and are known as [single assignment languages](https://en.wikipedia.org/wiki/Assignment_(computer_science)#Single_assignment).

**A5.** Create a version of `env_poke()` that doesn't allow re-binding old names:


```r
env_poke2 <- function(env, nm, value) {
  if (env_has(env, nm)) {
    abort("Can't re-bind existing names.")
  }

  env_poke(env, nm, value)
}
```

Making sure that it behaves as expected:


```r
e <- env(a = 1, b = 2, c = 3)

# re-binding old names not allowed
env_poke2(e, "b", 4)
#> Error in `env_poke2()`:
#> ! Can't re-bind existing names.

# binding new names allowed
env_poke2(e, "d", 8)
e$d
#> [1] 8
```

Contrast this behavior with the following:


```r
e <- env(a = 1, b = 2, c = 3)

e$b
#> [1] 2

# re-binding old names allowed
env_poke(e, "b", 4)
e$b
#> [1] 4
```

**Q6.** What does this function do? How does it differ from `<<-` and why might you prefer it?


```r
rebind <- function(name, value, env = caller_env()) {
  if (identical(env, empty_env())) {
    stop("Can't find `", name, "`", call. = FALSE)
  } else if (env_has(env, name)) {
    env_poke(env, name, value)
  } else {
    rebind(name, value, env_parent(env))
  }
}
rebind("a", 10)
#> Error: Can't find `a`
a <- 5
rebind("a", 10)
a
#> [1] 10
```

**A6.** The downside of `<<-` is that it will create a new binding if it doesn't exist in the given environment, which is something that we may not wish:


```r
# `x` doesn't exist
exists("x")
#> [1] FALSE

# so `<<-` will create one for us
{
  x <<- 5
}

# in the global environment
env_has(global_env(), "x")
#>    x 
#> TRUE
x
#> [1] 5
```

But `rebind()` function will let us know if the binding doesn't exist, which is much safer:


```r
rebind <- function(name, value, env = caller_env()) {
  if (identical(env, empty_env())) {
    stop("Can't find `", name, "`", call. = FALSE)
  } else if (env_has(env, name)) {
    env_poke(env, name, value)
  } else {
    rebind(name, value, env_parent(env))
  }
}

# doesn't exist
exists("abc")
#> [1] FALSE

# so function will produce an error instead of creating it for us
rebind("abc", 10)
#> Error: Can't find `abc`

# but it will work as expected when the variable already exists
abc <- 5
rebind("abc", 10)
abc
#> [1] 10
```

## Recursing over environments (Exercises 7.3.1)

**Q1.** Modify `where()` to return _all_ environments that contain a binding for `name`. Carefully think through what type of object the function will need to return.

**A1.** Here is a modified version of `where()` that returns _all_ environments that contain a binding for `name`.

Since we anticipate more than one environment, we dynamically update a list each time an environment with the specified binding is found. It is important to initialize to an empty list since that signifies that given binding is not found in any of the environments.


```r
where <- function(name, env = caller_env()) {
  env_list <- list()

  while (!identical(env, empty_env())) {
    if (env_has(env, name)) {
      env_list <- append(env_list, env)
    }

    env <- env_parent(env)
  }

  return(env_list)
}
```

Let's try it out:


```r
where("yyy")
#> list()

x <- 5
where("x")
#> [[1]]
#> <environment: R_GlobalEnv>

where("mean")
#> [[1]]
#> <environment: base>

library(dplyr, warn.conflicts = FALSE)
where("filter")
#> [[1]]
#> <environment: package:dplyr>
#> attr(,"name")
#> [1] "package:dplyr"
#> attr(,"path")
#> [1] "/Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library/dplyr"
#> 
#> [[2]]
#> <environment: package:stats>
#> attr(,"name")
#> [1] "package:stats"
#> attr(,"path")
#> [1] "/Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library/stats"
detach("package:dplyr")
```

**Q2.** Write a function called `fget()` that finds only function objects. It should have two arguments, `name` and `env`, and should obey the regular scoping rules for functions: if there's an object with a matching name that's not a function, look in the parent. For an added challenge, also add an `inherits` argument which controls whether the function recurses up the parents or only looks in one environment.

**A2.** Here is a function that recursively looks for function objects:


```r
fget <- function(name, env = caller_env(), inherits = FALSE) {
  # we need only function objects
  f_value <- mget(name,
    envir = env,
    mode = "function",
    inherits = FALSE, # since we have our custom argument
    ifnotfound = list(NULL)
  )

  if (!is.null(f_value[[1]])) {
    # success case
    f_value[[1]]
  } else {
    if (inherits && !identical(env, empty_env())) {
      # recursive case
      env <- env_parent(env)
      fget(name, env, inherits = TRUE)
    } else {
      # base case
      stop("No function objects with matching name was found.", call. = FALSE)
    }
  }
}
```

Let's try it out:


```r
fget("mean", inherits = FALSE)
#> Error: No function objects with matching name was found.

fget("mean", inherits = TRUE)
#> function (x, ...) 
#> UseMethod("mean")
#> <bytecode: 0x125efc430>
#> <environment: namespace:base>

mean <- 5
fget("mean", inherits = FALSE)
#> Error: No function objects with matching name was found.

mean <- function() NULL
fget("mean", inherits = FALSE)
#> function() NULL
rm("mean")
```

## Special environments (Exercises 7.4.5)

**Q1.** How is `search_envs()` different from `env_parents(global_env())`?

**A1.** The `search_envs()` lists a chain of environments currently attached to the search path and contains exported functions from these packages. The search path always ends at the `{base}` package environment. The search path also includes the global environment.


```r
search_envs()
#>  [[1]] $ <env: global>
#>  [[2]] $ <env: package:rlang>
#>  [[3]] $ <env: package:magrittr>
#>  [[4]] $ <env: package:stats>
#>  [[5]] $ <env: package:graphics>
#>  [[6]] $ <env: package:grDevices>
#>  [[7]] $ <env: package:utils>
#>  [[8]] $ <env: package:datasets>
#>  [[9]] $ <env: package:methods>
#> [[10]] $ <env: Autoloads>
#> [[11]] $ <env: package:base>
```

The `env_parents()` lists all parent environments up until the empty environment. Of course, the global environment itself is not included in this list.


```r
env_parents(global_env())
#>  [[1]] $ <env: package:rlang>
#>  [[2]] $ <env: package:magrittr>
#>  [[3]] $ <env: package:stats>
#>  [[4]] $ <env: package:graphics>
#>  [[5]] $ <env: package:grDevices>
#>  [[6]] $ <env: package:utils>
#>  [[7]] $ <env: package:datasets>
#>  [[8]] $ <env: package:methods>
#>  [[9]] $ <env: Autoloads>
#> [[10]] $ <env: package:base>
#> [[11]] $ <env: empty>
```

**Q2.** Draw a diagram that shows the enclosing environments of this function:


```r
f1 <- function(x1) {
  f2 <- function(x2) {
    f3 <- function(x3) {
      x1 + x2 + x3
    }
    f3(3)
  }
  f2(2)
}
f1(1)
```

**A2.** I don't have access to the graphics software used to create diagrams in the book, so I am linking the diagram from the [official solutions manual](https://advanced-r-solutions.rbind.io/environments.html#special-environments), where you will also find a more detailed description for the figure:

<img src="https://raw.githubusercontent.com/Tazinho/Advanced-R-Solutions/main/images/environments/function_environments_corrected.png" width="100%" />

**Q3.** Write an enhanced version of `str()` that provides more information about functions. Show where the function was found and what environment it was defined in.

**A3.** To write the required function, we can first re-purpose the `fget()` function we wrote above to return the environment in which it was found and its enclosing environment:


```r
fget2 <- function(name, env = caller_env()) {
  # we need only function objects
  f_value <- mget(name,
    envir = env,
    mode = "function",
    inherits = FALSE,
    ifnotfound = list(NULL)
  )

  if (!is.null(f_value[[1]])) {
    # success case
    list(
      "where" = env,
      "enclosing" = fn_env(f_value[[1]])
    )
  } else {
    if (!identical(env, empty_env())) {
      # recursive case
      env <- env_parent(env)
      fget2(name, env)
    } else {
      # base case
      stop("No function objects with matching name was found.", call. = FALSE)
    }
  }
}
```

Let's try it out:


```r
fget2("mean")
#> $where
#> <environment: base>
#> 
#> $enclosing
#> <environment: namespace:base>

mean <- function() NULL
fget2("mean")
#> $where
#> <environment: R_GlobalEnv>
#> 
#> $enclosing
#> <environment: R_GlobalEnv>
rm("mean")
```

We can now write the new version of `str()` as a wrapper around this function. We only need to foresee that the users might enter the function name either as a symbol or a string.


```r
str_function <- function(.f) {
  fget2(as_string(ensym(.f)))
}
```

Let's first try it with `base::mean()`:


```r
str_function(mean)
#> $where
#> <environment: base>
#> 
#> $enclosing
#> <environment: namespace:base>

str_function("mean")
#> $where
#> <environment: base>
#> 
#> $enclosing
#> <environment: namespace:base>
```

And then with our variant present in the global environment:


```r
mean <- function() NULL

str_function(mean)
#> $where
#> <environment: R_GlobalEnv>
#> 
#> $enclosing
#> <environment: R_GlobalEnv>

str_function("mean")
#> $where
#> <environment: R_GlobalEnv>
#> 
#> $enclosing
#> <environment: R_GlobalEnv>

rm("mean")
```

## Call stacks (Exercises 7.5.5)

**Q1.** Write a function that lists all the variables defined in the environment in which it was called. It should return the same results as `ls()`.

**A1.** Here is a function that lists all the variables defined in the environment in which it was called:


```r
# let's first remove everything that exists in the global environment right now
# to test with only newly defined objects
rm(list = ls())
rm(.Random.seed, envir = globalenv())

ls_env <- function(env = rlang::caller_env()) {
  sort(rlang::env_names(env))
}
```

The workhorse here is `rlang::caller_env()`, so let's also have a look at its definition:


```r
rlang::caller_env
#> function (n = 1) 
#> {
#>     parent.frame(n + 1)
#> }
#> <bytecode: 0x124f2f3c8>
#> <environment: namespace:rlang>
```

Let's try it out:

- In global environment:


```r
x <- "a"
y <- 1

ls_env()
#> [1] "ls_env" "x"      "y"

ls()
#> [1] "ls_env" "x"      "y"
```

- In function environment:


```r
foo <- function() {
  a <- "x"
  b <- 2

  print(ls_env())

  print(ls())
}

foo()
#> [1] "a" "b"
#> [1] "a" "b"
```

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
#>    crayon        1.5.2      2022-09-29 [1] CRAN (R 4.2.1)
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
#>    highr         0.9        2021-04-16 [1] CRAN (R 4.2.0)
#>    htmltools     0.5.3      2022-07-18 [1] CRAN (R 4.2.1)
#>    jquerylib     0.1.4      2021-04-26 [1] CRAN (R 4.2.0)
#>    jsonlite      1.8.3      2022-10-21 [1] CRAN (R 4.2.1)
#>    knitr         1.40       2022-08-24 [1] CRAN (R 4.2.1)
#>    lifecycle     1.0.3      2022-10-07 [1] CRAN (R 4.2.1)
#>    lobstr        1.1.2      2022-06-22 [1] CRAN (R 4.2.0)
#>    magrittr    * 2.0.3      2022-03-30 [1] CRAN (R 4.2.0)
#>    memoise       2.0.1      2021-11-26 [1] CRAN (R 4.2.0)
#>  P methods     * 4.2.2      2022-10-31 [1] local
#>    pillar        1.8.1      2022-08-19 [1] CRAN (R 4.2.1)
#>    pkgconfig     2.0.3      2019-09-22 [1] CRAN (R 4.2.0)
#>    png           0.1-7      2013-12-03 [1] CRAN (R 4.2.0)
#>    R6            2.5.1.9000 2022-10-27 [1] local
#>    rlang       * 1.0.6      2022-09-24 [1] CRAN (R 4.2.1)
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

