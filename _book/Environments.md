# Environments

<!-- ```{r, include = FALSE, eval=FALSE} -->
<!-- # don't include because otherwise all loaded packages will  -->
<!-- # show up in search path for environments -->
<!-- source("common.R") -->
<!-- ``` -->

Attaching the needed libraries:


```r
library(rlang, warn.conflicts = FALSE)
```

### Exercises 7.2.7

**Q1.** List three ways in which an environment differs from a list.

**A1.** As mentioned in the book, here are three ways in which environments differ from lists:

Property | List | Environment
:-------:|:-----:|:---------:
semantics | value | reference
data structure | linear | non-linear
duplicated names | allowed | not allowed
has parent? | false | true
can contain itself? | false | true

**Q2.** Create an environment as illustrated by this picture.

<img src="diagrams/environments/recursive-1.png" width="177" />

**A2.** Creating the environment illustrated in the picture:


```r
library(rlang)

e <- env()
e$loop <- e
env_print(e)
#> <environment: 0x14a34e710>
#> Parent: <environment: global>
#> Bindings:
#> • loop: <env>

# should be the same as the `e` memory address
lobstr::obj_addr(e$loop)
#> [1] "0x14a34e710"
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
#> [1] "0x10f8b3c10" "0x10f8b3c10"
lobstr::obj_addrs(list(e2, e1$loop))
#> [1] "0x10f9216d0" "0x10f9216d0"
```

**Q4.** Explain why `e[[1]]` and `e[c("a", "b")]` don't make sense when `e` is an environment.

**A4.** An environment is a non-linear data structure, and has no concept of ordered elements. Therefore, indexing it (e.g. `e[[1]]`) doesn't make sense.

Subsetting a list or a vector returns a subset of the underlying data structure. So, subsetting a vector returns another vector. But it's unclear what subsetting an environment (e.g. `e[c("a", "b")]`) should return because there is no data structure to contain its returns. It can't be another environment since environments have reference semantics.

**Q5.** Create a version of `env_poke()` that will only bind new names, never re-bind old names. Some programming languages only do this, and are known as [single assignment languages][https://en.wikipedia.org/wiki/Assignment_(computer_science)#Single_assignment].

**A5.** Create a version of `env_poke()` that doesn't allow re-binding old names:


```r
env_poke2 <- function(env, nm, value) {
  if (nm %in% names(env)) {
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

But `rebind()` function will let us know if the binding doesn't exist, which is much safer way to super-assign:


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
exists("a")
#> [1] TRUE

# so function will produce an error instead of creating it for us
rebind("a", 10)

# all good
a <- 5
rebind("a", 10)
a
#> [1] 10
```

### Exercises 7.3.1

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

library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
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
#> <bytecode: 0x12fa031a0>
#> <environment: namespace:base>

mean <- 5
fget("mean", inherits = FALSE)
#> Error: No function objects with matching name was found.

mean <- function() NULL
fget("mean", inherits = FALSE)
#> function() NULL
rm("mean")
```

### Exercises 7.4.5

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
#> [[11]] $ <env: org:r-lib>
#> [[12]] $ <env: package:base>
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
#> [[10]] $ <env: org:r-lib>
#> [[11]] $ <env: package:base>
#> [[12]] $ <env: empty>
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

**A2.** I don't have access to the graphics software used to create diagrams in the book, so I am linking the diagram from the official solutions manual:

<img src="https://raw.githubusercontent.com/Tazinho/Advanced-R-Solutions/main/images/environments/function_environments_corrected.png" width="100%" />

**Q3.** Write an enhanced version of `str()` that provides more information about functions. Show where the function was found and what environment it was defined in.

**A3.** To write the required function, we can first re-purpose the `fget()` function we wrote above to return not the found function, but to return the environment in which it was found and its enclosing environment:


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

We can now write the new version of `str()` as a wrapper around this function. We only need to foresee that users might enter the function name either as a symbol or a string.


```r
str_function <- function(.f) {
  fget2(as_string(ensym(.f)))
}

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

### Exercises 7.5.5

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

The MVP here is `rlang::caller_env()`, so let's also have a look at its definition:


```r
rlang::caller_env
#> function (n = 1) 
#> {
#>     parent.frame(n + 1)
#> }
#> <bytecode: 0x12fd5b270>
#> <environment: namespace:rlang>
```

As can be seen, it defines the caller frame/environment as the first ancestor of the parent frame/environment. We can vary `n` to change this and see how the caller environment changes:


```r
explore_caller_env <- function() {
  print(rlang::caller_env(1))

  print(rlang::caller_env(0))
  return(rlang::current_env()) # execution environment
}

explore_caller_env()
#> <environment: R_GlobalEnv>
#> <environment: 0x14991bcd0>
#> <environment: 0x14991bcd0>

rlang::fn_env(explore_caller_env)
#> <environment: R_GlobalEnv>

rm("explore_caller_env")
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
