#' Internal function to validate mx_normalize args
#'
#' @inheritParams mx_normalize
#'
#' @return `mx_dataset` object
validate_mx_normalize_params <- function(mx_data,
                                         transform,
                                         method,
                                         method_override){
    ## check args
    transform = match.arg(transform, c("None", "log10", "mean_divide","log10_mean_divide"))
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
