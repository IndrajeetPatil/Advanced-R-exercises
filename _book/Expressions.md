# Expressions

### Exercises 18.2.4

**Q1.** Reconstruct the code represented by the trees below:


```r
#> █─f
#> └─█─g
#>   └─█─h
#> █─`+`
#> ├─█─`+`
#> │ ├─1
#> │ └─2
#> └─3
#> █─`*`
#> ├─█─`(`
#> │ └─█─`+`
#> │   ├─x
#> │   └─y
#> └─z
```

**A1.** Below is the reconstructed code.


```r
f(g(h()))
1 + 2 + 3
(x + y) * z
```

We can confirm it by drawing ASTs for them:


```r
lobstr::ast(f(g(h())))
#> █─f 
#> └─█─g 
#>   └─█─h

lobstr::ast(1 + 2 + 3)
#> █─`+` 
#> ├─█─`+` 
#> │ ├─1 
#> │ └─2 
#> └─3

lobstr::ast((x + y) * z)
#> █─`*` 
#> ├─█─`(` 
#> │ └─█─`+` 
#> │   ├─x 
#> │   └─y 
#> └─z
```

**Q2.** Draw the following trees by hand and then check your answers with `lobstr::ast()`.


```r
f(g(h(i(1, 2, 3))))
f(1, g(2, h(3, i())))
f(g(1, 2), h(3, i(4, 5)))
```

**A2.** Successfully drawn by hand. Checking using `lobstr::ast()`:


```r
lobstr::ast(f(g(h(i(1, 2, 3)))))
#> █─f 
#> └─█─g 
#>   └─█─h 
#>     └─█─i 
#>       ├─1 
#>       ├─2 
#>       └─3

lobstr::ast(f(1, g(2, h(3, i()))))
#> █─f 
#> ├─1 
#> └─█─g 
#>   ├─2 
#>   └─█─h 
#>     ├─3 
#>     └─█─i

lobstr::ast(f(g(1, 2), h(3, i(4, 5))))
#> █─f 
#> ├─█─g 
#> │ ├─1 
#> │ └─2 
#> └─█─h 
#>   ├─3 
#>   └─█─i 
#>     ├─4 
#>     └─5
```

**Q3.** What's happening with the ASTs below? (Hint: carefully read `?"^"`.)


```r
lobstr::ast(`x` + `y`)
#> █─`+` 
#> ├─x 
#> └─y
lobstr::ast(x**y)
#> █─`^` 
#> ├─x 
#> └─y
lobstr::ast(1 -> x)
#> █─`<-` 
#> ├─x 
#> └─1
```

**A3.** The `str2expression()` helps make sense of these ASTs.

The non-syntactic names are parsed to names. Thus, backticks have been removed in the AST.


```r
str2expression("`x` + `y`")
#> expression(x + y)
```

As mentioned in the docs for `^`:

> \*\* is translated in the parser to \^


```r
str2expression("x**y")
#> expression(x^y)
```

The rightward assignment is parsed to leftward assignment:


```r
str2expression("1 -> x")
#> expression(x <- 1)
```

**Q4.** What is special about the AST below?


```r
lobstr::ast(function(x = 1, y = 2) {})
#> █─`function` 
#> ├─█─x = 1 
#> │ └─y = 2 
#> ├─█─`{` 
#> └─<inline srcref>
```

**A4.** As mentioned in [this](https://adv-r.hadley.nz/functions.html#fun-components) section:

> Like all objects in R, functions can also possess any number of additional `attributes()`. One attribute used by base R is `srcref`, short for source reference. It points to the source code used to create the function. The `srcref` is used for printing because, unlike `body()`, it contains code comments and other formatting.

Therefore, the last leaf in this AST, although not specified in the function call, represents source reference attribute.

**Q5.** What does the call tree of an `if` statement with multiple `else if` conditions look like? Why?

**A5.** There is nothing special about this tree. It just shows the nested loop structure inherent to code with `if` and multiple `else if` statements.


```r
lobstr::ast(if (FALSE) 1 else if (FALSE) 2 else if (FALSE) 3 else 4)
#> █─`if` 
#> ├─FALSE 
#> ├─1 
#> └─█─`if` 
#>   ├─FALSE 
#>   ├─2 
#>   └─█─`if` 
#>     ├─FALSE 
#>     ├─3 
#>     └─4
```

### Exercises 18.3.5

**Q1.** Which two of the six types of atomic vector can't appear in an expression? Why? Similarly, why can't you create an expression that contains an atomic vector of length greater than one?

**A1.** Out of the six types of atomic vectors, the two that can't appear in an expression are: complex and raw.

Complex numbers are created via a **function call** (using `+`), as can be seen by its AST:


```r
x_complex <- rlang::expr(1 + 1i)
typeof(x_complex)
#> [1] "language"

lobstr::ast(1 + 1i)
#> █─`+` 
#> ├─1 
#> └─1i
```

Similarly, for raw vectors (using `raw()`):


```r
x_raw <- rlang::expr(raw(2))
typeof(x_raw)
#> [1] "language"

lobstr::ast(raw(2))
#> █─raw 
#> └─2
```

Contrast this with other atomic vectors:


```r
x_int <- rlang::expr(2L)
typeof(x_int)
#> [1] "integer"

lobstr::ast(2L)
#> 2L
```

For the same reason, you can't you create an expression that contains an atomic vector of length greater than one since that itself is a function call that uses `c()` function:


```r
x_vec <- rlang::expr(c(1, 2))
typeof(x_vec)
#> [1] "language"

lobstr::ast(c(1, 2))
#> █─c 
#> ├─1 
#> └─2
```

**Q2.** What happens when you subset a call object to remove the first element? e.g. `expr(read.csv("foo.csv", header = TRUE))[-1]`. Why?

**A2.** A captured function call like the following creates a call object:


```r
expr(read.csv("foo.csv", header = TRUE))
#> read.csv("foo.csv", header = TRUE)

typeof(expr(read.csv("foo.csv", header = TRUE)))
#> [1] "language"
```

As mentioned in the [respective section](https://adv-r.hadley.nz/expressions.html#function-position):

> The first element of the call object is the function position.

Therefore, when the first element in the call object is removed, the next one moves in the function position, and we get the observed output:


```r
expr(read.csv("foo.csv", header = TRUE))[-1]
#> "foo.csv"(header = TRUE)
```

**Q3.** Describe the differences between the following call objects.


```r
x <- 1:10
call2(median, x, na.rm = TRUE)
call2(expr(median), x, na.rm = TRUE)
call2(median, expr(x), na.rm = TRUE)
call2(expr(median), expr(x), na.rm = TRUE)
```

**Q4.** `rlang::call_standardise()` doesn't work so well for the following calls. Why? What makes `mean()` special?


```r
call_standardise(quote(mean(1:10, na.rm = TRUE)))
#> mean(x = 1:10, na.rm = TRUE)
call_standardise(quote(mean(n = T, 1:10)))
#> mean(x = 1:10, n = T)
call_standardise(quote(mean(x = 1:10, , TRUE)))
#> mean(x = 1:10, , TRUE)
```

**Q5.** Why does this code not make sense?


```r
x <- expr(foo(x = 1))
names(x) <- c("x", "y")
```

**Q6.** Construct the expression `if(x > 1) "a" else "b"` using multiple calls to `call2()`. How does the code structure reflect the structure of the AST?

### Exercises 18.4.4

**Q1.** R uses parentheses in two slightly different ways as illustrated by these two calls:


```r
f((1))
`(`(1 + 1)
```

Compare and contrast the two uses by referencing the AST.

**Q2.** `=` can also be used in two ways. Construct a simple example that shows both uses.

**Q3.** Does `-2^2` yield 4 or -4? Why?

**Q4.** What does `!1 + !1` return? Why?

**Q5.** Why does `x1 <- x2 <- x3 <- 0` work? Describe the two reasons.

**Q6.** Compare the ASTs of `x + y %+% z` and `x ^ y %+% z`. What have you learned about the precedence of custom infix functions?

**Q7.** What happens if you call `parse_expr()` with a string that generates multiple expressions? e.g. `parse_expr("x + 1; y + 1")`

**Q8.** What happens if you attempt to parse an invalid expression? e.g. `"a +"` or `"f())"`.

**Q9.** `deparse()` produces vectors when the input is long. For example, the following call produces a vector of length two:


```r
expr <- expr(g(a + b + c + d + e + f + g + h + i + j + k + l +
  m + n + o + p + q + r + s + t + u + v + w + x + y + z))
deparse(expr)
```

What does `expr_text()` do instead?

**Q10.** `pairwise.t.test()` assumes that `deparse()` always returns a length one character vector. Can you construct an input that violates this expectation? What happens?

### Exercises 18.5.3

**Q1.** `logical_abbr()` returns `TRUE` for `T(1, 2, 3)`. How could you modify `logical_abbr_rec()` so that it ignores function calls that use `T` or `F`?

**Q2.** `logical_abbr()` works with expressions. It currently fails when you give it a function. Why? How could you modify `logical_abbr()` to make it work? What components of a function will you need to recurse over?


```r
logical_abbr(function(x = TRUE) {
  g(x + T)
})
```

**Q3.** Modify `find_assign` to also detect assignment using replacement functions, i.e. `names(x) <- y`.

**Q4.** Write a function that extracts all calls to a specified function.
