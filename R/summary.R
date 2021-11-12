#' Extension of `summary` S3 method to summarize `mx_dataset` objects
#'
#' @param object `mx_dataset` object to summarize
#' @param ... option for additional params given S3 logic
#'
#' @importFrom magrittr %>%
#'
#' @return `summary.mx_dataset` object
#' @export
#'
#' @examples
#' mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
#'   c("marker1_vals","marker2_vals","marker3_vals"),
#'   c("metadata1_vals"))
#' summary(mx_data)
summary.mx_dataset <- function(object, ...){
    ## validate
    mx_data <- object; rm(object)
    mx_data = validate_mx_dataset(mx_data)

    ## setup object
    summ_obj = list()
    summ_obj$mx_data = mx_data
    class(summ_obj) = "summary.mx_dataset"

    ## run summary stats
    if(!is.null(mx_data$norm_data)){
        ## generate marker summaries
        marker_summ = mx_data$data %>%
            dplyr::summarise(dplyr::across(mx_data$marker_cols,list(mean=mean,sd=stats::sd))) %>%
            dplyr::mutate("table"="raw") %>%
            rbind(mx_data$norm_data %>%
                      dplyr::summarise(dplyr::across(mx_data$marker_cols,list(mean=mean,sd=stats::sd))) %>%
                      dplyr::mutate("table"="normalized")) %>%
            dplyr::relocate(table)

        summ_obj$marker_summary = marker_summ

        ## run anderson darling
        all_ADs = get_ad_test_stats(mx_data$data,mx_data) %>%
            dplyr::mutate("table"="raw") %>%
            dplyr::relocate(table,marker) %>%
            rbind(get_ad_test_stats(mx_data$norm_data,mx_data) %>%
                      dplyr::mutate("table"="normalized") %>%
                      dplyr::relocate(table,marker))
        summ_ADs = all_ADs %>%
            dplyr::group_by(table) %>%
            dplyr::summarise(mean_test_statistic = mean(ad_test_statistic),
                      mean_std_test_statistic = mean(std_ad_test_statistic),
                      mean_p_value = mean(ad_p_value))

        summ_obj$AD_all_tests = all_ADs
        summ_obj$AD_test_summary = as.data.frame(summ_ADs)
    }

    if(!is.null(mx_data$otsu_data)){
        ## otsu threshold by marker (in object)
        otsu_summ = mx_data$otsu_data %>%
            dplyr::group_by(marker,table) %>%
            dplyr::summarise(mean=mean(slide_threshold),
                      sd=stats::sd(slide_threshold)) %>%
            dplyr::left_join(dplyr::distinct(mx_data$otsu_data[,c("marker","table","marker_threshold")]),
                      by=c("marker","table")) %>%
            dplyr::relocate(marker_threshold,.after="table")

        ## otsu misclass by marker (in object)
        otsu_marker_misclass = mx_data$otsu_data %>%
            dplyr::group_by(marker,table) %>%
            dplyr::summarise(mean=mean(misclass_error))

        ## otsu misclass all markers (output)
        otsu_global_misclass = mx_data$otsu_data %>%
            dplyr::group_by(table) %>%
            dplyr::summarise(mean_misclass=mean(misclass_error),
                      sd_misclass=stats::sd(misclass_error))

        summ_obj$otsu_summary = otsu_summ
        summ_obj$otsu_marker_misclass = otsu_marker_misclass
        summ_obj$otsu_global_misclass = as.data.frame(otsu_global_misclass)
    }

    summ_obj
}

#' Extension of `print` S3 method to print `summary.mx_dataset` objects
#'
#' @param x `summary.mx_dataset` object to summarize
#' @param ... option for additional params given S3 logic
#'
#' @return NULL
#' @export
#'
#' @examples
#' mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
#'   c("marker1_vals","marker2_vals","marker3_vals"),
#'   c("metadata1_vals"))
#' print(summary(mx_data))
print.summary.mx_dataset <- function(x, ...){
    ## basic print
    mx_summ <- x; rm(x)
    mx_data = mx_summ$mx_data

    # marker_str = paste(mx_data$marker_cols,collapse=", ")
    # meta_str = paste(mx_data$metadata_cols, collapse=", ")
    # print_str = stringr::str_glue("Call:\n`mx_dataset` object with {mx_data$slide_id} and {mx_data$image_id}\n\nmarkers\n{marker_str}\n\nmetadata\n{meta_str}")
    print_str = stringr::str_glue("Call:\n`mx_dataset` object with {length(unique(mx_data$data[,mx_data$slide_id]))} slide(s), {length(mx_data$marker_cols)} marker column(s), and {length(mx_data$metadata_cols)} metadata column(s)")

    cat(print_str)
    if(!is.null(mx_data$norm_data)){
        cat(stringr::str_glue("\n\n\nNormalization:\nData normalized with transformation=`{mx_data$transform}` and method=`{mx_data$method}`"))
        cat("\n\nAnderson-Darling Tests:\n")
        cat(utils::capture.output(print.data.frame(mx_summ$AD_test_summary %>% dplyr::mutate_if(is.numeric,round,digits=3),
                                                   right=TRUE,
                                                   row.names=FALSE)),
            sep="\n")
    }

    if(!is.null(mx_data$otsu_data)){
        cat("\nOtsu misclassification:\n")
        cat(utils::capture.output(print.data.frame(mx_summ$otsu_global_misclass %>% dplyr::mutate_if(is.numeric,round,digits=3),
                                                   right = TRUE,
                                                   row.names = FALSE)),
            sep = "\n")
    }
}

#' Internal function to generate Anderson-Darling test statistics
#'
#' @param data_table mx_data table to provide statistics
#' @param mx_data `mx_dataset` object to use to calc statistics
#' @param n_bins number of bins for density calculation (default=100). Large values of `n_bins` will slow computation considerably.
#'
#' @return `data.table` with AD test results
get_ad_test_stats <- function(data_table,
                              mx_data,
                              n_bins=100){
    #scipy_stats = reticulate::import("scipy.stats")

    data.table::rbindlist(
        lapply(mx_data$marker_cols, function(m){
            m1 = min(data_table[,m])
            m2 = max(data_table[,m])

            ## using stats::density()
            # all_dens = sapply(unique(data_table[,mx_data$slide_id]), function(s){
            #     stats::density(data_table[data_table$slide_id==s,m],
            #                    from = m1,
            #                    to = m2,
            #                    n = n_bins)$y
            # })
            ## faster density with KernSmooth::bkde()

            all_dens = sapply(unique(data_table[,mx_data$slide_id]), function(s){
                suppressWarnings(KernSmooth::bkde(x=data_table[data_table[,mx_data$slide_id]==s,m],
                                                  gridsize = n_bins,
                                                  range.x = c(m1,m2))$y)
            })

            ## using kSamples:ad.test()
            m_ad = data.frame(kSamples::ad.test(data.frame(all_dens))$ad,check.names = FALSE)[1,]

            ## using scipy.stats from python
            #ad_test = scipy_stats$anderson_ksamp(reticulate::np_array(all_dens))
            #m_ad = data.frame(matrix(c(ad_test$statistic,ad_test$significance_level),nrow=1,ncol=2))
            #colnames(m_ad) = c("ad_test_statistic","ad_test_signif_level")

            colnames(m_ad) = c("ad_test_statistic","std_ad_test_statistic","ad_p_value")
            m_ad$marker = m
            m_ad
        })
    )
}
