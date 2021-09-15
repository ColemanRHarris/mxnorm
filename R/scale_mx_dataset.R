#' Internal function to scale mx_dataset
#'
#' @param mx_data `mx_dataset` object to normalize
#' @param scale scale transformation to perform on the input data. Options include: c("None", "log10", "mean_divide","log10_mean_divide")
#'
#' @return `mx_dataset` object with scaled data, added attributes: `norm_data` (data.frame) and `scale` (character)
#' @importFrom rlang .data
scale_mx_dataset <- function(mx_data,
                             scale){
    ## factors s.t. log10 transform is not undefined
    log10_factor = 1
    log10_mean_divide_factor = 0.5

    ## do nothing if None
    if(scale == "None"){
        mx_data$norm_data = mx_data$data
    }
    if(scale == "log10"){
        x = mx_data$data
        cols = mx_data$marker_cols

        ## log10 transform
        x[,cols] = log10(x[,cols]+log10_factor)
        mx_data$norm_data = x
    }
    if(scale == "mean_divide"){
        x = mx_data$data
        cols = mx_data$marker_cols

        ## get column length slide means
        y = x %>%
            dplyr::group_by(.data[[mx_data$slide_id]]) %>%
            dplyr::mutate(dplyr::across(cols,mean))

        ## divide
        x[,cols] = x[,cols]/y[,cols]

        ## rescale
        x = x %>%
             dplyr::mutate(dplyr::across(cols,function(a){a + -min(a)}))

        mx_data$norm_data = x
    }
    if(scale == "log10_mean_divide"){
        x = mx_data$data
        cols = mx_data$marker_cols

        ## get column length slide means
        y = x %>%
            dplyr::group_by(.data[[mx_data$slide_id]]) %>%
            dplyr::mutate(dplyr::across(cols,mean))

        ## divide
        x[,cols] = x[,cols]/y[,cols]
        x[,cols] = log10(x[,cols] + log10_mean_divide_factor)

        ## rescale
        x= x %>%
            dplyr::mutate(dplyr::across(cols,function(a){a + -min(a)}))

        mx_data$norm_data = x
    }

    mx_data$scale = scale
    mx_data
}
