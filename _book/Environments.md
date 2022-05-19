# Environments

### Exercises 7.2.7

**Q1.** List three ways in which an environment differs from a list.

**A1.** As mentioned in the book, here are three ways in which environments differ from lists:

Property | List | Environment
:-------:|:-----:|:---------:
semantics | value | reference
data structure | linear | non-linear
duplicated names | allowed | not allowed
has parent? | false | true

**Q2.** Create an environment as illustrated by this picture.

<img src="diagrams/environments/recursive-1.png" width="177" />

**A2.** Creating the specified environment:


```r
library(rlang)

e <- env()
e$loop <- e
env_print(e)
#> <environment: 0x12d4e4b98>
#> Parent: <environment: global>
#> Bindings:
#> • loop: <env>

# should be the same as the `e` memory address
lobstr::obj_addr(e$loop)
#> [1] "0x12d4e4b98"
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
#> [1] "0x12e79a168" "0x12e79a168"
lobstr::obj_addrs(list(e2, e1$loop))
#> [1] "0x12e7ed608" "0x12e7ed608"
```

**Q4.** Explain why `e[[1]]` and `e[c("a", "b")]` don't make sense when `e` is an environment.

**A4.** 

An environment is a non-linear data structure, and has no concept of ordered elements. Therefore, indexing it (e.g. `e[[1]]`) doesn't make sense.

Subsetting a list or a vector returns a subset of the underlying data structure. So, subsetting a vector returns another vector. But it's unclear what subsetting an environment (e.g. `e[c("a", "b")]`) should return because there is no data structure to contain its returns. It can't be another environment since environments have reference semantics.

**Q5.** Create a version of `env_poke()` that will only bind new names, never re-bind old names. Some programming languages only do this, and are known as [single assignment languages][https://en.wikipedia.org/wiki/Assignment_(computer_science)#Single_assignment].

**A5.** Create a version of `env_poke()` that doesn't allow re-binding old names:


```r
env_poke2 <- function(env, nm, value) {
  if (nm %in% names(env)) {
    rlang::abort("Can't re-bind existing names.")
  }
 
  rlang::env_poke(env, nm, value)
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
rlang::env_has(global_env(), "x")
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

**Q2.** Write a function called `fget()` that finds only function objects. It  should have two arguments, `name` and `env`, and should obey the regular scoping rules for functions: if there's an object with a matching name that's not a function, look in the parent. For an added challenge, also add an `inherits` argument which controls whether the function recurses up the parents or only looks in one environment.

### Exercises 7.4.5

**Q1.** How is `search_envs()` different from `env_parents(global_env())`?

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

**Q3.** Write an enhanced version of `str()` that provides more information about functions. Show where the function was found and what environment it was defined in.

### Exercises 7.5.5

**Q1.** Write a function that lists all the variables defined in the environment in which it was called. It should return the same results as `ls()`.
