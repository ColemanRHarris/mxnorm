#' Calculate Otsu discordance scores using specified threshold for an `mx_dataset` object.
#'
#' The Otsu discordance analysis quantifies slide-to-slide agreement by summarizing
#' the distance between slide-level Otsu thresholds and the global Otsu threshold
#' for a given marker in a single metric.
#'
#' @param mx_data `mx_dataset` object used to compute Otsu discordance scores
#' @param table  dataset in `mx_data` used to compute metrics. Options include: c("raw","normalized","both"), e.g. a y-axis parameter.
#' @param threshold_override optional user-defined function or alternate thresholding algorithm adaptable from Python skimage module `filters` (Note: not all algorithms in `filters` adapted). Options include supplying a function or any of the following: c("isodata", "li", "mean", "otsu", "triangle","yen"). More detail available here:https://scikit-image.org/docs/dev/api/skimage.filters.html. If using a user-defined function, it must include a `thold_data` parameter.
#' @param plot_out boolean to generate Otsu discordance plots (default=FALSE)
#' @param ... optional additional arguments for Otsu discordance functions
#'
#' @references Otsu, N. (1979). A threshold selection method from gray-level histograms. IEEE transactions on systems, man, and cybernetics, 9(1), 62-66.
#'
#' @return `mx_dataset` object with analysis results of Otsu discordance in `otsu_data` table
#'
#' @export
#'
#' @examples
#' mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
#'   c("marker1_vals","marker2_vals","marker3_vals"),
#'   c("metadata1_vals"))
#' mx_data = mx_normalize(mx_data, transform="log10",method="None")
#' ## using `threshold_override` here in case users haven't installed `scikit-image`
#' mx_data = run_otsu_discordance(mx_data, table="normalized",
#' threshold_override = function(thold_data){quantile(thold_data, 0.5)})
run_otsu_discordance <- function(mx_data,
                          table,
                          threshold_override = NULL,
                          plot_out = FALSE,
                          ...){
    ## validate parameters
    mx_obj = validate_otsu_discordance_params(mx_data,
                                            table,
                                            threshold_override)

    ## set correct threshold & validate
    threshold = get_discordance_thold(threshold_override,
                               ...)

    ## create otsu dataset
    mx_obj = otsu_mx_dataset(mx_obj,
                             table,
                             threshold)

    ## run misclassification
    mx_obj = otsu_mx_discordance(mx_obj,
                                       table)

    ## plot out if desired
    if(plot_out){
        print(plot_mx_density(mx_obj))
        print(plot_mx_discordance(mx_obj))
    }

    ## set threshold param
    if(!is.null(threshold_override)){
        if(class(threshold_override) == "character"){
            thold_val = threshold_override
        } else{
            thold_val = "user-defined"
        }
    } else{
        thold_val = "otsu"
    }
    mx_obj$threshold = thold_val

    mx_obj
}
