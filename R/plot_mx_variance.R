#' Visualize Otsu misclassification metrics by marker and slide
#'
#' @param mx_data `mx_dataset` object that been used with `otsu_misclass()` to compute Otsu misclassification metrics
#'
#' @return `ggplot2` object with misclassification plot
#' @export
#'
#' @import ggplot2
#'
#' @examples
#' mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
#'   c("marker1_vals","marker2_vals","marker3_vals"),
#'   c("metadata1_vals"))
#' mx_data = mx_normalize(mx_data, scale="log10",method="None")
#' mx_data = otsu_misclass(mx_data, table="normalized")
#' plot_mx_variance(mx_data)
plot_mx_variance <- function(mx_data){
    ## validate step
    mx_data = validate_mx_dataset(mx_data)
    if(is.null(mx_data$otsu_data)){
        stop("You must run the otsu_misclass() analysis before generating this plot.",
             call.=FALSE)
    }

    ## get relevant values
    otsu_data = mx_data$otsu_data
    jitter_val = mean(otsu_data$misclass_error) * 0.1
    point_size = 4
    misclass_error = NULL ## set to not get CRAN notes
    slide_id = NULL ## set to not get CRAN notes

    ## calculate additional values

    ## slide means
    mean_vals = otsu_data %>%
        dplyr::group_by(slide_id,table) %>%
        dplyr::summarise(m1 = mean(misclass_error),.groups="drop")

    ## table means
    rug_vals =  otsu_data %>%
        dplyr::group_by(table) %>%
        dplyr::summarise(m2 = mean(misclass_error),.groups="drop")

    ## generate plots
    ggplot(otsu_data) +
        geom_jitter(aes_string(x="misclass_error",y="slide_id",color="marker"),size=point_size,height=0,width=jitter_val) +
        geom_point(data = mean_vals,aes_string(x="m1",y="slide_id"),color="black",fill="white",shape=23,size=point_size) +
        facet_wrap(~table,nrow=2,ncol=1) +
        #geom_rug(data = rug_vals,mapping=aes(x=m2)) +
        scale_color_discrete("Marker") +
        scale_x_continuous("Misclassification Error")+
        scale_y_discrete("")+
        theme(axis.text.y = element_text(hjust = 0))
}
