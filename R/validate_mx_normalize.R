
## check that norm data dims = data dims
## check that all values numeric
## check that no NA values

validate_mx_normalize <- function(x){
    ## check that nothing in the original data is incorrect
    x = validate_mx_dataset(x)

    ## check that normalized data is correct
    data = x$data
    norm_data = x$norm_data


    ## collect values
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
