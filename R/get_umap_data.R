#' Internal function to setup dataset for UMAP algorithm
#'
#' @inheritParams run_reduce_umap
#'
#' @return data.frame for umap analysis
get_umap_data <- function(mx_data,
                          table,
                          marker_list,
                          metadata_cols){
    if(table == "normalized"){
        dat = mx_data$norm_data
    } else {
        dat = mx_data$data
    }

    dat = dat[,c(marker_list,metadata_cols)]
    dat$table = table

    dat
}
