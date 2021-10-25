#' Visualize marker density before/after normalization by marker and slide
#'
#' @param mx_data `mx_dataset` object that been used with `run_otsu_misclass()` to compute Otsu misclassification metrics (necessary for the density rug plot). Note that the table attribute must be set when running `run_otsu_misclass()`.
#'
#' @return `ggplot2` object with density plot
#' @export
#'
#' @import ggplot2
#' @importFrom magrittr %>%
#'
#' @examples
#' mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
#'   c("marker1_vals","marker2_vals","marker3_vals"),
#'   c("metadata1_vals"))
#' mx_data = mx_normalize(mx_data, transform="log10",method="None")
#' mx_data = run_otsu_misclass(mx_data, table="normalized")
#' plot_mx_density(mx_data)
plot_mx_density <- function(mx_data){
    ## validate step
    mx_data = validate_mx_dataset(mx_data)
    if(is.null(mx_data$otsu_data)){
        stop("You must run the run_otsu_misclass() analysis before generating this plot.",
             call.=FALSE)
    }

    ## get relevant values
    long_data = get_long_data(mx_data)
    slide_id = mx_data$slide_id

    ## plot
    ggplot(long_data) +
        geom_density(aes_string(x="marker_value",color=slide_id)) +
        geom_rug(aes_string(x="slide_threshold",color=slide_id)) +
        facet_wrap(table~marker,scales = "free",nrow=2,ncol=length(mx_data$marker_cols))
}
