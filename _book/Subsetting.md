# Subsetting



## Exercise 4.2.6

**Q1.** Fix each of the following common data frame subsetting errors:


```r
mtcars[mtcars$cyl = 4, ]
mtcars[-1:4, ]
mtcars[mtcars$cyl <= 5]
mtcars[mtcars$cyl == 4 | 6, ]
```

**A1.** Fixed versions of these commands:


```r
mtcars[mtcars$cyl == 4, ]
mtcars[-(1:4), ]
mtcars[mtcars$cyl <= 5, ]
mtcars[mtcars$cyl == 4 | mtcars$cyl == 6, ]
```

**Q2.** Why does the following code yield five missing values?


```r
x <- 1:5
x[NA]
#> [1] NA NA NA NA NA
```

**A2.** This is because of two reasons:

- The default type of `NA` in R is of `logical` type.


```r
typeof(NA)
#> [1] "logical"
```

- R recycles indexes to match the length of the vector.


```r
x <- 1:5
x[c(TRUE, FALSE)] # recycled to c(TRUE, FALSE, TRUE, FALSE, TRUE)
#> [1] 1 3 5
```

**Q3.** What does `upper.tri()` return? How does subsetting a matrix with it work? Do we need any additional subsetting rules to describe its behaviour?


```r
x <- outer(1:5, 1:5, FUN = "*")
x[upper.tri(x)]
```

A3. The documentation for `upper.tri()` states-

> Returns a matrix of logicals the same size of a given matrix with entries `TRUE` in the **upper triangle**

That is, `upper.tri()` return a matrix of logicals.


```r
(x <- outer(1:5, 1:5, FUN = "*"))
#>      [,1] [,2] [,3] [,4] [,5]
#> [1,]    1    2    3    4    5
#> [2,]    2    4    6    8   10
#> [3,]    3    6    9   12   15
#> [4,]    4    8   12   16   20
#> [5,]    5   10   15   20   25

upper.tri(x)
#>       [,1]  [,2]  [,3]  [,4]  [,5]
#> [1,] FALSE  TRUE  TRUE  TRUE  TRUE
#> [2,] FALSE FALSE  TRUE  TRUE  TRUE
#> [3,] FALSE FALSE FALSE  TRUE  TRUE
#> [4,] FALSE FALSE FALSE FALSE  TRUE
#> [5,] FALSE FALSE FALSE FALSE FALSE
```

When used with a matrix for subsetting, this logical matrix returns a vector:


```r
x[upper.tri(x)]
#>  [1]  2  3  6  4  8 12  5 10 15 20
```

**Q4.**  Why does `mtcars[1:20]` return an error? How does it differ from the similar `mtcars[1:20, ]`?

When indexed like a list, data frame columns at given indices will be selected.


```r
head(mtcars[1:2])
#>                    mpg cyl
#> Mazda RX4         21.0   6
#> Mazda RX4 Wag     21.0   6
#> Datsun 710        22.8   4
#> Hornet 4 Drive    21.4   6
#> Hornet Sportabout 18.7   8
#> Valiant           18.1   6
```

`mtcars[1:20]` doesn't work because there are 11 columns in `mtcars` dataset.

On the other hand, `mtcars[1:20, ]` indexes a dataframe like a matrix, and because there are indeed 20 rows in `mtcars`, all columns with these rows are selected.


```r
nrow(mtcars[1:20, ])
#> [1] 20
```

**Q5.** Implement your own function that extracts the diagonal entries from a matrix (it should behave like `diag(x)` where `x` is a matrix).

**A5.** We can combine the existing functions to our advantage:


```r
x[!upper.tri(x) & !lower.tri(x)]
#> [1]  1  4  9 16 25

diag(x)
#> [1]  1  4  9 16 25
```

**Q6.** What does `df[is.na(df)] <- 0` do? How does it work?

**A6.** This command replaces every instance of `NA` in a dataframe with `0`.

`is.na(df)` produces a matrix of logical values, which provides a way to select and assign.


```r
(df <- tibble(x = c(1, 2, NA), y = c(NA, 5, NA)))
#> # A tibble: 3 × 2
#>       x     y
#>   <dbl> <dbl>
#> 1     1    NA
#> 2     2     5
#> 3    NA    NA

is.na(df)
#>          x     y
#> [1,] FALSE  TRUE
#> [2,] FALSE FALSE
#> [3,]  TRUE  TRUE

class(is.na(df))
#> [1] "matrix" "array"
```

## Exercise 4.3.5

**Q1.** Brainstorm as many ways as possible to extract the third value from the `cyl` variable in the `mtcars` dataset.

**A1.** Possible ways to do this:


```r
mtcars$cyl[[3]]
#> [1] 4
mtcars[, "cyl"][[3]]
#> [1] 4
mtcars[["cyl"]][[3]]
#> [1] 4

mtcars[3, ]$cyl
#> [1] 4
mtcars[3, "cyl"]
#> [1] 4
mtcars[3, ][["cyl"]]
#> [1] 4

mtcars[[c(2, 3)]]
#> [1] 4
mtcars[3, 2]
#> [1] 4
```

**Q2.** Given a linear model, e.g., `mod <- lm(mpg ~ wt, data = mtcars)`, extract the residual degrees of freedom. Then extract the R squared from the model summary (`summary(mod)`)

**A2.** Specified linear model:


```r
mod <- lm(mpg ~ wt, data = mtcars)
```

- extracting the residual degrees of freedom


```r
mod$df.residual 
#> [1] 30

# or 

mod[["df.residual"]]
#> [1] 30
```

- extracting the R squared from the model summary


```r
summary(mod)$r.squared
#> [1] 0.7528328
```

## Exercise 4.5.9

**Q1.**  How would you randomly permute the columns of a data frame? (This is an important technique in random forests.) Can you simultaneously permute the rows and columns in one step?

**Q2.** How would you select a random sample of `m` rows from a data frame?  What if the sample had to be contiguous (i.e., with an initial row, a final row, and every row in between)?
    
**Q3.** How could you put the columns in a data frame in alphabetical order?
