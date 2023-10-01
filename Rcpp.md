# Rewriting R code in C++




```r
library(Rcpp, warn.conflicts = FALSE)
```

## Getting started with C++ (Exercises 25.2.6)

**Q1.** With the basics of C++ in hand, it's now a great time to practice by reading and writing some simple C++ functions. For each of the following functions, read the code and figure out what the corresponding base R function is. You might not understand every part of the code yet, but you should be able to figure out the basics of what the function does.


```cpp
#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
double f1(NumericVector x) {
  int n = x.size();
  double y = 0;

  for(int i = 0; i < n; ++i) {
    y += x[i] / n;
  }
  return y;
}

// [[Rcpp::export]]
NumericVector f2(NumericVector x) {
  int n = x.size();
  NumericVector out(n);

  out[0] = x[0];
  for(int i = 1; i < n; ++i) {
    out[i] = out[i - 1] + x[i];
  }
  return out;
}

// [[Rcpp::export]]
bool f3(LogicalVector x) {
  int n = x.size();

  for(int i = 0; i < n; ++i) {
    if (x[i]) return true;
  }
  return false;
}

// [[Rcpp::export]]
int f4(Function pred, List x) {
  int n = x.size();

  for(int i = 0; i < n; ++i) {
    LogicalVector res = pred(x[i]);
    if (res[0]) return i + 1;
  }
  return 0;
}

// [[Rcpp::export]]
NumericVector f5(NumericVector x, NumericVector y) {
  int n = std::max(x.size(), y.size());
  NumericVector x1 = rep_len(x, n);
  NumericVector y1 = rep_len(y, n);

  NumericVector out(n);

  for (int i = 0; i < n; ++i) {
    out[i] = std::min(x1[i], y1[i]);
  }

  return out;
}
```

**A1.** 

`f1()` is the same as `mean()`:


```r
x <- c(1, 2, 3, 4, 5, 6)

f1(x)
#> [1] 3.5
mean(x)
#> [1] 3.5
```

`f2()` is the same as `cumsum()`:


```r
x <- c(1, 3, 5, 6)

f2(x)
#> [1]  1  4  9 15
cumsum(x)
#> [1]  1  4  9 15
```

`f3()` is the same as `any()`:


```r
x1 <- c(TRUE, FALSE, FALSE, TRUE)
x2 <- c(FALSE, FALSE)

f3(x1)
#> [1] TRUE
any(x1)
#> [1] TRUE

f3(x2)
#> [1] FALSE
any(x2)
#> [1] FALSE
```

`f4()` is the same as `Position()`:


```r
x <- list("a", TRUE, "m", 2)

f4(is.numeric, x)
#> [1] 4
Position(is.numeric, x)
#> [1] 4
```

`f5()` is the same as `pmin()`:


```r
v1 <- c(1, 3, 4, 5, 6, 7)
v2 <- c(1, 2, 7, 2, 8, 1)

f5(v1, v2)
#> [1] 1 2 4 2 6 1
pmin(v1, v2)
#> [1] 1 2 4 2 6 1
```

**Q2.** To practice your function writing skills, convert the following functions into C++. For now, assume the inputs have no missing values.

1. `all()`.

2. `cumprod()`, `cummin()`, `cummax()`.

3. `diff()`. Start by assuming lag 1, and then generalise for lag `n`.

4. `range()`.

