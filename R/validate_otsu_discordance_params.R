#' Internal function to validate parameters passed to `run_otsu_discordance`
#'
#' @inheritParams run_otsu_discordance
#'
#' @return `mx_dataset` object
#' @noRd
validate_otsu_discordance_params <- function(mx_data,
                                          table,
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
                "The normalized data table does not exist in the mx_data object. Please use mx_normalize() to normalize data before running run_otsu_discordance().",
                call. = FALSE
            )
        }
    }

    ## confirm threshold_override is valid
    if(!is.null(threshold_override)){
        c = class(threshold_override)
        if(c == "character"){
            threshold_override = match.arg(threshold_override,c("isodata", "li", "mean", "otsu", "triangle","yen"))
        }else if(c != "function"){
            stop(
                "threshold_override must be a function or thresholding algorithm listed in the Python skimage package",
                call.=FALSE
            )
        }
    }
    mx_data
}
