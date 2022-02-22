#' Internal function to normalize mx_dataset
#'
#' @param mx_data `mx_dataset` object to normalize
#' @param method normalization transformation to perform on the input data. Options include: c("None", "ComBat","Registration")
#' @param method_override optional user-defined function to perform own normalization method (default=NULL). This function must be in the same form as internal functions `normalize_mx_combat()` and `normalize_mx_registration()`, e.g. that they change the `norm_data` (data.frame) attribute of the input `mx_dataset` object.
#' @param method_override_name optional name for method_override (default=NULL).
#' @param ... optional additional arguments for normalization functions
#'
#' @return `mx_dataset` object with normalized data with updated attribute `norm_data` (data.frame) and new attribute `method` (character)
#' @noRd
normalize_mx_dataset <- function(mx_data,
                                 method,
                                 method_override=NULL,
                                 method_override_name=NULL,
                                 ...){
    ## do nothing if None
    if(method == "None"){
        mx_data$norm_data = mx_data$norm_data
    }
    if(method == "ComBat"){
        mx_data = normalize_mx_combat(mx_data, ...)
    }
    if(method == "Registration"){
        mx_data = normalize_mx_registration(mx_data, ...)
    }

    mx_data$method = method
    if(!is.null(method_override)){
        mx_data = method_override(mx_data, ...)
        if(!is.null(method_override_name)){
            mx_data$method = method_override_name
        } else{
            mx_data$method = "user-defined"
        }
    }

    mx_data
}
