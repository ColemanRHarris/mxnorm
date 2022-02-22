#' Internal function to create long data object from `mx_dataset` object
#'
#' @param mx_data `mx_dataset` object
#'
#' @importFrom magrittr %>%
#'
#' @return `data.frame` in long format
#' @noRd
get_long_data <- function(mx_data){
    ## mx_data should always have raw data
    rdata = mx_data$data
    rdata$table = "raw"

    ## check if normalized
    if(!is.null(mx_data$norm_data)){
        ndata = mx_data$norm_data
        ndata$table = "normalized"
    }

    ## check if otsu data
    if(!is.null(mx_data$otsu_data)){
        odata = mx_data$otsu_data
        if(mx_data$otsu_table == "both"){
            base_data = rbind(rdata,ndata)
            rm(rdata,ndata)
        } else if(mx_data$otsu_table == "normalized"){
            base_data = ndata
            rm(rdata,ndata)
        } else{
            base_data = rdata
            rm(rdata)
        }
    }

    ## make it long
    long_data = base_data %>%
        tidyr::gather(mx_data$marker_cols,
                      key = "marker",
                      value="marker_value")
    rm(base_data)

    ## create join on to match naming conventions
    join_on = c("slide_id","marker","table")
    names(join_on) = c(mx_data$slide_id,"marker","table")

    ## add otsu data
    if(!is.null(odata)){
        long_data = long_data %>%
            dplyr::left_join(y = odata,
                             by = join_on)
        rm(odata)
    }

    long_data
}
