#' Generates mx_dataset
#'
#' Takes in data from data.frame of cell-level multiplexed data to create a mx_dataset S3 object.
#'
#' @param data multiplexed data to normalize. Data assumed to be a data.frame with cell-level data.
#' @param slide_id String slide identifier of input `data`. This must be a column in the `data` data.frame.
#' @param image_id String image identifier of input `data`. This must be a column in the `data` data.frame.
#' @param marker_cols vector of column name(s) in `data` corresponding to marker values.
#' @param metadata_cols other identifiers of the input `data` (default=NULL). This must be a vector of column name(s) in the `data` data.frame.
#'
#' @return data.frame object in the mx_dataset format with attribute for input type
#' @export
#'
#' @examples
#' mx_dataset(mx_sample, "slide_id", "image_id",
#'   c("marker1_vals","marker2_vals","marker3_vals"),
#'   c("metadata1_vals"))
mx_dataset = function(data,
                      slide_id,
                      image_id,
                      marker_cols,
                      metadata_cols = NULL){

    ## trim `data` to remove any columns not in parameters
    data = trim_dataset(data,slide_id,image_id,marker_cols,metadata_cols)

    ## use `data` as base of S3 object
    ## add attributes for slide_id and image_id (column name),
    ## incl. column names of markers, column names of metadata
    mx_obj = new_mx_dataset(data,
                            slide_id = slide_id,
                            image_id = image_id,
                            marker_cols = marker_cols,
                            metadata_cols = metadata_cols)

    return(mx_obj)
}
## unit test 3: should run if generated with equivalent slide_id and image_id
## unit test 4: warning if data input size is larger than some value.
