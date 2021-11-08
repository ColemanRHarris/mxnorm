#' Visualize variance proportions by marker and table
#'
#' @param mx_data `mx_dataset` object that been used with `run_var_proportions()` to run random effects modeling. Note that the table attribute must be set when running `run_var_proportions()`.
#'
#' @return `ggplot2` object with proportions plot
#' @export
#'
#' @import ggplot2
#'
#' @examples
#' mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
#'   c("marker1_vals","marker2_vals","marker3_vals"),
#'   c("metadata1_vals"))
#' mx_data = mx_normalize(mx_data, transform="log10",method="None")
#' mx_data = run_var_proportions(mx_data, table="both")
#' plot_mx_proportions(mx_data)
plot_mx_proportions <- function(mx_data){
    ## validate step
    mx_data = validate_mx_dataset(mx_data)
    if(is.null(mx_data$var_data)){
        stop(
            "You must run the run_var_proportions() analysis before generating this plot.",
            call. = FALSE)
    }

    ## set to not get CRAN notes
    level = NULL

    vdata = mx_data$var_data
    #ggplot(vdata %>% filter(level=="slide"), aes_string(x="proportions",y="marker",color="table")) + geom_point()
    ggplot(vdata, aes_string(x="proportions",y="marker")) +
        geom_col(aes(fill=level)) +
        facet_wrap(~table)
}
