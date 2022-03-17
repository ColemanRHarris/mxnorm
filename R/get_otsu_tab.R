#' Title
#'
#' @inheritParams otsu_mx_dataset
#'
#' @param tdat data in the `mx_dataset` object used to calculate Otsu thresholds
#' @param cols columns of markers in the  `mx_dataset` object used to calculate Otsu threshold
#' @param slide column identifying different slides in the  `mx_dataset` object used to calculate Otsu threshold
#' @param use_np_array boolean indicating if np_arrays are necessary
#'
#' @importFrom magrittr %>%
#'
#' @return list of calculated Otsu thresholds
#' @noRd
get_otsu_tab <- function(tdat,
                         cols,
                         slide,
                         table,
                         threshold,
                         use_np_array){
    ## if a python threshold, use np_array
    if(use_np_array){
        lapply(X=cols,function(x){
            tdat %>%
                dplyr::group_by_at(slide) %>%
                dplyr::summarise(table=table,
                                 slide_threshold=threshold(reticulate::np_array(.data[[x]])),
                                 .groups = 'drop') %>%
                dplyr::mutate(marker_threshold=(tdat %>% dplyr::summarise(m=threshold(reticulate::np_array(.data[[x]]))))$m) %>%
                dplyr::mutate(marker=x) %>% dplyr::relocate(marker,.after=slide)
        })
    } else{ ##otherwise just use the data
        lapply(X=cols,function(x){
            tdat %>%
                dplyr::group_by_at(slide) %>%
                dplyr::summarise(table=table,
                                 slide_threshold=threshold(.data[[x]]),
                                 .groups = 'drop') %>%
                dplyr::mutate(marker_threshold=(tdat %>% dplyr::summarise(m=threshold(.data[[x]])))$m) %>%
                dplyr::mutate(marker=x) %>% dplyr::relocate(marker,.after=slide)
        })

    }
}
