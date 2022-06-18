# Vectors



## Exercises 3.2.5 

**Q1.** How do you create raw and complex scalars? (See `?raw` and `?complex`.)

**A1.** 

- raw vectors

The raw type holds raw bytes. For example,


```r
x <- "A string"

(y <- charToRaw(x))
#> [1] 41 20 73 74 72 69 6e 67

typeof(y)
#> [1] "raw"
```

You can use it to also figure out differences between characters that might look quite similar:


```r
charToRaw("–") # en-dash
#> [1] e2 80 93
charToRaw("—") # em-dash
#> [1] e2 80 94
```

- complex vectors

Complex vectors can be used to represent (surprise!) complex numbers.

Example of a complex scalar:


```r
(x <- complex(length.out = 1, real = 1, imaginary = 8))
#> [1] 1+8i

typeof(x)
#> [1] "complex"
```

**Q2.** Test your knowledge of the vector coercion rules by predicting the output of the following uses of `c()`:


```r
c(1, FALSE)
c("a", 1)
c(TRUE, 1L)
```

**A2.** Usually, the more *general* type would take precedence.


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

**Q3.** Why is `1 == "1"` true? Why is `-1 < FALSE` true? Why is `"one" < 2` false?

**A3.** The coercion rules for vectors reveal why some of these comparisons return the results that they do.


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

**Q4.** Why is the default missing value, `NA`, a logical vector? What's special about logical vectors? (Hint: think about `c(FALSE, NA_character_)`.)

**A4.** The `"logical"` type is the lowest in the coercion hierarchy.

So `NA` defaulting to any other type (e.g. `"numeric"`) would mean that any time there is a missing element in a vector, rest of the elements would be converted to a type higher in hierarchy, which would be problematic for types lower in hierarchy.


```r
typeof(NA)
#> [1] "logical"

c(FALSE, NA_character_)
#> [1] "FALSE" NA
```

**Q5.** Precisely what do `is.atomic()`, `is.numeric()`, and `is.vector()` test for?

**A5.** 

- `is.atomic()`

This functions checks if the object is of atomic *type* (or `NULL`), and not if it is an atomic *vector*.

Quoting docs:

> `is.atomic` is true for the atomic types ("logical", "integer", "numeric", "complex", "character" and "raw") and `NULL`.


```r
is.atomic(NULL)
#> [1] TRUE

is.vector(NULL)
#> [1] FALSE
```

- `is.numeric()`

Its documentation says:

> `is.numeric` should only return true if the base type of the class is `double` or `integer` and values can reasonably be regarded as `numeric`

Therefore, this function only checks for `double` and `integer` base types and not other types based on top of these types (`factor`, `Date`, `POSIXt`, or `difftime`).


```r
x <- factor(c(1L, 2L))

is.numeric(x)
#> [1] FALSE
```

- `is.vector()`

As the documentation for this function reveals:

> `is.vector` returns `TRUE` if `x` is a vector of the specified mode having no attributes *other than names*. It returns `FALSE` otherwise.

Thus, the function can be incorrect in presence if the object has attributes other than `names`.


```r
x <- c("x" = 1, "y" = 2)

is.vector(x)
#> [1] TRUE

attr(x, "m") <- "abcdef"

is.vector(x)
#> [1] FALSE
```

A better way to check for a vector:


```r
is.null(dim(x))
#> [1] TRUE
```

## Exercises 3.3.4

**Q1.** How is `setNames()` implemented? How is `unname()` implemented? Read the source code.

**A1.**


```r
setNames
#> function (object = nm, nm) 
#> {
#>     names(object) <- nm
#>     object
#> }
#> <bytecode: 0x137667fe0>
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
#> <bytecode: 0x116d8e0e0>
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

**Q2.** What does `dim()` return when applied to a 1-dimensional vector? When might you use `NROW()` or `NCOL()`?

**A2.** Dimensions for a 1-dimensional vector are `NULL`.

`NROW()` and `NCOL()` are helpful for getting dimensions for 1D vectors by treating them as if they were matrices or dataframes.


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

**Q3.** How would you describe the following three objects? What makes them different from `1:5`?


```r
x1 <- array(1:5, c(1, 1, 5))
x2 <- array(1:5, c(1, 5, 1))
x3 <- array(1:5, c(5, 1, 1))
```

**A3.**

- `1:5` is a dimensionless **vector** 
- `x1`, `x2`, and `x3` are one-dimensional **array** 


```r
(x <- 1:5)
#> [1] 1 2 3 4 5
dim(x)
#> NULL

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

