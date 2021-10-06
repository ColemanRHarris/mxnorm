#' Visualize UMAP dimension reduction algorithm
#'
#' @param mx_data `mx_dataset` object that been used with `run_reduce_umap()` to compute the UMAP dimensions for the dataset. Note that the table attribute must be set when running `run_reduce_umap()`.
#' @param metadata_col column denoted in the `run_reduce_umap()` to change the scale_color attribute of the ggplot (default=NULL)
#'
#' @return `ggplot2` object with density plot
#' @export
#'
#' @import ggplot2
#'
#' @examples
#' mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
#'   c("marker1_vals","marker2_vals","marker3_vals"),
#'   c("metadata1_vals"))
#' mx_data = mx_normalize(mx_data, scale="log10",method="None")
#' mx_data = run_reduce_umap(mx_data, table="normalized",
#' c("marker1_vals","marker2_vals","marker3_vals"))
#' plot_mx_umap(mx_data)
plot_mx_umap <- function(mx_data,
                         metadata_col=NULL){
    ## validate step
    mx_data = validate_mx_dataset(mx_data)
    if(is.null(mx_data$umap_data)){
        stop(
            "You must run the run_reduce_umap() analysis before generating this plot.",
             call. = FALSE)
    }

    udata = mx_data$umap_data

    if(!is.null(metadata_col)){
        if(!(metadata_col %in% colnames(udata))){
            stop(
                "The metadata column provided is not present in the UMAP data table. Be sure to include it when running run_reduce_umap().",
                call. = FALSE
            )
        }

        g1 = ggplot(udata) +
            geom_point(aes_string(x="U1",y="U2",color=metadata_col))
    } else{
        g1 = ggplot(udata) +
            geom_point(aes_string(x="U1",y="U2"))
    }

    g1 + facet_wrap(~table)
}
