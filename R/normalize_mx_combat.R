#' Internal function to normalize mx_dataset using ComBat
#'
#' @param mx_data `mx_dataset` object to normalize
#' @param remove_zeroes,tol,... optional additional arguments for `normalize_mx_combat`
#'
#' @return `mx_dataset` object with normalized data with updated attribute `norm_data` (data.frame) and new attribute `method` (character)
#' @noRd
normalize_mx_combat <- function(mx_data,
                                remove_zeroes=FALSE,
                                tol=0.0001,
                                 ...){
    ndat = mx_data$norm_data
    cols = mx_data$marker_cols
    slide = mx_data$slide_id

    ## apply combat function over columns
    ndat[,cols] <- sapply(X = cols, function(x){
        run_combat(marker=x,
                   slide_var=slide,
                   ndat=ndat,
                   remove_zeroes=remove_zeroes,
                   tol = tol
                   )
        })

    mx_data$norm_data = ndat

    mx_data
}
