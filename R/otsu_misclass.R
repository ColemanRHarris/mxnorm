#' Calculate misclassification metrics using specified threshold for an `mx_dataset` object.
#'
#' @param mx_data `mx_dataset` object used to compute Otsu misclassification metrics
#' @param table  dataset in `mx_data` used to compute metrics. Options include: c("raw","normalized","both"), e.g. a y-axis parameter.
#' @param threshold_override optional user-defined function or alternate thresholding algorithm adaptable from Python skimage module `filters` (Note: not all algorithms in `filters` adapted). Options include supplying a function or any of the following: c("isodata", "li", "mean", "otsu", "triangle","yen"). More detail available here:https://scikit-image.org/docs/dev/api/skimage.filters.html. If using a user-defined function, it must include a `thold_data` parameter.
#' @param plot_out boolean to generate Otsu misclassification plots (default=FALSE)
#' @param ... optional additional arguments for Otsu misclassification functions
#'
#' @references Otsu, N. (1979). A threshold selection method from gray-level histograms. IEEE transactions on systems, man, and cybernetics, 9(1), 62-66.
#'
#' @return `mx_dataset` object with analysis results of Otsu misclassification in `otsu_data` table
#'
#' @export
#'
#' @examples
#' mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
#'   c("marker1_vals","marker2_vals","marker3_vals"),
#'   c("metadata1_vals"))
#' mx_data = mx_normalize(mx_data, scale="log10",method="None")
#' mx_data = otsu_misclass(mx_data, table="normalized")
otsu_misclass <- function(mx_data,
                          table,
                          threshold_override = NULL,
                          plot_out = FALSE,
                          ...){
    ## validate parameters
    mx_obj = validate_otsu_misclass_params(mx_data,
                                            table,
                                            threshold_override)

    ## set correct threshold & validate
    threshold = get_misclass_thold(threshold_override,
                               ...)

    ## create otsu dataset
    mx_obj = otsu_mx_dataset(mx_obj,
                             table,
                             threshold)

    ## run misclassification
    mx_obj = otsu_mx_misclassification(mx_obj,
                                       table)

    ## **plot out if desired
    # if(plot_out){
    #     plot_mx_density(mx_obj,table)
    #     plot_mx_proportions(mx_obj,table)
    # }

    mx_obj
}
