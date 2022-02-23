#' Internal function to validate parameters passed to `run_var_proportions`
#'
#' @inheritParams run_var_proportions
#'
#' @return `mx_datast` object
#' @noRd
validate_var_proportions_params <- function(mx_data,
                                table,
                                metadata_cols,
                                formula_override,
                                save_models){
    ## check args
    table = match.arg(table,c("raw","normalized","both"))
    #save_models = match.arg(save_models,c(TRUE,FALSE))

    ## validate dataset
    mx_data = validate_mx_dataset(mx_data)

    ## normalized data exists
    if(table %in% c("normalized", "both")){
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

    ## if metadatacols not NULL, check raw data
    if(!is.null(metadata_cols)){
        if(!all(metadata_cols %in% mx_data$metadata_cols)){
            stop(
                "The metadata columns provided do not match the raw data.",
                call. = FALSE
            )
        }
    }

    ##check on formula override
    if(!is.null(formula_override)){
        if(class(formula_override) != "character"){
            stop(
                "The formula_override provided is not a string.",
                call. = FALSE
            )
        }
        if(!any(grepl(paste0("slide|",mx_data$slide_id),stringr::str_to_lower(paste(formula_override))))){
            stop(
                "None of the covariates provided in formula_override match the slide identifier."
            )
        }
    }
    mx_data
}
