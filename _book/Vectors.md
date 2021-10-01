# Vectors

## Exercise 3.2.5 

### Q1. Create raw and complex scalars {-}

The raw type holds raw bytes. For example,


```r
x <- "A string"

(y <- charToRaw(x))
#> [1] 41 20 73 74 72 69 6e 67

typeof(y)
#> [1] "raw"
```

You can use it to also figure out some encoding issues (both of these are scalars):


```r
charToRaw("\"")
#> [1] 22
charToRaw("”")
#> [1] 94
```

Complex vectors can be used to represent (surprise!) complex numbers.

Example of a complex scalar:


```r
(x <- complex(length.out = 1, real = 1, imaginary = 8))
#> [1] 1+8i

typeof(x)
#> [1] "complex"
```

### Q2. Vector coercion rules {-}

Usually, the more *general* type would take precedence.


```r
c(1, FALSE)
#> [1] 1 0

c("a", 1)
#> [1] "a" "1"

c(TRUE, 1L)
#> [1] 1 1
```

Let's try some more examples.


```r
c(1.0, 1L)
#> [1] 1 1

c(1.0, "1.0")
#> [1] "1"   "1.0"

c(TRUE, "1.0")
#> [1] "TRUE" "1.0"
```

### Q3. Comparisons between different types {-}

The coercion in vectors reveal why some of these comparisons return the results that they do.


```r
1 == "1"
#> [1] TRUE

c(1, "1")
#> [1] "1" "1"
```


```r
-1 < FALSE
#> [1] TRUE

c(-1, FALSE)
#> [1] -1  0
```


```r
"one" < 2
#> [1] FALSE

c("one", 2)
#> [1] "one" "2"

sort(c("one", 2))
#> [1] "2"   "one"
```

### Q4. Why `NA` defaults to `"logical"` type {-}

The `"logical"` type is the lowest in the coercion hierarchy.

So `NA` defaulting to any other type (e.g. `"numeric"`) would mean that any time there is a missing element in a vector, rest of the elements would be converted to a type higher in hierarchy, which would be problematic for types lower in hierarchy.


```r
typeof(NA)
#> [1] "logical"

c(FALSE, NA_character_)
#> [1] "FALSE" NA
```

### Q5. Misleading variants of `is.*` functions {-}

- `is.atomic()`:
- `is.numeric()`:
- `is.vector()`:


## Exercise 3.3.4

### Q1. Reading source code {-}


```r
setNames
#> function (object = nm, nm) 
#> {
#>     names(object) <- nm
#>     object
#> }
#> <bytecode: 0x0000000019046910>
#> <environment: namespace:stats>

setNames(c(1, 2), c("a", "b"))
#> a b 
#> 1 2
```


```r
unname
#> function (obj, force = FALSE) 
#> {
#>     if (!is.null(names(obj))) 
#>         names(obj) <- NULL
#>     if (!is.null(dimnames(obj)) && (force || !is.data.frame(obj))) 
#>         dimnames(obj) <- NULL
#>     obj
#> }
#> <bytecode: 0x00000000160f2848>
#> <environment: namespace:base>

A <- provideDimnames(N <- array(1:24, dim = 2:4))

unname(A, force = TRUE)
#> , , 1
#> 
#>      [,1] [,2] [,3]
#> [1,]    1    3    5
#> [2,]    2    4    6
#> 
#> , , 2
#> 
#>      [,1] [,2] [,3]
#> [1,]    7    9   11
#> [2,]    8   10   12
#> 
#> , , 3
#> 
#>      [,1] [,2] [,3]
#> [1,]   13   15   17
#> [2,]   14   16   18
#> 
#> , , 4
#> 
#>      [,1] [,2] [,3]
#> [1,]   19   21   23
#> [2,]   20   22   24
```

### Q2. 1-dimensional vector {-}

Dimensions for a 1-dimensional vector are `NULL`.

`NROW()` and `NCOL()` are helpful for getting dimensions for 1D vectors by treating them as if they were a data frame vectors.


```r
x <- character(0)

dim(x)
#> NULL

nrow(x)
#> NULL
NROW(x)
#> [1] 0

ncol(x)
#> NULL
NCOL(x)
#> [1] 1
```

### Q3. Difference between vectors and arrays {-}

`1:5` is a 1D vector without dimensions, while `x1`, `x2`, and `x3` are one-dimensional arrays.


```r
1:5
#> [1] 1 2 3 4 5
(x1 <- array(1:5, c(1, 1, 5)))
#> , , 1
#> 
#>      [,1]
#> [1,]    1
#> 
#> , , 2
#> 
#>      [,1]
#> [1,]    2
#> 
#> , , 3
#> 
#>      [,1]
#> [1,]    3
#> 
#> , , 4
#> 
#>      [,1]
#> [1,]    4
#> 
#> , , 5
#> 
#>      [,1]
#> [1,]    5
(x2 <- array(1:5, c(1, 5, 1)))
#> , , 1
#> 
#>      [,1] [,2] [,3] [,4] [,5]
#> [1,]    1    2    3    4    5
(x3 <- array(1:5, c(5, 1, 1)))
#> , , 1
#> 
#>      [,1]
#> [1,]    1
#> [2,]    2
#> [3,]    3
#> [4,]    4
#> [5,]    5
```

### Q4. About `structure()` {-}

From `?attributes` (emphasis mine):

> Note that some attributes (namely class, **comment**, dim, dimnames, names, row.names and tsp) are treated specially and have restrictions on the values which can be set.


```r
structure(1:5, x = "my attribute")
#> [1] 1 2 3 4 5
#> attr(,"x")
#> [1] "my attribute"

structure(1:5, comment = "my attribute")
#> [1] 1 2 3 4 5
```

