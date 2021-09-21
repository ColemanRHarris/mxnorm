#' Internal function to validate method_override function
#'
#' @param method_override user-defined function to perform own normalization method
#' @param ... optional additional arguments for `method_override` method
#'
#' @return boolean indicating a pass
validate_method_override <- function(method_override,
                                     ...){
    ## check that all params in method_override are passed
    argg = c(names(list(...)))
    margs = names(formals(method_override))
    if(!("mx_data" %in% margs)){
        stop(
            "The method_override function must specify a parameter 'mx_data' to use for thresholding."
        )
    }

    margs = margs[-which(margs=="mx_data")]

    if(length(margs) > 0 & !all(margs %in% argg)){
        stop(
            "The method_override function requires variables not passed",
            call. = FALSE
             )
    }

    ## check that method_override runs on mx_sample, with incl. params, and passes validation
    mx_obj = method_override(mxnorm::mx_sample,...)
    mx_obj$method = "Validation"

    ## run validation
    mx_obj = validate_mx_dataset(mx_obj)

    TRUE
}

