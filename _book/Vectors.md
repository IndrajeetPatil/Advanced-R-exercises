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

