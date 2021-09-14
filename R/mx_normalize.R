#' Normalizes multiplexed data
#'
#' Normalizes some given image input according to the method specified
#'
#' @param mx_data `mx_dataset` object to normalize
#' @param scale scale transformation to perform on the input data. Options include: c("None", "log10", "mean_divide","log10_mean_divide")
#' @param method normalization method to perform on the input data. Options include: c("None", "ComBat","Registration")
#' @param method_override optional user-defined function to perform own normalization method (default=NULL).
#'
#' @return Multiplexed data normalized according to the method specified, in the `mx_dataset` format. Normalized data will be included a new table with normalized values and attributes describing the transformation.
#' @export
#'
#' @examples
mx_normalize <- function(mx_data,
                         scale = "None",
                         method = "None",
                         method_override = NULL,
                         ...){
    ## validate parameters
    mx_obj = validate_mx_normalize_params(mx_data,
                                          scale,
                                          method,
                                          method_override)

    ## scale transformation
    mx_obj = scale_mx_dataset(mx_data,
                              scale)

    ## if method_override
    ## check that all necessary params passed to mx_normalize()
    ## check that method_override runs on mx_sample, with incl. params, and passes validation

    ## --- perform normalization (internal function)
    ## check & run if none
    ## check & run if method override
    ## check & run if ComBat
    ## check & run if Registration

    #mx_obj = normalize_mx_dataset(...)

    ## validate if normalization works/reasonable, even if method_override (needed in both cases)
    #mx_obj = validate_mx_normalize(...)

    mx_obj
}
