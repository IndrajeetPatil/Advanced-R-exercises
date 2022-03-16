# Names and values

## 2.2.2 Exercises 

Q1. Explain the relationship


```r
a <- 1:10
b <- a
c <- b
d <- 1:10
```

All of these variable names are actively bound to the same value.


```r
library(lobstr)

obj_addr(a)
#> [1] "0x17380090"
obj_addr(b)
#> [1] "0x17380090"
obj_addr(c)
#> [1] "0x17380090"
obj_addr(d)
#> [1] "0x19340a28"
```

Q2. Function object address

Following code verifies that indeed these calls all point to the same underlying function object.


```r
obj_addr(mean)
#> [1] "0x18d86dd8"
obj_addr(base::mean)
#> [1] "0x18d86dd8"
obj_addr(get("mean"))
#> [1] "0x18d86dd8"
obj_addr(evalq(mean))
#> [1] "0x18d86dd8"
obj_addr(match.fun("mean"))
#> [1] "0x18d86dd8"
```

Q3. Converting non-syntactic names 

The conversion of non-syntactic names to syntactic ones can sometimes corrupt the data. Some datasets may require non-syntactic names.

To suppress this behavior, one can set `check.names = FALSE`.

Q4. Behavior of `make.names()` 

It just prepends `X` in non-syntactic names and invalid characters (like `@`) are translated to `.`.


```r
make.names(c("123abc", "@me", "_yu", "  gh", "else"))
#> [1] "X123abc" "X.me"    "X_yu"    "X..gh"   "else."
```

Q5. Why is `.123e1` not a syntactic name? 

Because it is parsed as a number.


```r
.123e1 < 1
#> [1] FALSE
```

## 2.3.6 Exercises 

Q1. Usefulness of `tracemem()`

`tracemem()` traces copying of objects in R, but since the object created here is not assigned a name, there is nothing to trace. 


```r
tracemem(1:10)
#> [1] "<0000000031656B78>"
```

Q2. Why two copies when you run this code?

Were it not for `4` being a double - and not an integer (`4L`) - this would have been modified in place.


```r
x <- c(1L, 2L, 3L)
tracemem(x)
#> [1] "<000000003184C7A8>"

x[[3]] <- 4
#> tracemem[0x000000003184c7a8 -> 0x0000000031905348]: eval eval eval_with_user_handlers withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir eng_r block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> do.call eval eval eval eval eval.parent local 
#> tracemem[0x0000000031905348 -> 0x00000000318a09d8]: eval eval eval_with_user_handlers withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir eng_r block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> do.call eval eval eval eval eval.parent local
```

Try with integer:


```r
x <- c(1L, 2L, 3L)
tracemem(x)
#> [1] "<0000000031AC4C18>"

x[[3]] <- 4L
#> tracemem[0x0000000031ac4c18 -> 0x0000000031b43078]: eval eval eval_with_user_handlers withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir eng_r block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> do.call eval eval eval eval eval.parent local
```

As for why this still produces a copy, this is from Solutions manual:

> Please be aware that running this code in RStudio will result in additional copies because of the reference from the environment pane.

Q3. Study relationship


```r
a <- 1:10
b <- list(a, a)
c <- list(b, a, 1:10)

ref(a)
#> [1:0x31eac3e0] <int>

ref(b)
#> o [1:0x31e9a9e8] <list> 
#> +-[2:0x31eac3e0] <int> 
#> \-[2:0x31eac3e0]

ref(c)
#> o [1:0x31f20398] <list> 
#> +-o [2:0x31e9a9e8] <list> 
#> | +-[3:0x31eac3e0] <int> 
#> | \-[3:0x31eac3e0] 
#> +-[3:0x31eac3e0] 
#> \-[4:0x31f6e000] <int>
```

Q4. List inside another list


```r
x <- list(1:10)
x
#> [[1]]
#>  [1]  1  2  3  4  5  6  7  8  9 10
obj_addr(x)
#> [1] "0x332e4eb8"

x[[2]] <- x
x
#> [[1]]
#>  [1]  1  2  3  4  5  6  7  8  9 10
#> 
#> [[2]]
#> [[2]][[1]]
#>  [1]  1  2  3  4  5  6  7  8  9 10
obj_addr(x)
#> [1] "0x33757e40"

ref(x)
#> o [1:0x33757e40] <list> 
#> +-[2:0x32d8cc90] <int> 
#> \-o [3:0x332e4eb8] <list> 
#>   \-[2:0x32d8cc90]
```

Figure here:
<https://advanced-r-solutions.rbind.io/images/names_values/copy_on_modify_fig2.png>

## 2.4.1 Exercises 

Q1. Object size difference between `{base}` and `{lobstr}`

> This function...does not detect if elements of a list are shared.


```r
y <- rep(list(runif(1e4)), 100)

object.size(y)
#> 8005648 bytes

obj_size(y)
#> 80,896 B
```

Q2. Misleading object size

These functions are not externally created objects in R, but are always available, so doesn't make much sense to measure their size.


```r
funs <- list(mean, sd, var)
obj_size(funs)
#> 17,608 B
```

Nevertheless, it's still interesting that the addition is not the same as size of list of those objects.


```r
obj_size(mean)
#> 1,184 B
obj_size(sd)
#> 4,480 B
obj_size(var)
#> 12,472 B

obj_size(mean) + obj_size(sd) + obj_size(var)
#> 18,136 B
```

Q3. Predict object sizes


```r
a <- runif(1e6)
obj_size(a)
#> 8,000,048 B

b <- list(a, a)
obj_size(b)
#> 8,000,112 B
obj_size(a, b)
#> 8,000,112 B

b[[1]][[1]] <- 10
obj_size(b)
#> 16,000,160 B
obj_size(a, b)
#> 16,000,160 B

b[[2]][[1]] <- 10
obj_size(b)
#> 16,000,160 B
obj_size(a, b)
#> 24,000,208 B
```

## 2.5.3 Exercises

Q1. Why not a circular list?

Copy-on-modify prevents the creation of a circular list.


```r
x <- list()

obj_addr(x)
#> [1] "0x322e7ba0"

tracemem(x)
#> [1] "<00000000322E7BA0>"

x[[1]] <- x
#> tracemem[0x00000000322e7ba0 -> 0x000000003241bf10]: eval eval eval_with_user_handlers withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir eng_r block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> do.call eval eval eval eval eval.parent local

obj_addr(x[[1]])
#> [1] "0x322e7ba0"
```

Q2. Why are loops so slow

<!-- TODO -->


```r
library(bench)
```


Q3. `tracemem()` on an environment

It doesn't work and the documentation makes it clear as to why:

> It is not useful to trace NULL, environments, promises, weak references, or external pointer objects, as these are not duplicated


```r
e <- rlang::env(a = 1, b = "3")
tracemem(e)
#> Error in tracemem(e): 'tracemem' is not useful for promise and environment objects
```
