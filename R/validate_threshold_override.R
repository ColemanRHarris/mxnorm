#' Internal function to validate user defined thresholding algorithm
#'
#' @param mx_data `mx_dataset` object used to calculate threshold
#' @param threshold_override optional user-defined function or alternate thresholding algorithm in Python skimage module `filters`. Options include supplying a function or any of the following: c("isodata", "li", "local", "mean", "minimum", "multiotsu", "niblack", "otsu", "sauvola", "triangle","yen"). More detail available here:https://scikit-image.org/docs/dev/api/skimage.filters.html
#' @param ... optional additional arguments for Otsu misclassification functions
#'
#' @return boolean indicating a pass
#'
#' @examples
validate_threshold_override <- function(mx_data,
                                        threshold_override,
                                        ...){
    ## check that all params in threshold_override are passed
    argg = c("mx_data",names(list(...)))
    targs = names(formals(threshold_override))

    if(!all(targs %in% argg)){
        stop(
            "The threshold_override function requires variables not passed",
            call. = FALSE
        )
    }

    ## run test case with sample data
    thold = threshold_override(mx_data$marker1_vals,...)

    ## check data values (for Inf, NA, numerics)
    check_data_values(thold)
}
