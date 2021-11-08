#' Extension of `summary` S3 method to summarize `mx_dataset` objects
#'
#' @param x `mx_dataset` object to summarize
#'
#' @return TBD
#' @export
#'
#' @examples
#' mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
#'   c("marker1_vals","marker2_vals","marker3_vals"),
#'   c("metadata1_vals"))
#' summary(mx_data)
summary.mx_dataset <- function(mx_data){
    mx_data = validate_mx_dataset(mx_data)

    summ_obj = list()
    summ_obj$mx_data = mx_data
    class(summ_obj) = "summary.mx_dataset"

    ## run summary stats

    summ_obj
}

#' Extension of `print` S3 method to print `summary.mx_dataset` objects
#'
#' @param mx_summ `summary.mx_dataset` object to summarize
#'
#' @return TBD
#' @export
#'
#' @examples
#' mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
#'   c("marker1_vals","marker2_vals","marker3_vals"),
#'   c("metadata1_vals"))
#' print(summary(mx_data))
print.summary.mx_dataset <- function(mx_summ){
    ## basic print
    mx_data = mx_summ$mx_data

    marker_str = paste(mx_data$marker_cols,collapse=", ")
    meta_str = paste(mx_data$metadata_cols, collapse=", ")
    print_str = stringr::str_glue("
                                  Call:
                                  `mx_dataset` object with {mx_data$slide_id} and {mx_data$image_id}\n
                                  markers
                                  {marker_str}\n
                                  metadata
                                  {meta_str}
                                  ")
    print(print_str)
}

summary123.mx_dataset <- function(mx_data){
    summ_obj = list()
    summ_obj$mx_data = mx_data
    class(summ_obj) = "summary.mx_dataset"

    ## basic print
    print_str =
    "
	mx_dataset object with [SLIDE ID] and [IMAGE ID]

	markers
	[marker1_vals, ...]

	metadata_cols
	[metdata1_vals, ...]
	"

    ## if mx_data includes normalization
    summ_obj = summ_obj + norm_summary_table
    summ_obj = summ_obj + norm_AD_test

    print_str = print_str +
    "
	Normalized with [TRANSFORM] [METHOD]

	Anderson-Darling test:
	[RESULTS]
	"

    ## if mx_data includes Otsu
    summ_obj = summ_obj + otsu_summary_table
    summ_obj = summ_obj + otsu_marker_table
    summ_obj = summ_obj + mean_misclass_error

    print_str = print_str +
    "
    Otsu misclassification error:
                mean    SD
    normalized     x     x
    raw            x     x
    "

    ## if mx_data includes UMAP
    summ_obj = summ_obj + slide_clusters
    ## if metadata [need to loop over ]
    summ_obj = summ_obj + metadata_clusters

    print_str = print_str +
    "
    UMAP separation of groups:
                slide    metadata1_vals ...
    normalized     x     x
    raw            x     x
    "

    ## if mx_data includes variance proportions
    summ_obj = summ_obj + var_data
    "
    Proportion of variance at slide level:
                mean    sd
    normalized     x     x
    raw            x     x
    "

}
