#' Visualize Otsu agreement scores by marker and slide
#'
#' @param mx_data `mx_dataset` object that been used with `run_otsu_agreement()` to compute Otsu agreement scores. Note that the table attribute must be set when running `run_otsu_agreement()`.
#'
#' @return `ggplot2` object with Otsu agreement scores plot
#' @export
#'
#' @import ggplot2
#' @importFrom magrittr %>%
#'
#' @examples
#' mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
#'   c("marker1_vals","marker2_vals","marker3_vals"),
#'   c("metadata1_vals"))
#' mx_data = mx_normalize(mx_data, transform="log10",method="None")
#' mx_data = run_otsu_agreement(mx_data, table="normalized")
#' plot_mx_agreement(mx_data)
plot_mx_agreement <- function(mx_data){
    ## validate step
    mx_data = validate_mx_dataset(mx_data)
    if(is.null(mx_data$otsu_data)){
        stop("You must run the run_otsu_agreement() analysis before generating this plot.",
             call.=FALSE)
    }

    ## get relevant values
    otsu_data = mx_data$otsu_data
    jitter_val = mean(otsu_data$agreement_score) * 0.1
    point_size = 4

    ## set to not get CRAN notes
    agreement_score = NULL
    slide_id = NULL

    ## calculate additional values - slide means
    mean_vals = otsu_data %>%
        dplyr::group_by(slide_id,table) %>%
        dplyr::summarise(m1 = mean(agreement_score),.groups="drop")

    ## generate plots
    ggplot(otsu_data) +
        geom_jitter(aes_string(x="agreement_score",y="slide_id",color="marker"),size=point_size,height=0,width=jitter_val) +
        geom_point(data = mean_vals,aes_string(x="m1",y="slide_id"),color="black",fill="white",shape=23,size=point_size) +
        facet_wrap(~table,nrow=2,ncol=1)
}
