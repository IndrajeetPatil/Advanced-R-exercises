# Translation



### Exercises 21.2.6

**Q1.** The escaping rules for `<script>` tags are different because they contain JavaScript, not HTML. Instead of escaping angle brackets or ampersands, you need to escape `</script>` so that the tag isn't closed too early. For example, `script("'</script>'")`, shouldn't generate this:

```html
  <script>'</script>'</script>
```

But

```html
  <script>'<\/script>'</script>
```

Adapt the `escape()` to follow these rules when a new argument `script` is set to `TRUE`.

**Q2.** The use of `...` for all functions has some big downsides. There's no input validation and there will be little information in the documentation or autocomplete about how they are used in the function. Create a new function that, when given a named list of tags and their attribute names (like below), creates tag functions with named arguments.


```r
list(
  a = c("href"),
  img = c("src", "width", "height")
)
```

All tags should get `class` and `id` attributes.

**Q3.** Reason about the following code that calls `with_html()` referencing objects from the environment. Will it work or fail? Why? Run the code to verify your predictions.


```r
greeting <- "Hello!"
with_html(p(greeting))
p <- function() "p"
address <- "123 anywhere street"
with_html(p(address))
```

**Q4.** Currently the HTML doesn't look terribly pretty, and it's hard to see the structure. How could you adapt `tag()` to do indenting and formatting? (You may need to do some research into block and inline tags.)

### Exercises 21.3.8

**Q1.** Add escaping. The special symbols that should be escaped by adding a backslash in front of them are `\`, `$`, and `%`. Just as with HTML, you'll need to make sure you don't end up double-escaping. So you'll need to create a small S3 class and then use that in function operators. That will also allow you to embed arbitrary LaTeX if needed.

**Q2.** Complete the DSL to support all the functions that `plotmath` supports.
