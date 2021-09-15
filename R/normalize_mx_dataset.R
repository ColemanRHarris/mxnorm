#' Internal function to normalize mx_dataset
#'
#' @param mx_data `mx_dataset` object to normalize
#' @param method normalization transformation to perform on the input data. Options include: c("None", "ComBat","Registration")
#' @param method_override optional user-defined function to perform own normalization method (default=NULL).
#' @param ... optional additional arguments for normalization functions
#'
#' @return `mx_dataset` object with normalized data with updated attribute `norm_data` (data.frame) and new attribute `method` (character)
#' @importFrom rlang .data
normalize_mx_dataset <- function(mx_data,
                                 method,
                                 method_override=NULL,
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
    if(!is.null(method_override)){
        mx_data = method_override(mx_data, ...)
    }

    mx_data$method = method
    mx_data
}
