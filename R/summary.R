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

        summ_obj$AD_test_all = all_ADs
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

        summ_obj$otsu_threshold_summary = otsu_summ
        summ_obj$otsu_marker_misclass = otsu_marker_misclass
        summ_obj$otsu_global_misclass = as.data.frame(otsu_global_misclass)
    }

    if(!is.null(mx_data$norm_data) & !is.null(mx_data$umap_data)){
        ## run UMAP stats
        udat1 = get_umap_cluster_results("raw",mx_data)
        udat2 = get_umap_cluster_results("normalized",mx_data)

        raw_slide_adj_rand =  fossil::adj.rand.index(udat1$cluster_slide,udat1$actual_slide)
        raw_slide_kappa = psych::cohen.kappa(udat1[,c("cluster_slide","actual_slide")])$kappa
        norm_slide_adj_rand = fossil::adj.rand.index(udat2$cluster_slide,udat2$actual_slide)
        norm_slide_kappa = psych::cohen.kappa(udat2[,c("cluster_slide","actual_slide")])$kappa

        umap_cluster_res = udat1 %>%
            rbind(udat2) %>%
            dplyr::select(c(mx_data$slide_id,U1,U2, actual_slide,cluster_slide))

        umap_cluster_summ = data.frame(matrix(c(norm_slide_adj_rand,norm_slide_kappa,
                                                raw_slide_adj_rand,raw_slide_kappa),byrow=T,nrow=2,ncol=2))
        colnames(umap_cluster_summ) = c("adj_rand_index","cohens_kappa")
        umap_cluster_summ$table = c("normalized","raw")
        umap_cluster_summ = umap_cluster_summ %>%
            dplyr::relocate(table)

        summ_obj$umap_cluster_results = umap_cluster_res
        summ_obj$umap_cluster_summary =  as.data.frame(umap_cluster_summ)
    }

    if(!is.null(mx_data$var_data)){
        var_prop_summ = mx_data$var_data %>%
            dplyr::filter(level=="slide") %>%
            dplyr::group_by(table) %>%
            dplyr::summarise(mean=mean(proportions),
                             sd=sd(proportions))

        summ_obj$var_prop_summary = as.data.frame(var_prop_summ)
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
        # (slide histograms are from common distribution)
        cat("\n\nAnderson-Darling tests:\n")
        cat(utils::capture.output(print.data.frame(mx_summ$AD_test_summary %>% dplyr::mutate_if(is.numeric,round,digits=3),
                                                   right=TRUE,
                                                   row.names=FALSE)),
            sep="\n")
    }

    if(!is.null(mx_data$otsu_data)){
        # (slide-level agreement of Otsu thresholds)
        cat("\nOtsu misclassification:\n")
        cat(utils::capture.output(print.data.frame(mx_summ$otsu_global_misclass %>% dplyr::mutate_if(is.numeric,round,digits=3),
                                                   right = TRUE,
                                                   row.names = FALSE)),
            sep = "\n")
    }

    if(!is.null(mx_data$umap_data)){
        # (measures of consistency for slide labels)
        cat("\nUMAP clustering:\n")
        cat(utils::capture.output(print.data.frame(mx_summ$umap_cluster_summary %>% dplyr::mutate_if(is.numeric,round,digits=3),
                                                   right=TRUE,
                                                   row.names=FALSE)),
            sep="\n")
    }
    if(!is.null(mx_data$var_data)){
        # (proportion of variance at slide-level)
        cat("\nVariance proportions:\n")
        cat(utils::capture.output(print.data.frame(mx_summ$var_prop_summary %>% dplyr::mutate_if(is.numeric,round,digits=3),
                                                   right=TRUE,
                                                   row.names=FALSE)),
            sep="\n")
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

#' Internal function to generate UMAP clustering results
#'
#' @param table table in `mx_data` to provide clustering results
#' @param mx_data `mx_dataset` object to use to generate clustering results results
#'
#' @return `data.frame` with UMAP clustering results
get_umap_cluster_results <- function(table,
                                     mx_data){
    ## subset to table
    udat = mx_data$umap_data[mx_data$umap_data$table==table,]

    ## run kmeans
    kslide = stats::kmeans(udat[,c("U1","U2")],length(unique(mx_data$data[,mx_data$slide_id])))

    ## add clusters
    udat$cluster_slide = kslide$cluster

    ## add actual slide IDs as numerics
    udat$actual_slide = match(udat[,mx_data$slide_id],unique(udat[,mx_data$slide_id]))

    udat
}