dim(x1)
#> [1] 1 1 5
dim(x2)
#> [1] 1 5 1
dim(x3)
#> [1] 5 1 1
```

**Q4.** An early draft used this code to illustrate `structure()`:


```r
structure(1:5, comment = "my attribute")
#> [1] 1 2 3 4 5
```

But when you print that object you don't see the comment attribute. Why? Is the attribute missing, or is there something else special about it? (Hint: try using help.)

**A4.** From `?attributes` (emphasis mine):

> Note that some attributes (namely class, **comment**, dim, dimnames, names, row.names and tsp) are treated specially and have restrictions on the values which can be set.


```r
structure(1:5, x = "my attribute")
#> [1] 1 2 3 4 5
#> attr(,"x")
#> [1] "my attribute"

structure(1:5, comment = "my attribute")
#> [1] 1 2 3 4 5
```

## Exercises 3.4.5

**Q1.** What sort of object does `table()` return? What is its type? What attributes does it have? How does the dimensionality change as you tabulate more variables?

**A1.** `table()` returns an array with integer type and its dimensions scale with the number of variables present.


```r
(x <- table(mtcars$am))
#> 
#>  0  1 
#> 19 13
(y <- table(mtcars$am, mtcars$cyl))
#>    
#>      4  6  8
#>   0  3  4 12
#>   1  8  3  2
(z <- table(mtcars$am, mtcars$cyl, mtcars$vs))
#> , ,  = 0
#> 
#>    
#>      4  6  8
#>   0  0  0 12
#>   1  1  3  2
#> 
#> , ,  = 1
#> 
#>    
#>      4  6  8
#>   0  3  4  0
#>   1  7  0  0

# type
purrr::map(list(x, y, z), typeof)
#> [[1]]
#> [1] "integer"
#> 
#> [[2]]
#> [1] "integer"
#> 
#> [[3]]
#> [1] "integer"

# attributes
purrr::map(list(x, y, z), attributes)
#> [[1]]
#> [[1]]$dim
#> [1] 2
#> 
#> [[1]]$dimnames
#> [[1]]$dimnames[[1]]
#> [1] "0" "1"
#> 
#> 
#> [[1]]$class
#> [1] "table"
#> 
#> 
#> [[2]]
#> [[2]]$dim
#> [1] 2 3
#> 
#> [[2]]$dimnames
#> [[2]]$dimnames[[1]]
#> [1] "0" "1"
#> 
#> [[2]]$dimnames[[2]]
#> [1] "4" "6" "8"
#> 
#> 
#> [[2]]$class
#> [1] "table"
#> 
#> 
#> [[3]]
#> [[3]]$dim
#> [1] 2 3 2
#> 
#> [[3]]$dimnames
#> [[3]]$dimnames[[1]]
#> [1] "0" "1"
#> 
#> [[3]]$dimnames[[2]]
#> [1] "4" "6" "8"
#> 
#> [[3]]$dimnames[[3]]
#> [1] "0" "1"
#> 
#> 
#> [[3]]$class
#> [1] "table"
```

**Q2.** What happens to a factor when you modify its levels? 


```r
f1 <- factor(letters)
levels(f1) <- rev(levels(f1))
```

**A2.** Its levels changes but the underlying integer values remain the same.


```r
f1 <- factor(letters)
f1
#>  [1] a b c d e f g h i j k l m n o p q r s t u v w x y z
#> 26 Levels: a b c d e f g h i j k l m n o p q r s t u ... z
as.integer(f1)
#>  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18
#> [19] 19 20 21 22 23 24 25 26

levels(f1) <- rev(levels(f1))
f1
#>  [1] z y x w v u t s r q p o n m l k j i h g f e d c b a
#> 26 Levels: z y x w v u t s r q p o n m l k j i h g f ... a
as.integer(f1)
#>  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18
#> [19] 19 20 21 22 23 24 25 26
```

**Q3.** What does this code do? How do `f2` and `f3` differ from `f1`?


```r
f2 <- rev(factor(letters))
f3 <- factor(letters, levels = rev(letters))
```

**A3.** In this code:

`f2`: Only the underlying integers are reversed, but levels remain unchanged.
`f3`: Both the levels and the underlying integers are reversed.


```r
f2 <- rev(factor(letters))
f2
#>  [1] z y x w v u t s r q p o n m l k j i h g f e d c b a
#> 26 Levels: a b c d e f g h i j k l m n o p q r s t u ... z
as.integer(f2)
#>  [1] 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9
#> [19]  8  7  6  5  4  3  2  1

