library(profvis)

source("profiling-exercises.R")

profvis(f())

profvis(f(), torture = TRUE)