5. `var()`. Read about the approaches you can take on  [Wikipedia](http://en.wikipedia.org/wiki/Algorithms_for_calculating_variance). Whenever implementing a numerical algorithm, it's always good to check what is already known about the problem.

**A2.** The performance benefits are not going to be observed if the function is primitive since those are already tuned to the max in R for performance. So, expect performance gain only for `diff()` and `var()`.


```r
is.primitive(all)
#> [1] TRUE
is.primitive(cumprod)
#> [1] TRUE
is.primitive(diff)
#> [1] FALSE
is.primitive(range)
#> [1] TRUE
is.primitive(var)
#> [1] FALSE
```

- `all()`


```cpp
#include <vector>
// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
bool allC(std::vector<bool> x)
{
    for (const auto& xElement : x)
    {
        if (!xElement) return false;
    }

    return true;
}
```


```r
v1 <- rep(TRUE, 10)
v2 <- c(rep(TRUE, 5), rep(FALSE, 5))

all(v1)
#> [1] TRUE
allC(v1)
#> [1] TRUE

all(v2)
#> [1] FALSE
allC(v2)
#> [1] FALSE

# performance benefits?
bench::mark(
  all(c(rep(TRUE, 1000), rep(FALSE, 1000))),
  allC(c(rep(TRUE, 1000), rep(FALSE, 1000))),
  iterations = 100
)
#> # A tibble: 2 × 6
#>   expression                                      min
#>   <bch:expr>                                 <bch:tm>
#> 1 all(c(rep(TRUE, 1000), rep(FALSE, 1000)))     9.9µs
#> 2 allC(c(rep(TRUE, 1000), rep(FALSE, 1000)))   15.5µs
#>     median `itr/sec` mem_alloc `gc/sec`
#>   <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1   11.8µs    83907.    15.8KB        0
#> 2   17.1µs    57303.    18.3KB        0
```

- `cumprod()`


```cpp
#include <vector>

// [[Rcpp::export]]
std::vector<double> cumprodC(const std::vector<double> &x)
{
    std::vector<double> out{x};

    for (std::size_t i = 1; i < x.size(); i++)
    {
        out[i] = out[i - 1] * x[i];
    }

    return out;
}
```



```r
v1 <- c(10, 4, 6, 8)

cumprod(v1)
#> [1]   10   40  240 1920
cumprodC(v1)
#> [1]   10   40  240 1920

# performance benefits?
bench::mark(
  cumprod(v1),
  cumprodC(v1),
  iterations = 100
)
#> # A tibble: 2 × 6
#>   expression        min   median `itr/sec` mem_alloc
#>   <bch:expr>   <bch:tm> <bch:tm>     <dbl> <bch:byt>
#> 1 cumprod(v1)         0    100ns  7518806.        0B
#> 2 cumprodC(v1)    1.7µs    1.8µs   502766.    6.62KB
#>   `gc/sec`
#>      <dbl>
#> 1        0
#> 2        0
```

- `cumminC()`


```cpp
#include <vector>
// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
std::vector<double> cumminC(const std::vector<double> &x)
{
    std::vector<double> out{x};

    for (std::size_t i = 1; i < x.size(); i++)
    {
        out[i] = (out[i] < out[i - 1]) ? out[i] : out[i - 1];
    }

    return out;
}
```


```r
v1 <- c(3:1, 2:0, 4:2)

cummin(v1)
#> [1] 3 2 1 1 1 0 0 0 0
cumminC(v1)
#> [1] 3 2 1 1 1 0 0 0 0

# performance benefits?
bench::mark(
  cummin(v1),
  cumminC(v1),
  iterations = 100
)
#> # A tibble: 2 × 6
#>   expression       min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>  <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 cummin(v1)    99.9ns    200ns  5127952.        0B        0
#> 2 cumminC(v1)    1.8µs    2.2µs   439560.    6.62KB        0
```

- `cummaxC()`


```cpp
#include <vector>
// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
std::vector<double> cummaxC(const std::vector<double> &x)
{
    std::vector<double> out{x};

    for (std::size_t i = 1; i < x.size(); i++)
    {
        out[i] = (out[i] > out[i - 1]) ? out[i] : out[i - 1];
    }
    
    return out;
}
```


```r
v1 <- c(3:1, 2:0, 4:2)

cummax(v1)
#> [1] 3 3 3 3 3 3 4 4 4
cummaxC(v1)
#> [1] 3 3 3 3 3 3 4 4 4

# performance benefits?
bench::mark(
  cummax(v1),
  cummaxC(v1),
  iterations = 100
)
#> # A tibble: 2 × 6
#>   expression       min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>  <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 cummax(v1)    99.9ns    100ns  7299401.        0B        0
#> 2 cummaxC(v1)    1.8µs    2.2µs   428999.    6.62KB        0
```

- `diff()`


```cpp
#include <vector>
#include <functional>
#include <algorithm>
using namespace std;
// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
std::vector<double> diffC(const std::vector<double> &x, int lag)
{
    std::vector<double> vec_start;
    std::vector<double> vec_lagged;
    std::vector<double> vec_diff;

    for (std::size_t i = lag; i < x.size(); i++)
    {
        vec_lagged.push_back(x[i]);
    }

    for (std::size_t i = 0; i < (x.size() - lag); i++)
    {
        vec_start.push_back(x[i]);
    }

    std::transform(
        vec_lagged.begin(), vec_lagged.end(),
        vec_start.begin(), std::back_inserter(vec_diff),
        std::minus<double>());

    return vec_diff;
}
```


```r
v1 <- c(1, 2, 4, 8, 13)
v2 <- c(1, 2, NA, 8, 13)

diff(v1, 2)
#> [1] 3 6 9
diffC(v1, 2)
#> [1] 3 6 9

diff(v2, 2)
#> [1] NA  6 NA
diffC(v2, 2)
#> [1] NA  6 NA

# performance benefits?
bench::mark(
  diff(v1, 2),
  diffC(v1, 2),
  iterations = 100
)
#> # A tibble: 2 × 6
#>   expression        min   median `itr/sec` mem_alloc
#>   <bch:expr>   <bch:tm> <bch:tm>     <dbl> <bch:byt>
#> 1 diff(v1, 2)     4.7µs    5.7µs   172533.        0B
#> 2 diffC(v1, 2)    2.2µs    2.4µs   390322.    2.49KB
#>   `gc/sec`
#>      <dbl>
#> 1        0
#> 2        0
```

- `range()`


```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

// [[Rcpp::export]]
std::vector<double> rangeC(std::vector<double> x)
{
    std::vector<double> rangeVec{0.0, 0.0};

    rangeVec.at(0) = *std::min_element(x.begin(), x.end());
    rangeVec.at(1) = *std::max_element(x.begin(), x.end());

    return rangeVec;
}
```


```r
v1 <- c(10, 4, 6, 8)

range(v1)
#> [1]  4 10
rangeC(v1)
#> [1]  4 10

# performance benefits?
bench::mark(
  range(v1),
  rangeC(v1),
  iterations = 100
)
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 range(v1)     1.8µs    2.2µs   423550.        0B        0
#> 2 rangeC(v1)    1.7µs      2µs   467073.    6.62KB        0
```

- `var()`


```cpp
#include <vector>
#include <cmath>
#include <numeric>
using namespace std;
// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
double variance(std::vector<double> x)
{
    double sumSquared{0};

    double mean = std::accumulate(x.begin(), x.end(), 0.0) / x.size();

    for (const auto& xElement : x)
    {
        sumSquared += pow(xElement - mean, 2.0);
    }

    return sumSquared / (x.size() - 1);
}
```



```r
v1 <- c(1, 4, 7, 8)

var(v1)
#> [1] 10
variance(v1)
#> [1] 10

# performance benefits?
bench::mark(
  var(v1),
  variance(v1),
  iterations = 100
)
#> # A tibble: 2 × 6
#>   expression        min   median `itr/sec` mem_alloc
#>   <bch:expr>   <bch:tm> <bch:tm>     <dbl> <bch:byt>
#> 1 var(v1)         9.2µs   10.2µs    93624.        0B
#> 2 variance(v1)    1.6µs    1.9µs   505818.    6.62KB
#>   `gc/sec`
#>      <dbl>
#> 1        0
#> 2        0
```

## Missing values (Exercises 25.4.5)

**Q1.** Rewrite any of the functions from Exercise 25.2.6 to deal with missing values. If `na.rm` is true, ignore the missing values. If `na.rm` is false,  return a missing value if the input contains any missing values. Some good functions to practice with are `min()`, `max()`, `range()`, `mean()`, and `var()`.

**A1.** We will only create a version of `range()` that deals with missing values. The same principle applies to others:


```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <math.h>
#include <Rcpp.h>
using namespace std;
// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
std::vector<double> rangeC_NA(std::vector<double> x, bool removeNA = true)
{
    std::vector<double> rangeVec{0.0, 0.0};

    bool naPresent = std::any_of(
        x.begin(),
        x.end(),
        [](double d)
        { return isnan(d); });

    if (naPresent)
    {
        if (removeNA)
        {
            std::remove(x.begin(), x.end(), NAN);
        }
        else
        {
            rangeVec.at(0) = NA_REAL; // NAN;
            rangeVec.at(1) = NA_REAL; // NAN;

            return rangeVec;
        }
    }

    rangeVec.at(0) = *std::min_element(x.begin(), x.end());
    rangeVec.at(1) = *std::max_element(x.begin(), x.end());

    return rangeVec;
}
```


```r
v1 <- c(10, 4, NA, 6, 8)

range(v1, na.rm = FALSE)
#> [1] NA NA
rangeC_NA(v1, FALSE)
#> [1] NA NA

range(v1, na.rm = TRUE)
#> [1]  4 10
rangeC_NA(v1, TRUE)
#> [1]  4 10
```

**Q2.** Rewrite `cumsum()` and `diff()` so they can handle missing values. Note that these functions have slightly more complicated behaviour.

**A2.** The `cumsum()` docs say:

> An `NA` value in `x` causes the corresponding and following elements of the return value to be `NA`, as does integer overflow in cumsum (with a warning).

Similarly, `diff()` docs say:

> `NA`'s propagate.

Therefore, both of these functions don't allow removing missing values and the `NA`s propagate.

As seen from the examples above, `diffC()` already behaves this way.

Similarly, `cumsumC()` propagates `NA`s as well.


```cpp
#include <Rcpp.h>
using namespace Rcpp;
// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
NumericVector cumsumC(NumericVector x) {
  int n = x.size();
  NumericVector out(n);
  
  out[0] = x[0];
  for(int i = 1; i < n; ++i) {
    out[i] = out[i - 1] + x[i];
  }
  
  return out;
}
```


```r
v1 <- c(1, 2, 3, 4)
v2 <- c(1, 2, NA, 4)

cumsum(v1)
#> [1]  1  3  6 10
cumsumC(v1)
#> [1]  1  3  6 10

cumsum(v2)
#> [1]  1  3 NA NA
cumsumC(v2)
#> [1]  1  3 NA NA
```

## Standard Template Library (Exercises 25.5.7)

**Q1.** To practice using the STL algorithms and data structures, implement the following using R functions in C++, using the hints provided:

**A1.** 

1. `median.default()` using `partial_sort`.


```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;
// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
double medianC(std::vector<double> &x)
{
    int middleIndex = static_cast<int>(x.size() / 2);

    std::partial_sort(x.begin(), x.begin() + middleIndex, x.end());

    // for even number of observations
    if (x.size() % 2 == 0)
    {
        return (x[middleIndex - 1] + x[middleIndex]) / 2;
    }

    return x[middleIndex];
}
```



```r
v1 <- c(1, 3, 3, 6, 7, 8, 9)
v2 <- c(1, 2, 3, 4, 5, 6, 8, 9)

median.default(v1)
#> [1] 6
medianC(v1)
#> [1] 6

median.default(v2)
#> [1] 4.5
medianC(v2)
#> [1] 4.5

# performance benefits?
bench::mark(
  median.default(v2),
  medianC(v2),
  iterations = 100
)
#> # A tibble: 2 × 6
#>   expression              min   median `itr/sec` mem_alloc
#>   <bch:expr>         <bch:tm> <bch:tm>     <dbl> <bch:byt>
#> 1 median.default(v2)   25.1µs   26.9µs    36555.        0B
#> 2 medianC(v2)           1.7µs      2µs   483558.    2.49KB
#>   `gc/sec`
#>      <dbl>
#> 1        0
#> 2        0
```

1. `%in%` using `unordered_set` and the `find()` or `count()` methods.


```cpp
#include <vector>
#include <unordered_set>
using namespace std;
// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
std::vector<bool> matchC(const std::vector<double> &x, const std::vector<double> &table)
{
    std::unordered_set<double> tableUnique(table.begin(), table.end());
    std::vector<bool> out;

    for (const auto &xElem : x)
    {
        out.push_back(tableUnique.find(xElem) != tableUnique.end() ? true : false);
    }

    return out;
}
```


```r
x1 <- c(3, 4, 8)
x2 <- c(1, 2, 3, 3, 4, 4, 5, 6)

x1 %in% x2
#> [1]  TRUE  TRUE FALSE
matchC(x1, x2)
#> [1]  TRUE  TRUE FALSE

# performance benefits?
bench::mark(
  x1 %in% x2,
  matchC(x1, x2),
  iterations = 100
)
#> # A tibble: 2 × 6
#>   expression          min   median `itr/sec` mem_alloc
#>   <bch:expr>     <bch:tm> <bch:tm>     <dbl> <bch:byt>
#> 1 x1 %in% x2        1.1µs    1.4µs   664453.        0B
#> 2 matchC(x1, x2)    2.7µs    3.2µs   293686.    6.62KB
#>   `gc/sec`
#>      <dbl>
#> 1        0
#> 2        0
```

1. `unique()` using an `unordered_set` (challenge: do it in one line!).


```cpp
#include <unordered_set>
#include <vector>
#include <iostream>
using namespace std;
// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
std::unordered_set<double> uniqueC(const std::vector<double> &x)
{
    std::unordered_set<double> xSet(x.begin(), x.end());

    return xSet;
}
```

Note that these functions are **not** comparable. As far as I can see, there is no way to get the same output as the R version of the function using the `unordered_set` data structure.


```r
v1 <- c(1, 3, 3, 6, 7, 8, 9)

unique(v1)
#> [1] 1 3 6 7 8 9
uniqueC(v1)
#> [1] 9 8 7 6 3 1
```

We can make comparable version using `set` data structure:


```cpp
#include <set>
#include <vector>
#include <iostream>
using namespace std;
// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
std::set<double> uniqueC2(const std::vector<double> &x)
{
    std::set<double> xSet(x.begin(), x.end());

    return xSet;
}
```


```r
v1 <- c(1, 3, 3, 6, 7, 8, 9)

unique(v1)
#> [1] 1 3 6 7 8 9
uniqueC2(v1)
#> [1] 1 3 6 7 8 9

# performance benefits?
bench::mark(
  unique(v1),
  uniqueC2(v1),
  iterations = 100
)
#> # A tibble: 2 × 6
#>   expression        min   median `itr/sec` mem_alloc
#>   <bch:expr>   <bch:tm> <bch:tm>     <dbl> <bch:byt>
#> 1 unique(v1)      2.5µs    2.9µs   326371.        0B
#> 2 uniqueC2(v1)      2µs   2.35µs   273075.    6.62KB
#>   `gc/sec`
#>      <dbl>
#> 1        0
#> 2        0
```

1. `min()` using `std::min()`, or `max()` using `std::max()`.


```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;
// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
const double minC(const std::vector<double> &x)
{
     return *std::min_element(x.begin(), x.end());
}

// [[Rcpp::export]]
const double maxC(std::vector<double> x)
{
     return *std::max_element(x.begin(), x.end());
}
```


```r
v1 <- c(3, 3, 6, 1, 9, 7, 8)

min(v1)
#> [1] 1
minC(v1)
#> [1] 1

# performance benefits?
bench::mark(
  min(v1),
  minC(v1),
  iterations = 100
)
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 min(v1)     199.9ns    200ns  3663007.        0B        0
#> 2 minC(v1)      1.7µs      2µs   472813.    6.62KB        0

max(v1)
#> [1] 9
maxC(v1)
#> [1] 9

# performance benefits?
bench::mark(
  max(v1),
  maxC(v1),
  iterations = 100
)
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 max(v1)     199.9ns    300ns  3039512.        0B        0
#> 2 maxC(v1)      1.6µs    1.8µs   528258.    6.62KB        0
```

1. `which.min()` using `min_element`, or `which.max()` using `max_element`.


```cpp
#include <vector>
#include <algorithm>
using namespace std;
// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
int which_maxC(std::vector<double> &x)
{
    int maxIndex = std::distance(x.begin(), std::max_element(x.begin(), x.end()));
  
    // R is 1-index based, while C++ is 0-index based
    return maxIndex + 1;
}

// [[Rcpp::export]]
int which_minC(std::vector<double> &x)
{
    int minIndex = std::distance(x.begin(), std::min_element(x.begin(), x.end()));
  
    // R is 1-index based, while C++ is 0-index based
    return minIndex + 1;
}
```



```r
v1 <- c(3, 3, 6, 1, 9, 7, 8)

which.min(v1)
#> [1] 4
which_minC(v1)
#> [1] 4

# performance benefits?
bench::mark(
  which.min(v1),
  which_minC(v1),
  iterations = 100
)
#> # A tibble: 2 × 6
#>   expression          min   median `itr/sec` mem_alloc
#>   <bch:expr>     <bch:tm> <bch:tm>     <dbl> <bch:byt>
#> 1 which.min(v1)     300ns    400ns  2164524.        0B
#> 2 which_minC(v1)    1.6µs      2µs   469485.    6.62KB
#>   `gc/sec`
#>      <dbl>
#> 1        0
#> 2        0

which.max(v1)
#> [1] 5
which_maxC(v1)
#> [1] 5

# performance benefits?
bench::mark(
  which.max(v1),
  which_maxC(v1),
  iterations = 100
)
#> # A tibble: 2 × 6
#>   expression          min   median `itr/sec` mem_alloc
#>   <bch:expr>     <bch:tm> <bch:tm>     <dbl> <bch:byt>
#> 1 which.max(v1)     300ns    400ns  2123142.        0B
#> 2 which_maxC(v1)    1.7µs      2µs   439752.    6.62KB
#>   `gc/sec`
#>      <dbl>
#> 1        0
#> 2        0
```

1. `setdiff()`, `union()`, and `intersect()` for integers using sorted ranges and `set_union`, `set_intersection` and `set_difference`.

Note that the following C++ implementations of given functions are not strictly equivalent to their R versions. As far as I can see, there is no way for them to be identical while satisfying the specifications mentioned in the question.

- `union()`


```cpp
#include <algorithm>
#include <iostream>
#include <vector>
#include <set>
using namespace std;
// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
std::set<int> unionC(std::vector<int> &v1, std::vector<int> &v2)
{
    std::sort(v1.begin(), v1.end());
    std::sort(v2.begin(), v2.end());

    std::vector<int> union_vec(v1.size() + v2.size());
    auto it = std::set_union(v1.begin(), v1.end(), v2.begin(), v2.end(), union_vec.begin());

    union_vec.resize(it - union_vec.begin());
    std::set<int> union_set(union_vec.begin(), union_vec.end());

    return union_set;
}
```


```r
v1 <- c(1, 4, 5, 5, 5, 6, 2)
v2 <- c(4, 1, 6, 8)

union(v1, v2)
#> [1] 1 4 5 6 2 8
unionC(v1, v2)
#> [1] 1 2 4 5 6 8
```

- `intersect()`


```cpp
#include <algorithm>
#include <iostream>
#include <vector>
#include <set>
using namespace std;
// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
std::set<int> intersectC(std::vector<int> &v1, std::vector<int> &v2)
{
    std::sort(v1.begin(), v1.end());
    std::sort(v2.begin(), v2.end());

    std::vector<int> union_vec(v1.size() + v2.size());
    auto it = std::set_intersection(v1.begin(), v1.end(), v2.begin(), v2.end(), union_vec.begin());

    union_vec.resize(it - union_vec.begin());
    std::set<int> union_set(union_vec.begin(), union_vec.end());

    return union_set;
}
```


```r
v1 <- c(1, 4, 5, 5, 5, 6, 2)
v2 <- c(4, 1, 6, 8)

intersect(v1, v2)
#> [1] 1 4 6
intersectC(v1, v2)
#> [1] 1 4 6
```

- `setdiff()`


```cpp
#include <algorithm>
#include <iostream>
#include <vector>
#include <set>
using namespace std;
// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
std::set<int> setdiffC(std::vector<int> &v1, std::vector<int> &v2)
{
    std::sort(v1.begin(), v1.end());
    std::sort(v2.begin(), v2.end());

    std::vector<int> union_vec(v1.size() + v2.size());
    auto it = std::set_difference(v1.begin(), v1.end(), v2.begin(), v2.end(), union_vec.begin());

    union_vec.resize(it - union_vec.begin());
    std::set<int> union_set(union_vec.begin(), union_vec.end());

    return union_set;
}
```


```r
v1 <- c(1, 4, 5, 5, 5, 6, 2)
v2 <- c(4, 1, 6, 8)

setdiff(v1, v2)
#> [1] 5 2
setdiffC(v1, v2)
#> [1] 2 5
```

## Session information


```r
sessioninfo::session_info(include_base = TRUE)
#> ─ Session info ───────────────────────────────────────────
#>  setting  value
#>  version  R version 4.3.1 (2023-06-16)
#>  os       Ubuntu 22.04.3 LTS
#>  system   x86_64, linux-gnu
#>  ui       X11
#>  language (EN)
#>  collate  C.UTF-8
#>  ctype    C.UTF-8
#>  tz       UTC
#>  date     2023-10-01
#>  pandoc   3.1.8 @ /usr/bin/ (via rmarkdown)
#> 
#> ─ Packages ───────────────────────────────────────────────
#>  package     * version date (UTC) lib source
#>  base        * 4.3.1   2023-08-04 [3] local
#>  bench         1.1.3   2023-05-04 [1] RSPM
#>  bookdown      0.35    2023-08-09 [1] RSPM
#>  bslib         0.5.1   2023-08-11 [1] RSPM
#>  cachem        1.0.8   2023-05-01 [1] RSPM
#>  cli           3.6.1   2023-03-23 [1] RSPM
#>  compiler      4.3.1   2023-08-04 [3] local
#>  datasets    * 4.3.1   2023-08-04 [3] local
#>  digest        0.6.33  2023-07-07 [1] RSPM
#>  downlit       0.4.3   2023-06-29 [1] RSPM
#>  evaluate      0.21    2023-05-05 [1] RSPM
#>  fansi         1.0.4   2023-01-22 [1] RSPM
#>  fastmap       1.1.1   2023-02-24 [1] RSPM
#>  fs            1.6.3   2023-07-20 [1] RSPM
#>  glue          1.6.2   2022-02-24 [1] RSPM
#>  graphics    * 4.3.1   2023-08-04 [3] local
#>  grDevices   * 4.3.1   2023-08-04 [3] local
#>  htmltools     0.5.6   2023-08-10 [1] RSPM
#>  jquerylib     0.1.4   2021-04-26 [1] RSPM
#>  jsonlite      1.8.7   2023-06-29 [1] RSPM
#>  knitr         1.44    2023-09-11 [1] RSPM
#>  lifecycle     1.0.3   2022-10-07 [1] RSPM
#>  magrittr    * 2.0.3   2022-03-30 [1] RSPM
#>  memoise       2.0.1   2021-11-26 [1] RSPM
#>  methods     * 4.3.1   2023-08-04 [3] local
#>  pillar        1.9.0   2023-03-22 [1] RSPM
#>  pkgconfig     2.0.3   2019-09-22 [1] RSPM
#>  profmem       0.6.0   2020-12-13 [1] RSPM
#>  R6            2.5.1   2021-08-19 [1] RSPM
#>  Rcpp        * 1.0.11  2023-07-06 [1] RSPM
#>  rlang         1.1.1   2023-04-28 [1] RSPM
#>  rmarkdown     2.25    2023-09-18 [1] RSPM
#>  sass          0.4.7   2023-07-15 [1] RSPM
#>  sessioninfo   1.2.2   2021-12-06 [1] RSPM
#>  stats       * 4.3.1   2023-08-04 [3] local
#>  tibble        3.2.1   2023-03-20 [1] RSPM
#>  tools         4.3.1   2023-08-04 [3] local
#>  utf8          1.2.3   2023-01-31 [1] RSPM
#>  utils       * 4.3.1   2023-08-04 [3] local
#>  vctrs         0.6.3   2023-06-14 [1] RSPM
#>  withr         2.5.1   2023-09-26 [1] RSPM
#>  xfun          0.40    2023-08-09 [1] RSPM
#>  xml2          1.3.5   2023-07-06 [1] RSPM
#>  yaml          2.3.7   2023-01-23 [1] RSPM
#> 
#>  [1] /home/runner/work/_temp/Library
#>  [2] /opt/R/4.3.1/lib/R/site-library
#>  [3] /opt/R/4.3.1/lib/R/library
#> 
#> ──────────────────────────────────────────────────────────
```
