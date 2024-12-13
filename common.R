# example R options set globally
options(
  width             = 60,
  tibble.width      = Inf,
  pillar.bold       = TRUE,
  pillar.neg        = TRUE,
  pillar.subtle_num = TRUE,
  pillar.min_chars  = Inf
)

# example chunk options set globally
knitr::opts_chunk$set(
  comment     = "#>",
  collapse    = TRUE,
  strip.white = FALSE,
  out.width   = "100%"
)

# for reproducibility
set.seed(1024)

# needed for the pipe operator
library(magrittr)
options(crayon.enabled = FALSE)

emojis <- emoji::emoji_name
