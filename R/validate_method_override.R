#' Internal function to validate method_override function
#'
#' @param mx_data `mx_dataset` object to normalize
#' @param method_override user-defined function to perform own normalization method
#' @param ... optional additional arguments for `method_override` method
#'
#' @return `mx_dataset` object
validate_method_override <- function(mx_data,
                                     method_override,
                                     ...){
    ## check that all params in method_override are passed
    argg = c("mx_data",names(list(...)))
    margs = names(formals(method_override))

    if(!all(margs %in% argg)){
        stop(
            "The method_override function requires variables not passed",
            call. = FALSE
             )
    }

    ## check that method_override runs on mx_sample, with incl. params, and passes validation
    mx_obj = method_override(mx_data,...)
    mx_obj$method = "Validation"

    ## run validation
    mx_obj = validate_mx_dataset(mx_obj)

    ## return original data bc no changes needed
    mx_data
}

