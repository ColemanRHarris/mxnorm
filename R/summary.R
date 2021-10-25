#' Setup S3 method for `summary`
#'
#' @param x used to define S3 method (later assumed to be `mx_dataset` object)
#'
#' @return NULL
summary <- function(x) UseMethod("summary")

#' Extension of `summary` S3 method to summarize `mx_dataset` objects
#'
#' @param x `mx_dataset` object to summarize
#'
#' @return TBD
#' @export
#'
#' @examples summary(mxnorm::mx_sample)
summary.mx_dataset <- function(x){
    length(x)
    ## however we want to summarize
}

