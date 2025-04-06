## function to deal with duplicated column names when loading BayesTraits tables

custom_name_repair <- function(names) {
  ave(names, names, FUN = function(x) {
    if (length(x) == 1) return(x)
    paste0(x, c("", paste0("_", seq_along(x)[-1])))
  })
}
