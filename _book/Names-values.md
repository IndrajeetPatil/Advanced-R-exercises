# Names and values

##  2.2.2 Exercises

### Q1. Explain the relationship


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
#> [1] "0x12401c90"
obj_addr(b)
#> [1] "0x12401c90"
obj_addr(c)
#> [1] "0x12401c90"
obj_addr(d)
#> [1] "0x125000c0"
```

### Q2. Function object address

Following code verifies that indeed these calls all point to the same underlying function object.


```r
obj_addr(mean)
#> [1] "0x195916b8"
obj_addr(base::mean)
#> [1] "0x195916b8"
obj_addr(get("mean"))
#> [1] "0x195916b8"
obj_addr(evalq(mean))
#> [1] "0x195916b8"
obj_addr(match.fun("mean"))
#> [1] "0x195916b8"
```

### Q3. Converting non-syntactic names

The conversion of non-syntactic names to syntactic ones can sometimes corrupt the data. Some datasets may require non-syntactic names.

To suppress this behavior, one can set `check.names = FALSE`.

### Q4. Behavior of `make.names()`

It just prepends `X` in non-syntactic names and invalid characters (like `@`) are translated to `.`.


```r
make.names(c("123abc", "@me", "_yu", "  gh", "else"))
#> [1] "X123abc" "X.me"    "X_yu"    "X..gh"   "else."
```

### Q5. Why is `.123e1` not a syntactic name?

Because it is parsed as a number.


```r
.123e1 < 1
#> [1] FALSE
```

