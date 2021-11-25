#' Internal function to validate user defined thresholding algorithm
#'
#' @inheritParams run_otsu_agreement
#'
#' @return threshold_override function if it passes
validate_threshold_override <- function(threshold_override,
                                        ...){
    ## check that all params in threshold_override are passed
    argg = c(names(list(...)))
    targs = names(formals(threshold_override))
    if(!("thold_data" %in% targs)){
        stop(
            "The threshold_override function must specify a parameter 'thold_data' to use for thresholding."
        )
    }

    targs = targs[-which(targs=="thold_data")]

    if(length(targs) > 0 & !all(targs %in% argg)){
        stop(
            "threshold_override parameters do not match the variables passed to the function",
            call. = FALSE
        )
    }

    ## run test case with sample data
    thold = threshold_override(thold_data = mxnorm::mx_sample$marker1_vals, ...)

    ## check data values (for Inf, NA, numerics)
    check_data_values(thold)

    threshold_override
}
