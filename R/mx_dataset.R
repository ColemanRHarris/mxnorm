#' Generates mx_dataset
#'
#' Takes in data from data.frame of cell-level multiplexed data to create a mx_dataset
#'
#' @param data multiplexed data to normalize. Data assumed to be a data.frame with cell-level data.
#' @param image_id String image identifier of input `data`. This must be a column in the `data` data.frame.
#' @param slide_id String slide identifier of input `data`. This must be a column in the `data` data.frame.
#' @param marker_cols vector of column name(s) in `data` corresponding to marker values.
#' @param metadata_cols other identifiers of the input `data` (default=NULL). This must be a vector of column name(s) in the `data` data.frame.
#'
#' @return data.frame object in the mx_dataset format with attribute for input type
#' @export
#'
#' @examples
mx_dataset = function(data,
                      image_id,
                      slide_id,
                      marker_cols,
                      metadata_cols = NULL, ...){
    ## transform input data into data.frame object with these columns: {markerValue, image_id, slide_id, ... metadata ...}

    ## transform into long

    ## add basic information attributes about data to mx_dataset object (e.g. list of metadata_cols, number of cols and rows, etc.)
    return(ncol(data))
}

## unit test 1: `slide_id` and `image_id` and `marker_cols` exist in `data`.
## unit test 2: if `metadata_cols` == !NULL, check if cols exist in `data`.
## unit test 3: should run if generated with equivalent slide_id and image_id
## unit test 4: warning if data input size is larger than some value.
## unit test 5: confirm if data is in fact long or wide
