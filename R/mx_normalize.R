#' Normalizes multiplexed data
#'
#' Normalizes some given image input according to the method specified
#'
#' @param mx_data `mx_dataset` object to normalize
#' @param scale scale transformation to perform on the input data. Options include: c("None", "log10", "mean_divide","log10_mean_divide")
#' @param method normalization method to perform on the input data. Options include: c("None", "ComBat","Registration")
#' @param method_override optional user-defined function to perform own normalization method (default=NULL).
#' @param ... optional additional arguments for normalization functions
#'
#' @return Multiplexed data normalized according to the method specified, in the `mx_dataset` format. Normalized data will be included a new table with normalized values and attributes describing the transformation.
#' @export
#'
#' @examples
#' mx_sample = mx_dataset(mx_sample, "slide_id", "image_id",
#'   c("marker1_vals","marker2_vals","marker3_vals"),
#'   c("metadata1_vals"))
#' mx_normalize(mx_sample, scale="log10",method="ComBat")
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

    ## check method override function
    if(!is.null(method_override)){
        y = validate_method_override(mxnorm::mx_sample,
                                 method_override,
                                 ...)
    }

    ## perform normalization
    mx_obj = normalize_mx_dataset(mx_obj,
                                  method,
                                  method_override,
                                  ...)

    ## validate to confirm if normalization works
    mx_obj = validate_mx_dataset(mx_obj)

    mx_obj
}
