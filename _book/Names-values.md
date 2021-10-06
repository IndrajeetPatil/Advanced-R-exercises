# Names and values

## 2.2.2 Exercises 

### Q1. Explain the relationship {-}


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
#> [1] "0x289b5c60"
obj_addr(b)
#> [1] "0x289b5c60"
obj_addr(c)
#> [1] "0x289b5c60"
obj_addr(d)
#> [1] "0x28ab4020"
```

### Q2. Function object address {-}

Following code verifies that indeed these calls all point to the same underlying function object.


```r
obj_addr(mean)
#> [1] "0x17e31fe0"
obj_addr(base::mean)
#> [1] "0x17e31fe0"
obj_addr(get("mean"))
#> [1] "0x17e31fe0"
obj_addr(evalq(mean))
#> [1] "0x17e31fe0"
obj_addr(match.fun("mean"))
#> [1] "0x17e31fe0"
```

### Q3. Converting non-syntactic names  {-}

The conversion of non-syntactic names to syntactic ones can sometimes corrupt the data. Some datasets may require non-syntactic names.

To suppress this behavior, one can set `check.names = FALSE`.

### Q4. Behavior of `make.names()`  {-}

It just prepends `X` in non-syntactic names and invalid characters (like `@`) are translated to `.`.


```r
make.names(c("123abc", "@me", "_yu", "  gh", "else"))
#> [1] "X123abc" "X.me"    "X_yu"    "X..gh"   "else."
```

### Q5. Why is `.123e1` not a syntactic name?  {-}

Because it is parsed as a number.


```r
.123e1 < 1
#> [1] FALSE
```

## 2.3.6 Exercises 

### Q1. Usefulness of `tracemem()` {-}

`tracemem()` traces copying of objects in R, but since the object created here is not assigned a name, there is nothing to trace. 


```r
tracemem(1:10)
#> [1] "<00000000297646B8>"
```

### Q2. Why two copies when you run this code? {-}

Were it not for `4` being a double - and not an integer (`4L`) - this would have been modified in place.


```r
x <- c(1L, 2L, 3L)
tracemem(x)
#> [1] "<00000000130378D8>"

x[[3]] <- 4
#> tracemem[0x00000000130378d8 -> 0x0000000013055948]: eval eval withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir eng_r block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> do.call eval eval eval eval eval.parent local 
#> tracemem[0x0000000013055948 -> 0x0000000013060e18]: eval eval withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir eng_r block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> do.call eval eval eval eval eval.parent local
```

Try with integer:


```r
x <- c(1L, 2L, 3L)
tracemem(x)
#> [1] "<00000000130AABC0>"

x[[3]] <- 4L
#> tracemem[0x00000000130aabc0 -> 0x00000000130db480]: eval eval withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir eng_r block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> do.call eval eval eval eval eval.parent local
```

As for why this still produces a copy, this is from Solutions manual:

> Please be aware that running this code in RStudio will result in additional copies because of the reference from the environment pane.

### Q3. Study relationship {-}


```r
a <- 1:10
b <- list(a, a)
c <- list(b, a, 1:10)

ref(a)
#> [1:0x17ca4ba8] <int>

ref(b)
#> o [1:0x243ee488] <list> 
#> +-[2:0x17ca4ba8] <int> 
#> \-[2:0x17ca4ba8]

ref(c)
#> o [1:0x285ee4e8] <list> 
#> +-o [2:0x243ee488] <list> 
#> | +-[3:0x17ca4ba8] <int> 
#> | \-[3:0x17ca4ba8] 
#> +-[3:0x17ca4ba8] 
#> \-[4:0x17b4ed20] <int>
```

### Q4. List inside another list {-}


```r
x <- list(1:10)
x
#> [[1]]
#>  [1]  1  2  3  4  5  6  7  8  9 10
obj_addr(x)
#> [1] "0x28808ce8"

x[[2]] <- x
x
#> [[1]]
#>  [1]  1  2  3  4  5  6  7  8  9 10
#> 
#> [[2]]
#> [[2]][[1]]
#>  [1]  1  2  3  4  5  6  7  8  9 10
obj_addr(x)
#> [1] "0x17bd2218"

ref(x)
#> o [1:0x17bd2218] <list> 
#> +-[2:0x28586318] <int> 
#> \-o [3:0x28808ce8] <list> 
#>   \-[2:0x28586318]
```

Figure here:
<https://advanced-r-solutions.rbind.io/images/names_values/copy_on_modify_fig2.png>

## 2.4.1 Exercises 

### Q1. Object size difference between `{base}` and `{lobstr}` {-}

> This function...does not detect if elements of a list are shared.


```r
y <- rep(list(runif(1e4)), 100)

object.size(y)
#> 8005648 bytes

obj_size(y)
#> 80,896 B
```

### Q2. Misleading object size {-}

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

### Q3. Predict object sizes {-}


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

### Q1. Why not a circular list? {-}

Copy-on-modify prevents the creation of a circular list.


```r
x <- list()

obj_addr(x)
#> [1] "0x29c1d6a0"

tracemem(x)
#> [1] "<0000000029C1D6A0>"

x[[1]] <- x
#> tracemem[0x0000000029c1d6a0 -> 0x0000000029d242b8]: eval eval withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir eng_r block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> do.call eval eval eval eval eval.parent local

obj_addr(x[[1]])
#> [1] "0x29c1d6a0"
```

### Q2. Why are loops so slow {-}

<!-- TODO -->


```r
library(bench)
```


### Q3. `tracemem()` on an environment {-}

It doesn't work and the documentation makes it clear as to why:

> It is not useful to trace NULL, environments, promises, weak references, or external pointer objects, as these are not duplicated


```r
e <- rlang::env(a = 1, b = "3")
tracemem(e)
#> Error in tracemem(e): 'tracemem' is not useful for promise and environment objects
```