f3 <- factor(letters, levels = rev(letters))
f3
#>  [1] a b c d e f g h i j k l m n o p q r s t u v w x y z
#> 26 Levels: z y x w v u t s r q p o n m l k j i h g f ... a
as.integer(f3)
#>  [1] 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9
#> [19]  8  7  6  5  4  3  2  1
```

## Exercises 3.5.4

**Q1.** List all the ways that a list differs from an atomic vector.

**A1.** 

feature | atomic vector  | list (aka generic vector)
------- | -------------- | --------------
element type | unique | mixed^[a list can contain a mix of types]
recursive? | no | yes^[(a list can contain itself)]
return for out-of-bounds index | `NA`^[(e.g. `c(1)[2]`)] | `NULL`^[(e.g. `list(1)[2]`)]
memory address | single memory reference^[`lobstr::ref(c(1, 2))`] | reference per list element^[`lobstr::ref(list(1, 2))`]

**Q2.** Why do you need to use `unlist()` to convert a list to an atomic vector? Why doesn't `as.vector()` work? 

**A2.** List already *is* a (generic) vector, so `as.vector` is not going to change anything, and there is no `as.atomic.vector`. Thus the need to use `unlist()`.


```r
x <- list(a = 1, b = 2)

is.vector(x)
#> [1] TRUE
is.atomic(x)
#> [1] FALSE

as.vector(x)
#> $a
#> [1] 1
#> 
#> $b
#> [1] 2

unlist(x)
#> a b 
#> 1 2
```

**Q3.** Compare and contrast `c()` and `unlist()` when combining a date and date-time into a single vector.

**A3.** 


```r
# creating a date and datetime
date <- as.Date("1947-08-15")
datetime <- as.POSIXct("1950-01-26 00:01", tz = "UTC")

# check attributes
attributes(date)
#> $class
#> [1] "Date"
attributes(datetime)
#> $class
#> [1] "POSIXct" "POSIXt" 
#> 
#> $tzone
#> [1] "UTC"

# check their underlying double representation
as.double(date) # number of days since the Unix epoch 1970-01-01
#> [1] -8175
as.double(datetime) # number of seconds since then
#> [1] -628991940
```

Behavior with `c()`: Works as expected. Only odd thing is that it strips the `tzone` attribute.


```r
c(date, datetime)
#> [1] "1947-08-15" "1950-01-26"

attributes(c(date, datetime))
#> $class
#> [1] "Date"

c(datetime, date)
#> [1] "1950-01-26 01:01:00 CET"  "1947-08-15 02:00:00 CEST"

attributes(c(datetime, date))
#> $class
#> [1] "POSIXct" "POSIXt"
```

Behavior with `unlist()`: Removes all attributes and we are left only with the underlying double representations of these objects.


```r
unlist(list(date, datetime))
#> [1]      -8175 -628991940

unlist(list(datetime, date))
#> [1] -628991940      -8175
```

## Exercises 3.6.8

**Q1.** Can you have a data frame with zero rows? What about zero columns?

**A1.** Data frame with 0 rows is possible. This is basically a list with a vector of length 0.


```r
data.frame(x = numeric(0))
#> [1] x
#> <0 rows> (or 0-length row.names)
```

Data frame with 0 columns is possible. This will be an empty list.


```r
data.frame(row.names = 1)
#> data frame with 0 columns and 1 row
```

Both in one go:


```r
data.frame()
#> data frame with 0 columns and 0 rows

dim(data.frame())
#> [1] 0 0
```

**Q2.** What happens if you attempt to set rownames that are not unique?

**A2.** If you attempt to set rownames that are not unique, it will not work.


```r
data.frame(row.names = c(1, 1))
#> Error in data.frame(row.names = c(1, 1)): duplicate row.names: 1
```

**Q3.** If `df` is a data frame, what can you say about `t(df)`, and `t(t(df))`? Perform some experiments, making sure to try different column types.

**A3.** Transposing a dataframe transforms it into a matrix and coerces all its elements to be of the same type.


```r
# original
(df <- head(iris))
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> 1          5.1         3.5          1.4         0.2  setosa
#> 2          4.9         3.0          1.4         0.2  setosa
#> 3          4.7         3.2          1.3         0.2  setosa
#> 4          4.6         3.1          1.5         0.2  setosa
#> 5          5.0         3.6          1.4         0.2  setosa
#> 6          5.4         3.9          1.7         0.4  setosa

# transpose
t(df)
#>              1        2        3        4        5       
#> Sepal.Length "5.1"    "4.9"    "4.7"    "4.6"    "5.0"   
#> Sepal.Width  "3.5"    "3.0"    "3.2"    "3.1"    "3.6"   
#> Petal.Length "1.4"    "1.4"    "1.3"    "1.5"    "1.4"   
#> Petal.Width  "0.2"    "0.2"    "0.2"    "0.2"    "0.2"   
#> Species      "setosa" "setosa" "setosa" "setosa" "setosa"
#>              6       
#> Sepal.Length "5.4"   
#> Sepal.Width  "3.9"   
#> Petal.Length "1.7"   
#> Petal.Width  "0.4"   
#> Species      "setosa"

