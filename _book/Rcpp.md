# Rewriting R code in C++



## Exercise 25.2.6

**Q1.** Figure out base function corresponding to Rccp code


```r
library(Rcpp)
```



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

**Q2.** Converting base function to Rcpp

The performance benefits are not going to be observed if the function is primitive since those are already tuned to the max in R for performance. So, expect performance gain only for `diff()` and `var()`.


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
#> # A tibble: 2 x 6
#>   expression                                      min
#>   <bch:expr>                                 <bch:tm>
#> 1 all(c(rep(TRUE, 1000), rep(FALSE, 1000)))    14.4us
#> 2 allC(c(rep(TRUE, 1000), rep(FALSE, 1000)))   15.9us
#>     median `itr/sec` mem_alloc `gc/sec`
#>   <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1   19.9us    47344.    15.8KB        0
#> 2   20.3us    46136.    18.3KB        0
```

- `cumprod()`


```cpp
#include <vector>

// [[Rcpp::export]]
std::vector<double> cumulativeProduct(std::vector<double> x)
{
    std::vector<double> out = x;

    for (size_t i = 1; i < x.size(); i++)
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
cumulativeProduct(v1)
#> [1]   10   40  240 1920

# performance benefits?
bench::mark(
  cumprod(v1),
  cumulativeProduct(v1),
  iterations = 100
)
#> # A tibble: 2 x 6
#>   expression                 min   median `itr/sec`
#>   <bch:expr>            <bch:tm> <bch:tm>     <dbl>
#> 1 cumprod(v1)              100ns    200ns  2865329.
#> 2 cumulativeProduct(v1)      2us   4.05us   221582.
#>   mem_alloc `gc/sec`
#>   <bch:byt>    <dbl>
#> 1        0B        0
#> 2    7.02KB        0
```

- `diff()`

TODO

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
#> # A tibble: 2 x 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 range(v1)     2.4us    2.8us   339098.        0B        0
#> 2 rangeC(v1)    2.2us    2.7us   334896.    7.02KB        0
```

- `var()`


```cpp
#include <vector>
#include <cmath>
#include <numeric>
using namespace std;

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
#> # A tibble: 2 x 6
#>   expression        min   median `itr/sec` mem_alloc
#>   <bch:expr>   <bch:tm> <bch:tm>     <dbl> <bch:byt>
#> 1 var(v1)          11us   12.1us    77839.        0B
#> 2 variance(v1)    2.3us    3.1us   287936.    7.02KB
#>   `gc/sec`
#>      <dbl>
#> 1        0
#> 2        0
```

## Exercise 25.4.5

**Q1.** Rewrite functions with original `na.rm` argument


```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <math.h>
#include <Rcpp.h>
using namespace std;

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

**Q2.** Rewrite functions without original `na.rm` argument

## Exercise 25.5.7

**Q1.** `median.default()` using `partial_sort()`


```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

// [[Rcpp::export]]
double medianC(std::vector<double> x)
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
#> # A tibble: 2 x 6
#>   expression              min   median `itr/sec` mem_alloc
#>   <bch:expr>         <bch:tm> <bch:tm>     <dbl> <bch:byt>
#> 1 median.default(v2)   27.9us   30.8us    31085.        0B
#> 2 medianC(v2)           2.1us    3.2us   267738.    2.49KB
#>   `gc/sec`
#>      <dbl>
#> 1        0
#> 2        0
```
