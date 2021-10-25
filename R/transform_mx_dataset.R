#' Internal function to transform mx_dataset
#'
#' @param mx_data `mx_dataset` object to normalize
#' @param transform transformation to perform on the input data. Options include: c("None", "log10", "mean_divide","log10_mean_divide")
#'
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#' @importFrom dplyr all_of
#'
#' @return `mx_dataset` object with transformed data, added attributes: `norm_data` (data.frame) and `transform` (character)
transform_mx_dataset <- function(mx_data,
                             transform){
    ## factors s.t. log10 transform is not undefined
    log10_factor = 1
    log10_mean_divide_factor = 0.5

    ## do nothing if None
    if(transform == "None"){
        mx_data$norm_data = mx_data$data
    }
    if(transform == "log10"){
        x = mx_data$data
        cols = mx_data$marker_cols

        ## log10 transform
        x[,cols] = log10(x[,cols]+log10_factor)
        mx_data$norm_data = x
    }
    if(transform == "mean_divide"){
        x = mx_data$data
        cols = mx_data$marker_cols

        ## get column length slide means
        y = x %>%
            dplyr::group_by(.data[[mx_data$slide_id]]) %>%
            dplyr::mutate(dplyr::across(all_of(cols),mean))

        ## divide
        x[,cols] = x[,cols]/y[,cols]

        ## rescale
        x = x %>%
             dplyr::mutate(dplyr::across(all_of(cols),function(a){a + -min(a)}))

        mx_data$norm_data = x
    }
    if(transform == "log10_mean_divide"){
        x = mx_data$data
        cols = mx_data$marker_cols

        ## get column length slide means
        y = x %>%
            dplyr::group_by(.data[[mx_data$slide_id]]) %>%
            dplyr::mutate(dplyr::across(all_of(cols),mean))

        ## divide
        x[,cols] = x[,cols]/y[,cols]
        x[,cols] = log10(x[,cols] + log10_mean_divide_factor)

        ## rescale
        x= x %>%
            dplyr::mutate(dplyr::across(all_of(cols),function(a){a + -min(a)}))

        mx_data$norm_data = x
    }

    mx_data$transform = transform
    mx_data
}