# transpose of a transpose
t(t(df))
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width
#> 1 "5.1"        "3.5"       "1.4"        "0.2"      
#> 2 "4.9"        "3.0"       "1.4"        "0.2"      
#> 3 "4.7"        "3.2"       "1.3"        "0.2"      
#> 4 "4.6"        "3.1"       "1.5"        "0.2"      
#> 5 "5.0"        "3.6"       "1.4"        "0.2"      
#> 6 "5.4"        "3.9"       "1.7"        "0.4"      
#>   Species 
#> 1 "setosa"
#> 2 "setosa"
#> 3 "setosa"
#> 4 "setosa"
#> 5 "setosa"
#> 6 "setosa"

# is it a dataframe?
is.data.frame(df)
#> [1] TRUE
is.data.frame(t(df))
#> [1] FALSE
is.data.frame(t(t(df)))
#> [1] FALSE

# check type
typeof(df)
#> [1] "list"
typeof(t(df))
#> [1] "character"
typeof(t(t(df)))
#> [1] "character"

# check dimensions
dim(df)
#> [1] 6 5
dim(t(df))
#> [1] 5 6
dim(t(t(df)))
#> [1] 6 5
```

**Q4.** What does `as.matrix()` do when applied to a data frame with columns of different types? How does it differ from `data.matrix()`?

**A4.** The return type of `as.matrix()` depends on dataframe column types.


```r
# example with mixed types (coerced to character)
(df <- head(iris))
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> 1          5.1         3.5          1.4         0.2  setosa
#> 2          4.9         3.0          1.4         0.2  setosa
#> 3          4.7         3.2          1.3         0.2  setosa
#> 4          4.6         3.1          1.5         0.2  setosa
#> 5          5.0         3.6          1.4         0.2  setosa
#> 6          5.4         3.9          1.7         0.4  setosa

as.matrix(df)
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width
#> 1 "5.1"        "3.5"       "1.4"        "0.2"      
#> 2 "4.9"        "3.0"       "1.4"        "0.2"      
#> 3 "4.7"        "3.2"       "1.3"        "0.2"      
#> 4 "4.6"        "3.1"       "1.5"        "0.2"      
#> 5 "5.0"        "3.6"       "1.4"        "0.2"      
#> 6 "5.4"        "3.9"       "1.7"        "0.4"      
#>   Species 
#> 1 "setosa"
#> 2 "setosa"
#> 3 "setosa"
#> 4 "setosa"
#> 5 "setosa"
#> 6 "setosa"

str(as.matrix(df))
#>  chr [1:6, 1:5] "5.1" "4.9" "4.7" "4.6" "5.0" "5.4" ...
#>  - attr(*, "dimnames")=List of 2
#>   ..$ : chr [1:6] "1" "2" "3" "4" ...
#>   ..$ : chr [1:5] "Sepal.Length" "Sepal.Width" "Petal.Length" "Petal.Width" ...

# another example (no such coercion)
BOD
#>   Time demand
#> 1    1    8.3
#> 2    2   10.3
#> 3    3   19.0
#> 4    4   16.0
#> 5    5   15.6
#> 6    7   19.8

as.matrix(BOD)
#>      Time demand
#> [1,]    1    8.3
#> [2,]    2   10.3
#> [3,]    3   19.0
#> [4,]    4   16.0
#> [5,]    5   15.6
#> [6,]    7   19.8
```

From documentation of `data.matrix()`:

> Return the matrix obtained by converting all the variables in a data frame to numeric mode and then binding them together as the columns of a matrix.

So `data.matrix()` always returns a numeric matrix:


```r
data.matrix(df)
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> 1          5.1         3.5          1.4         0.2       1
#> 2          4.9         3.0          1.4         0.2       1
#> 3          4.7         3.2          1.3         0.2       1
#> 4          4.6         3.1          1.5         0.2       1
#> 5          5.0         3.6          1.4         0.2       1
#> 6          5.4         3.9          1.7         0.4       1

str(data.matrix(df))
#>  num [1:6, 1:5] 5.1 4.9 4.7 4.6 5 5.4 3.5 3 3.2 3.1 ...
#>  - attr(*, "dimnames")=List of 2
#>   ..$ : chr [1:6] "1" "2" "3" "4" ...
#>   ..$ : chr [1:5] "Sepal.Length" "Sepal.Width" "Petal.Length" "Petal.Width" ...
```
