#' Run UMAP dimension reduction algorithm on an `mx_dataset` object.
#'
#' @param mx_data `mx_dataset` object used to compute UMAP dimensions
#' @param table dataset in `mx_data` used to compute metrics. Options include: c("raw","normalized","both"), e.g. a y-axis parameter.
#' @param marker_list list of markers in the `mx_dataset` object to use for UMAP algorithm
#' @param downsample_pct double, optional percentage (0, 1] of sample rows to include when running UMAP algorithm. (default=1)
#' @param metadata_cols other identifiers of the input `data` (default=NULL). This must be a vector of column name(s) in the `mx_dataset` object
#'
#' @return `mx_dataset` object with analysis results of UMAP dimension results in `umap_data` table
#' @export
#'
#' @examples
#' mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
#'   c("marker1_vals","marker2_vals","marker3_vals"),
#'   c("metadata1_vals"))
#' mx_data = mx_normalize(mx_data, scale="log10",method="None")
#' mx_data = run_reduce_umap(mx_data, table="normalized",c("marker1_vals","marker2_vals","marker3_vals"))
run_reduce_umap <- function(mx_data,
                            table,
                            marker_list,
                            downsample_pct=1,
                            metadata_cols=NULL){
    ## validate params
    mx_data = validate_reduce_umap_params(mx_data,
                                          table,
                                          marker_list,
                                          downsample_pct,
                                          metadata_cols)

    ## setup umap data with metadata_cols
    if(table == "both"){
        udata1 = get_umap_data(mx_data,"raw",marker_list,metadata_cols)
        udata2 = get_umap_data(mx_data,"normalized",marker_list,metadata_cols)

        udata1 = get_umap_reduction(udata1,marker_list,downsample_pct)
        udata2 = get_umap_reduction(udata2,marker_list,downsample_pct)
        udata = rbind(udata1,udata2)
        rm(udata1,udata2)
    } else{
        udata = get_umap_data(mx_data,table,marker_list,metadata_cols)
        udata = get_umap_reduction(udata,marker_list,downsample_pct)
    }

    mx_data$umap_data = udata

    mx_data
}
