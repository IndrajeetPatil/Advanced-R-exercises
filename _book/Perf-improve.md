# Improving performance

### Exercises

1. What are faster alternatives to `lm()`? Which are specifically designed to work with larger datasets?

1. What package implements a version of `match()` that's faster for repeated lookups? How much faster is it?

1. List four functions (not just those in base R) that convert a string into a date time object. What are their strengths and weaknesses?

1. Which packages provide the ability to compute a rolling mean?

1. What are the alternatives to `optim()`?

### Exercises

1. What's the difference between `rowSums()` and `.rowSums()`?

1. Make a faster version of `chisq.test()` that only computes the chi-square test statistic when the input is two numeric vectors with no missing values. You can try simplifying `chisq.test()` or by coding from the [mathematical definition](http://en.wikipedia.org/wiki/Pearson%27s_chi-squared_test).

1. Can you make a faster version of `table()` for the case of an input of two integer vectors with no missing values? Can you use it to speed up your chi-square test?

### Exercises

1. The density functions, e.g., `dnorm()`, have a common interface. Which arguments are vectorised over? What does `rnorm(10, mean = 10:1)` do?

1. Compare the speed of `apply(x, 1, sum)` with `rowSums(x)` for varying sizes of `x`.

1. How can you use `crossprod()` to compute a weighted sum? How much faster is it than the naive `sum(x * w)`?
