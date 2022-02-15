#' Normalizes multiplexed data
#'
#' Normalizes some given image input according to the method specified
#'
#' @param mx_data `mx_dataset` object to normalize
#' @param transform transformation to perform on the input data. Options include: c("None", "log10", "mean_divide","log10_mean_divide")
#' @param method normalization method to perform on the input data. Options include: c("None", "ComBat","Registration")
#' @param method_override optional user-defined function to perform own normalization method (default=NULL). If using a user-defined function, it must include a `mx_data` parameter.
#' @param method_override_name optional name for method_override (default=NULL).
#' @param ... optional additional arguments for normalization functions
#'
#' @return Multiplexed data normalized according to the method specified, in the `mx_dataset` format. Normalized data will be included a new table with normalized values and attributes describing the transformation.
#' @export
#'
#' @examples
#' mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
#'   c("marker1_vals","marker2_vals","marker3_vals"),
#'   c("metadata1_vals"))
#' mx_data = mx_normalize(mx_data, transform="log10",method="None")
mx_normalize <- function(mx_data,
                         transform = "None",
                         method = "None",
                         method_override = NULL,
                         method_override_name = NULL,
                         ...){
    ## validate parameters
    mx_obj = validate_mx_normalize_params(mx_data,
                                          transform,
                                          method,
                                          method_override,
                                          method_override_name)

    ## transformation
    mx_obj = transform_mx_dataset(mx_data,
                              transform)

    ## check method override function
    if(!is.null(method_override)){
        validate_method_override(method_override,
                                 ...)
    }

    ## perform normalization
    mx_obj = normalize_mx_dataset(mx_obj,
                                  method,
                                  method_override,
                                  method_override_name,
                                  ...)

    ## validate to confirm if normalization works
    mx_obj = validate_mx_dataset(mx_obj)

    mx_obj
}
