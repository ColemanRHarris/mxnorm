#' Internal function to validate mx_normalize args
#'
#' @param mx_data `mx_dataset` object to normalize
#' @param scale scale transformation to perform on the input data. Options include: c("None", "log10", "mean_divide","log10_mean_divide")
#' @param method normalization method to perform on the input data. Options include: c("None", "ComBat","Registration")
#' @param method_override optional user-defined function to perform own normalization method (default=NULL).
#'
#' @return `mx_dataset` object
#'
#' @examples
validate_mx_normalize_params <- function(mx_data,
                                         scale,
                                         method,
                                         method_override){
    ## check args
    scale = match.arg(scale, c("None", "log10", "mean_divide","log10_mean_divide"))
    method = match.arg(method, c("None", "ComBat","Registration"))
    stopifnot(class(mx_data)=="mx_dataset")

    ## check & validate method override
    if(!is.null(method_override)){
        if(method!="None"){
            stop(
                "method argument must be 'None' when using method_override",
                call. = FALSE
             )
        }
        if(class(method_override)!="function"){
            stop(
                "method_override must be a function",
                call. = FALSE
            )
        }
    }
    mx_data
}
