#' Internal function to trim mx_dataset
#'
#' @param data multiplexed data to normalize. Data assumed to be a data.frame with cell-level data.
#' @param slide_id String slide identifier of input `data`. This must be a column in the `data` data.frame.
#' @param image_id String image identifier of input `data`. This must be a column in the `data` data.frame.
#' @param marker_cols vector of column name(s) in `data` corresponding to marker values.
#' @param metadata_cols other identifiers of the input `data` (default=NULL). This must be a vector of column name(s) in the `data` data.frame.
#'
#' @return subset of data
#'
#' @examples
trim_dataset <- function(data,
                          slide_id,
                          image_id,
                          marker_cols,
                          metadata_cols = NULL){
    if(!is.null(metadata_cols)){
        if(!all(c(slide_id,image_id,marker_cols,metadata_cols) %in% colnames(data))){
            stop(
                "All column identifiers must be in the dataset",
                call. = FALSE
            )
        }
        return(data[,c(slide_id,image_id,marker_cols,metadata_cols)])
    }


    if(!all(c(slide_id,image_id,marker_cols) %in% colnames(data))){
        stop(
            "All column identifiers must be in the dataset",
            call. = FALSE
        )
    }
    data[,c(slide_id,image_id,marker_cols)]
}
