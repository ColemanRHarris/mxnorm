#' Internal function to normalize mx_dataset using functional data registration
#'
#' @param mx_data `mx_dataset` object to normalize
#' @param ... optional additional arguments for `normalize_mx_registration`
#'
#' @return `mx_dataset` object with normalized data with updated attribute `norm_data` (data.frame) and new attribute `method` (character)
normalize_mx_registration <- function(mx_data,
                                      len=512,
                                      weighted=TRUE,
                                      offset=0.0001,
                                      fdobj_norder=4, ##approx hist
                                      fdobj_nbasis=21,
                                      w_norder=2, ##linear transform
                                      w_nbasis=2,
                                ...){
    ndat = mx_data$norm_data
    cols = mx_data$marker_cols
    slide = mx_data$slide_id

    ## apply combat function over columns
    ndat[,cols] <- sapply(X = cols, function(x){
        run_registration(marker=x,
                         slide_var=slide,
                         ndat=ndat,
                         len=len,
                         weighted=weighted,
                         offset=offset,
                         fdobj_norder=fdobj_norder,
                         fdobj_nbasis=fdobj_nbasis,
                         w_norder=w_norder,
                         w_nbasis=w_nbasis)
    })

    mx_data$norm_data = ndat

    mx_data
}
