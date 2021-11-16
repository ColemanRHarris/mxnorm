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
    mx_obj1 = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
      c("marker1_vals","marker2_vals","marker3_vals"),
      c("metadata1_vals"))
    mx_obj2 = method_override(mx_obj1,...)
    mx_obj2$method = 'validation'
    mx_obj2$transform = 'validation'

    ## run validation
    mx_obj2 = validate_mx_dataset(mx_obj2)

    TRUE
}

