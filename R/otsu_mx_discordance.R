#' Internal function to run discordance score analysis on otsu table
#'
#' @inheritParams run_otsu_discordance
#'
#' @return `mx_dataset` object with discordance results
otsu_mx_discordance <- function(mx_data,
                                      table){
    ## setup local params
    cols = mx_data$marker_cols
    otsu_data = mx_data$otsu_data
    slide_id = mx_data$slide_id

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
                              cols,
                              slide_id)

        ## setup params
        tdat = mx_data$norm_data
        slides = unique(tdat[,mx_data$slide_id])

        ## calc for normalized
        mdat2 = otsu_mx_error(tdat,
                              table = "normalized",
                              otsu_data,
                              slides,
                              cols,
                              slide_id)

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
                              cols,
                              slide_id)
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
                              cols,
                              slide_id)
    }

    otsu_data$discordance_score = mdat

    ## fix slide id naming
    if(!("slide_id" %in% colnames(otsu_data))){
        colnames(otsu_data)[colnames(otsu_data) == slide_id] <- "slide_id"
    }

    mx_data$otsu_data = otsu_data
    mx_data$otsu_table = table

    mx_data
}
