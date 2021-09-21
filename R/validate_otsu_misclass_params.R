#' Internal function to validate parameters passed to `otsu_misclass`
#'
#' @inheritParams otsu_misclass
#'
#' @return `mx_dataset` object
validate_otsu_misclass_params <- function(mx_data,
                                          table,
                                          metadata_cols,
                                          threshold_override){
    ## check args
    table = match.arg(table,c("raw","normalized","both"))

    ## validate dataset
    mx_data = validate_mx_dataset(mx_data)

    ## validate logic
    ## normalized data exists
    if(table %in% c("normalized", "both")){
        if(is.null(mx_data$norm_data)){
            stop(
                "The normalized data table does not exist in the mx_data object. Please use mx_normalize() to normalize data before running otsu_misclass().",
                call. = FALSE
            )
        }
    }

    ## confirm threshold_override is valid
    if(!is.null(threshold_override)){
        c = class(threshold_override)
        if(c == "character"){
            threshold_override = match.arg(threshold_override,c("isodata", "li", "local", "mean", "minimum", "multiotsu", "niblack", "otsu", "sauvola", "triangle","yen"))
        }
        if(c != "function"){
            stop(
                "threshold_override must be a function or thresholding algorithm listed in the Python skimage package",
                call.=FALSE
            )
        }
    }
    mx_data
}
