options(warn=1)  # Show warnings when running through CHAP

library(readr)

train_chap <- function(csv_fn, model_fn) {
  df <- read_csv(csv_fn)
  #write code to train your model, and save the trained model to model_fn
}

args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 2) {
  csv_fn <- args[1]
  model_fn <- args[2]

  train_chap(csv_fn, model_fn)
}# else {
#  stop("Usage: Rscript train.R <csv_fn> <model_fn>")
#}
