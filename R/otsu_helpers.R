#' Internal function to calculate misclassification error
#'
#' @param vec vector of values to compare
#' @param thr1 first threshold used to compare values
#' @param thr2 second threshold used to compare values
#'
#' @return decimal value of misclassification error
check_threshold = function(vec,thr1,thr2){
    tab = caret::confusionMatrix(factor(vec>thr1),factor(vec>thr2),)$table

    return(sum(tab/sum(tab) * (1-diag(2))))
}

#' Internal helper function to compute and return Otsu table
#'
#' @param tdat table of raw or normalized values
#' @param table dataset in `mx_data` used to compute metrics. Options include: c("raw","normalized","both"), e.g. a y-axis parameter.
#' @param otsu_data otsu dataset created using `otsu_mx_dataset()`
#' @param slides vector of slides in the dataset
#' @param cols vector of marker columns
#'
#' @importFrom magrittr %>%
#'
#' @return `data.frame` with Otsu misclassification metrics
otsu_mx_error = function(tdat,table,otsu_data,slides,cols){
    lapply(cols,function(x){
        lapply(slides,function(s){
            vec = tdat[tdat$slide_id==s,x]
            idx = which(otsu_data$slide_id == s & otsu_data$marker == x & otsu_data$table == table)
            check_threshold(vec,otsu_data[idx,]$slide_threshold,otsu_data[idx,]$marker_threshold)
        })
    }) %>% unlist()
}
