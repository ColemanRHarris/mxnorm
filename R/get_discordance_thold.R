#' Internal function to select correct thresholding algorithm
#'
#' @inheritParams run_otsu_discordance
#'
#' @return function to use as thresholding algorithm
get_discordance_thold <- function(threshold_override,
                               ...){
    ## return Otsu if null
    if(is.null(threshold_override)){
        skf <- reticulate::import("skimage.filters")
        return(skf["threshold_otsu"])
    }
    ## return other skf module if character
    if(class(threshold_override) == "character"){
        skf <- reticulate::import("skimage.filters")
        return(skf[paste0("threshold_",threshold_override)])
    }
    ## validate function if user-defined
    if(class(threshold_override) == "function"){
        threshold_override = validate_threshold_override(threshold_override,
                                        ...)
    }

    threshold_override
}


# global reference to scipy (will be initialized in .onLoad)
skf <- NULL

.onLoad <- function(libname, pkgname) {
    # use superassignment to update global reference to scipy
    skf <<- reticulate::import("skimage.filters", delay_load = TRUE)
}
