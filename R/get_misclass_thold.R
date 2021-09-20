#' Internal function to select correct thresholding algorithm
#'
#' @inheritParams otsu_misclass
#'
#' @return function to use as thresholding algorithm
get_misclass_thold <- function(threshold_override,
                               ...){
    ## import skf
    skf = reticulate::import("skimage.filters")

    ## return Otsu if null
    if(is.null(threshold_override)){
        return(skf["threshold_otsu"])
    }
    ## return other skf module if character
    if(class(threshold_override) == "character"){
        return(skf[paste0("threshold_",threshold_override)])
    }
    ## validate function if user-defined
    if(class(threshold_override) == "function"){
        y = validate_threshold_override(mxnorm::mx_sample,
                                    threshold_override,
                                    ...)
    }

    threshold_override
}
