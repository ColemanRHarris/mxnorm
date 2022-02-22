#' Internal function to run UMAP algorithm
#'
#' @param udata dataset to use for UMAP algorithm, generated with `get_umap_data()`
#' @param marker_list list of markers in the `mx_dataset` object to use for UMAP algorithm
#' @param downsample_pct double, optional percentage (0, 1] of sample rows to include when running UMAP algorithm. (default=1)
#'
#' @return data.frame
#' @noRd
get_umap_reduction <- function(udata,
                               marker_list,
                               downsample_pct){
    ## downsample
    nr = nrow(udata)
    udata = udata[sample(x = 1:nr,size=nr * downsample_pct),]

    ## run umap with uwot::tumap()
    new_dims = uwot::tumap(udata[,marker_list])
    udata[,c("U1","U2")] = new_dims

    return(udata)
}
