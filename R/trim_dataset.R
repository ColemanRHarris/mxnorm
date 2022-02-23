#' Internal function to trim input data for `mx_dataset()`
#'
#' @inheritParams mx_dataset
#'
#' @return subset of data input to `mx_dataset()` (data.frame)
#' @noRd
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
