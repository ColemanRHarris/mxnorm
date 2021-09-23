#' Internal function to run misclassification analysis on otsu table
#'
#' @inheritParams otsu_misclass
#'
#' @return `mx_dataset` object with misclassification results
otsu_mx_misclassification <- function(mx_data,
                                      table){
    ## setup local params
    cols = mx_data$marker_cols
    otsu_data = mx_data$otsu_data

    ## if both
    if(table == "both"){
        ## setup params
        tdat = mx_data$data
        slides = unique(tdat[,mx_data$slide_id])

        ## calc for raw
        mdat1 = otsu_mx_error(tdat,
                              table = "raw",
                              otsu_data,
                              slides,
                              cols)

        ## setup params
        tdat = mx_data$norm_data
        slides = unique(tdat[,mx_data$slide_id])

        ## calc for normalized
        mdat2 = otsu_mx_error(tdat,
                              table = "normalized",
                              otsu_data,
                              slides,
                              cols)

        ## rbind
        mdat = c(mdat1,mdat2)
    }

    ## if raw
    if(table == "raw"){
        ## setup params
        tdat = mx_data$data
        slides = unique(tdat[,mx_data$slide_id])

        ## calc for raw
        mdat = otsu_mx_error(tdat,
                              table = "raw",
                              otsu_data,
                              slides,
                              cols)
    }

    ## if normalized
    if (table == "normalized"){
        ## setup params
        tdat = mx_data$norm_data
        slides = unique(tdat[,mx_data$slide_id])

        ## calc for normalized
        mdat = otsu_mx_error(tdat,
                              table = "normalized",
                              otsu_data,
                              slides,
                              cols)
    }

    otsu_data$misclass_error = mdat
    mx_data$otsu_data = otsu_data

    mx_data
}
