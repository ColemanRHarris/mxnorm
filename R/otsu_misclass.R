#' Calculate misclassification metrics using specified threshold for an `mx_dataset` object.
#'
#' @param mx_data `mx_dataset` object used to compute Otsu misclassification metrics
#' @param table  dataset in `mx_data` used to compute metrics. Options include: c("raw","normalized","both"), e.g. a y-axis parameter.
#' @param metadata_cols column name(s) in `mx_data` used to generate stratified results (default=NULL), e.g. a facet parameter.
#' @param threshold_override optional user-defined function or alternate thresholding algorithm in Python skimage module `filters`. Options include supplying a function or any of the following: c("isodata", "li", "local", "mean", "minimum", "multiotsu", "niblack", "otsu", "sauvola", "triangle","yen"). More detail available here:https://scikit-image.org/docs/dev/api/skimage.filters.html. If using a user-defined function, it must include a `thold_data` parameter.
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
otsu_misclass <- function(mx_data,
                          table,
                          metadata_cols = NULL,
                          threshold_override = NULL,
                          plot_out = TRUE,
                          ...){
    ## validate parameters
    mx_obj = validate_otsu_misclass_params(mx_data,
                                            table,
                                            metadata_cols,
                                            threshold_override)

    ## set correct threshold & validate
    threshold = get_misclass_thold(threshold_override,
                               ...)

    ## **run Otsu misclassification
    mx_obj = otsu_mx_dataset(mx_obj,
                             table,
                             threshold,
                             metadata_cols)

    ## **plot out if desired
    if(plot_out){
        plot_mx_density(mx_obj,table)
        plot_mx_proportions(mx_obj,table)
    }

    mx_obj
}
