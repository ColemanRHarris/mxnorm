#' Internal function to validate mx_dataset object
#'
#' @param x mx_dataset object to validate
#'
#' @return if valid, mx_dataset object from input
validate_mx_dataset <- function(x){
    ## collect default values
    data = x$data
    slide_id = x$slide_id
    image_id = x$image_id
    marker_cols = x$marker_cols
    metadata_cols = x$metadata_cols

    ## confirm data exists
    data_values = data[,marker_cols]
    if(!is.null(metadata_cols)){meta_values = data[,metadata_cols]}

    ## collected potential norm values
    norm_data = x$norm_data
    transform = x$transform
    method = x$method

    ## collected potential otsu values
    otsu_data = x$otsu_data

    ## check uploaded data
    b = check_data_values(data_values)

    ## only runs if x contains normalized data
    if(!is.null(norm_data)){
        norm_values = norm_data[,marker_cols]
        if(!is.null(metadata_cols)){metanorm_values = norm_data[,metadata_cols]}

        ## check normalized data
        b = check_data_values(norm_values)

        ## throw error if transform not present
        if(is.null(transform)){
            stop(
                "Transform attribute not present in mx_dataset object"
            )
        }

        ## throw error if method not present
        if(is.null(method)){
            stop(
                "Method attribute not present in mx_dataset object"
            )
        }

        ## throw error if new data is wrong
        if(any(dim(norm_data) != dim(data))){
            stop(
                "Dimensions of normalized data do not match input data",
                call. = FALSE
            )
        }
    }

    if(!is.null(otsu_data)){
        otsu_values = otsu_data[,c("slide_threshold","marker_threshold","discordance_score")]
        b = check_data_values(otsu_values)
    }

    x
}

#' Internal function to check data values in validation step
#'
#' @param data_values data.frame values to check if valid
#'
#' @return boolean TRUE if passes
check_data_values <- function(data_values){
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

    ## check for NAs
    if(any(is.na(data_values))){
        stop(
            "NA values detected - data cannot contain NA values",
            call. = FALSE
        )
    }

    TRUE
}
