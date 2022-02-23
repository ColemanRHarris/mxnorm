#' Internal function to validate parameters passed to `run_reduce_umap`
#'
#' @inheritParams run_reduce_umap
#'
#' @return `mx_datast` object
#' @noRd
validate_reduce_umap_params <- function(mx_data,
                                        table,
                                        marker_list,
                                        downsample_pct,
                                        metadata_cols){
    ## check args
    table = match.arg(table,c("raw","normalized","both"))

    ## validate dataset
    mx_data = validate_mx_dataset(mx_data)

    ## validate logic
    ## normalized data exists
    if(table %in% c("normalized", "both")){
        ## check marker list is in norm data
        if(!all(marker_list %in% colnames(mx_data$norm_data))){
            stop(
                "The marker list provided does not match the normalized data.",
                call. = FALSE
            )
        }

        ## if metadatacols not NULL, check norm data
        if(!is.null(metadata_cols)){
            if(!all(metadata_cols %in% colnames(mx_data$norm_data))){
                stop(
                    "The metadata columns provided do not match the normalized data.",
                    call. = FALSE
                )
            }
        }
    }

    ## check that marker list is in data
    if(!all(marker_list %in% mx_data$marker_cols)){
        stop(
            "The marker list provided does not match the raw data.",
            call. = FALSE
        )
    }

    ## if metadatacols not NULL, check raw data
    if(!is.null(metadata_cols)){
        if(!all(metadata_cols %in% mx_data$metadata_cols)){
            stop(
                "The metadata columns provided do not match the raw data.",
                call. = FALSE
            )
        }
    }

    ## downsample pct between 0 and 1
    if(!(downsample_pct > 0 & downsample_pct <= 1)){
        stop(
            "The downsample percentage must be a value greater than 0 and less than or equal to 1.",
            call.=FALSE
        )
    }

    mx_data
}
