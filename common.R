# example R options set globally
options(width = 60, tibble.width = Inf)

# example chunk options set globally
knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  strip.white = FALSE
)

# needed libraries
library(tidyverse, warn.conflicts = FALSE)
library(lobstr, warn.conflicts = FALSE)
library(sloop, warn.conflicts = FALSE)
library(rlang, warn.conflicts = FALSE)
library(fastmatch, warn.conflicts = FALSE)

# for reproducibility
set.seed(1024)
