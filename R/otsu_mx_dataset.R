#' Internal function to generate table for otsu misclassification analysis
#'
#' @inheritParams otsu_misclass
#' @param threshold thresolding function as defined using `otsu_misclass()`
#'
#' @importFrom magrittr %>%
#'
#' @return `mx_dataset` object with `otsu_data` attribute added and misclassification results
otsu_mx_dataset <- function(mx_data,
                            table,
                            threshold){
    ## check if threshold is in skf to use np_array
    use_np_array = FALSE
    if(any(grepl("python",class(threshold)))){ use_np_array = TRUE }

    ## setup variables for other functions
    cols = mx_data$marker_cols
    slide = mx_data$slide_id

    ## generate slide level otsus
    if(table == "both"){
        ## run for raw, table = raw
        o1 = get_otsu_tab(tdat=mx_data$data,
                          cols,
                          slide,
                          table="raw",
                          threshold,
                          use_np_array) %>%
            data.table::rbindlist()

        ## run for normalized, table = normalized
        o2 = get_otsu_tab(tdat=mx_data$norm_data,
                          cols,
                          slide,
                          table="normalized",
                          threshold,
                          use_np_array) %>%
            data.table::rbindlist()

        otsu_data = rbind(o1,o2)
    }
    if(table == "raw"){
        ## run for raw, table = raw
        otsu_data = get_otsu_tab(tdat=mx_data$data,
                                 cols,
                                 slide,
                                 table,
                                 threshold,
                                 use_np_array) %>%
            data.table::rbindlist()
    }
    if(table == "normalized"){
        ## run for normalized, table = normalized
        otsu_data = get_otsu_tab(tdat=mx_data$norm_data,
                                 cols,
                                 slide,
                                 table,
                                 threshold,
                                 use_np_array) %>%
            data.table::rbindlist()
    }

    mx_data$otsu_data = data.frame(otsu_data)

    mx_data
}
