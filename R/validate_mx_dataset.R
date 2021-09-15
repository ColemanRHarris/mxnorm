#' Internal function to validate mx_dataset
#'
#' @param x mx_dataset object to validate
#'
#' @return mx_dataset object
#'
#' @examples
validate_mx_dataset <- function(x){
    ## collect values
    data = x$data
    slide_id = x$slide_id
    image_id = x$image_id
    marker_cols = x$marker_cols
    metadata_cols = x$metadata_cols
    data_values = data[,marker_cols]

    ## check for infinite values
    if(any(data_values == Inf | data_values == -Inf)){
        stop(
            "Infinite values detected - data cannot contain infinite values",
            call. = FALSE
        )
    }

    ## check for numeric
    if(!all(unlist(lapply(data_values,is.numeric)))){
        stop(
            "Non-numeric values detected - data cannot contain non-numeric values",
            call. = FALSE
        )
    }

    if(any(is.na(data_values))){
        stop(
            "NA values detected - data cannot contain NA values",
            call. = FALSE
        )
    }
    x
}
