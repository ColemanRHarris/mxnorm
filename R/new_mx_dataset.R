#' Constructor for mx_dataset
#'
#' @param data multiplexed data to normalize. Data assumed to be a data.frame with cell-level data.
#' @param slide_id String slide identifier of input `data`. This must be a column in the `data` data.frame.
#' @param image_id String image identifier of input `data`. This must be a column in the `data` data.frame.
#' @param marker_cols vector of column name(s) in `data` corresponding to marker values.
#' @param metadata_cols other identifiers of the input `data` (default=NULL). This must be a vector of column name(s) in the `data` data.frame.
#'
#' @return mx_dataset object
#'
#' @examples
new_mx_dataset <- function(data = data.frame(),
                           slide_id = character(),
                           image_id = character(),
                           marker_cols = vector(),
                           metadata_cols = NULL){
    ## confirm types are correct
    stopifnot(is.data.frame(data))
    stopifnot(is.character(slide_id))
    stopifnot(is.character(image_id))

    ## create object
    ret = list(data = data,
         slide_id = slide_id,
         image_id = image_id,
         marker_cols = marker_cols,
         metadata_cols = metadata_cols
         )
    class(ret) = "mx_dataset"
    ret
}
