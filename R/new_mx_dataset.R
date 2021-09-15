#' Constructor for mx_dataset object
#'
#' @inheritParams mx_dataset
#'
#' @return mx_dataset object with attributes `data` (data.frame), `slide_id` (character), `image_id` (character), `marker_cols` (vector), `metadata_cols` (default: NULL, otherwise vector).
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
