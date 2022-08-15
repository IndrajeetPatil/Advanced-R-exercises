# Translation



Needed libraries:


```r
library(rlang)
library(purrr)
```

### Exercises 21.2.6

---

**Q1.** The escaping rules for `<script>` tags are different because they contain JavaScript, not HTML. Instead of escaping angle brackets or ampersands, you need to escape `</script>` so that the tag isn't closed too early. For example, `script("'</script>'")`, shouldn't generate this:

```html
  <script>'</script>'</script>
```

But

```html
  <script>'<\/script>'</script>
```

Adapt the `escape()` to follow these rules when a new argument `script` is set to `TRUE`.

**A1.**


```r
escape <- function(x, ...) UseMethod("escape")

escape.character <- function(x, script = FALSE) {
  if (script) {
    x <- gsub("</script>", "<\\/script>", x, fixed = TRUE)
  } else {
    x <- gsub("&", "&amp;", x)
    x <- gsub("<", "&lt;", x)
    x <- gsub(">", "&gt;", x)
  }

  html(x)
}

escape.advr_html <- function(x, ...) x
```

We will also need to tweak the boilerplate to pass this additional parameter to `escape()`:


```r
html <- function(x) structure(x, class = "advr_html")

print.advr_html <- function(x, ...) {
  out <- paste0("<HTML> ", x)
  cat(paste(strwrap(out), collapse = "\n"), "\n", sep = "")
}

dots_partition <- function(...) {
  dots <- list2(...)

  if (is.null(names(dots))) {
    is_named <- rep(FALSE, length(dots))
  } else {
    is_named <- names(dots) != ""
  }

  list(
    named = dots[is_named],
    unnamed = dots[!is_named]
  )
}

tag <- function(tag, script = FALSE) {
  force(script)
  new_function(
    exprs(... = ),
    expr({
      dots <- dots_partition(...)
      attribs <- html_attributes(dots$named)
      children <- map_chr(.x = dots$unnamed, .f = ~ escape(.x, !!script))

      html(paste0(
        !!paste0("<", tag), attribs, ">",
        paste(children, collapse = ""),
        !!paste0("</", tag, ">")
      ))
    }),
    caller_env()
  )
}

void_tag <- function(tag) {
  new_function(
    exprs(... = ),
    expr({
      dots <- dots_partition(...)
      if (length(dots$unnamed) > 0) {
        abort(!!paste0("<", tag, "> must not have unnamed arguments"))
      }
      attribs <- html_attributes(dots$named)

      html(paste0(!!paste0("<", tag), attribs, " />"))
    }),
    caller_env()
  )
}

p <- tag("p")
script <- tag("script", script = TRUE)
```


```r
script("'</script>'")
#> <HTML> <script>'<\/script>'</script>
```

---

**Q2.** The use of `...` for all functions has some big downsides. There's no input validation and there will be little information in the documentation or autocomplete about how they are used in the function. Create a new function that, when given a named list of tags and their attribute names (like below), creates tag functions with named arguments.


```r
list(
  a = c("href"),
  img = c("src", "width", "height")
)
```

All tags should get `class` and `id` attributes.

---

**Q3.** Reason about the following code that calls `with_html()` referencing objects from the environment. Will it work or fail? Why? Run the code to verify your predictions.


```r
greeting <- "Hello!"
with_html(p(greeting))
p <- function() "p"
address <- "123 anywhere street"
with_html(p(address))
```

**A3.** To work with this, we first need to copy-paste relevant code from the book:


```r
tags <- c(
  "a", "abbr", "address", "article", "aside", "audio",
  "b", "bdi", "bdo", "blockquote", "body", "button", "canvas",
  "caption", "cite", "code", "colgroup", "data", "datalist",
  "dd", "del", "details", "dfn", "div", "dl", "dt", "em",
  "eventsource", "fieldset", "figcaption", "figure", "footer",
  "form", "h1", "h2", "h3", "h4", "h5", "h6", "head", "header",
  "hgroup", "html", "i", "iframe", "ins", "kbd", "label",
  "legend", "li", "mark", "map", "menu", "meter", "nav",
  "noscript", "object", "ol", "optgroup", "option", "output",
  "p", "pre", "progress", "q", "ruby", "rp", "rt", "s", "samp",
  "script", "section", "select", "small", "span", "strong",
  "style", "sub", "summary", "sup", "table", "tbody", "td",
  "textarea", "tfoot", "th", "thead", "time", "title", "tr",
  "u", "ul", "var", "video"
)

void_tags <- c(
  "area", "base", "br", "col", "command", "embed",
  "hr", "img", "input", "keygen", "link", "meta", "param",
  "source", "track", "wbr"
)

html_tags <- c(
  tags %>% set_names() %>% map(tag),
  void_tags %>% set_names() %>% map(void_tag)
)

with_html <- function(code) {
  code <- enquo(code)
  eval_tidy(code, html_tags)
}
```

Note that `with_html()` uses `eval_tidy()`, and therefore `code` argument is evaluated first in the `html_tags` named list, which acts as a data mask, and if no object is found in the data mask, searches in the caller environment.

For this reason, the first example code will work:


```r
greeting <- "Hello!"
with_html(p(greeting))
#> <HTML> <p>Hello!</p>
```

The following code, however, is not going to work because there is already `address` element in the data mask, and so `p()` will take a function `address()` as an input, and `escape()` doesn't know how to deal with objects of `function` type:


```r
"address" %in% names(html_tags)
#> [1] TRUE

p <- function() "p"
address <- "123 anywhere street"
with_html(p(address))
#> Error in UseMethod("escape"): no applicable method for 'escape' applied to an object of class "function"
```

---

**Q4.** Currently the HTML doesn't look terribly pretty, and it's hard to see the structure. How could you adapt `tag()` to do indenting and formatting? (You may need to do some research into block and inline tags.)

**A4.** 


```r
html_tags$p(
  "Some text. ",
  html_tags$b(html_tags$i("some bold italic text")),
  class = "mypara"
)
#> <HTML> <p class='mypara'>Some text. <b><i>some bold
#> italic text</i></b></p>
```


---

### Exercises 21.3.8

---

**Q1.** Add escaping. The special symbols that should be escaped by adding a backslash in front of them are `\`, `$`, and `%`. Just as with HTML, you'll need to make sure you don't end up double-escaping. So you'll need to create a small S3 class and then use that in function operators. That will also allow you to embed arbitrary LaTeX if needed.

---

**Q2.** Complete the DSL to support all the functions that `plotmath` supports.

---
