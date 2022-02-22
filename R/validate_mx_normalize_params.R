#' Internal function to validate mx_normalize args
#'
#' @inheritParams mx_normalize
#'
#' @return `mx_dataset` object
#' @noRd
validate_mx_normalize_params <- function(mx_data,
                                         transform,
                                         method,
                                         method_override=NULL,
                                         method_override_name=NULL){
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
        if(class(method_override_name)!="character"){
            stop(
                "method_override_name must be a character",
                call.=FALSE
            )
        }
    }
    if(!is.null(method_override_name)){
        if(is.null(method_override)){
            stop(
                "method_override_name can only be used when method_override is not NULL",
                call.=FALSE
            )
        }
    }
    mx_data
}
