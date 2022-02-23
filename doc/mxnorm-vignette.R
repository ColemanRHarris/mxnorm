## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  message=FALSE,
  warning=FALSE
)

## ----setup, warning=FALSE,message=FALSE---------------------------------------
library(mxnorm)
library(dplyr)
library(reticulate)

## -----------------------------------------------------------------------------
if(reticulate::py_module_available("skimage")){
  knitr::knit_engines$set(python = reticulate::eng_python)
  skimage_available = TRUE
} else{
  ## set boolean for CRAN builds
  skimage_available = FALSE
  
  ## install if running locally
  #py_install("scikit-image")
}

## -----------------------------------------------------------------------------
head(mx_sample, 3)

## ----example------------------------------------------------------------------
mx_data = mx_dataset(data=mx_sample,
                        slide_id="slide_id",
                        image_id="image_id",
                        marker_cols=c("marker1_vals","marker2_vals","marker3_vals"),
                        metadata_cols=c("metadata1_vals"))

## ----norm---------------------------------------------------------------------
mx_data = mx_normalize(mx_data = mx_data,
                       transform = "mean_divide",
                       method="None",
                       method_override=NULL,
                       method_override_name=NULL)

## ----norm_data----------------------------------------------------------------
head(mx_data$norm_data,3)

## ----otsu---------------------------------------------------------------------
if(skimage_available){
  thold_override = NULL
} else{
  thold_override = function(thold_data){quantile(thold_data, 0.5)}
}

mx_data = run_otsu_discordance(mx_data,
                        table="both",
                        threshold_override = thold_override,
                        plot_out = FALSE)

## ----otsu_data----------------------------------------------------------------
head(mx_data$otsu_data, 3)

## ----mx_dens------------------------------------------------------------------
plot_mx_density(mx_data)

## ----mx_misc------------------------------------------------------------------
plot_mx_discordance(mx_data)

## ----umap---------------------------------------------------------------------
set.seed(1234)
mx_data = run_reduce_umap(mx_data,
                        table="both",
                        marker_list = c("marker1_vals","marker2_vals","marker3_vals"),
                        downsample_pct = 0.5,
                        metadata_cols = c("metadata1_vals"))

## ----umap_data----------------------------------------------------------------
head(mx_data$umap_data, 3)

## ----mx_umap------------------------------------------------------------------
plot_mx_umap(mx_data,
             metadata_col = "metadata1_vals")

## ----mx_umap_slide------------------------------------------------------------
plot_mx_umap(mx_data,
             metadata_col = "slide_id")

## ----var,warning=FALSE,message=FALSE------------------------------------------
mx_data = run_var_proportions(mx_data,
                             table="both",
                             metadata_cols = NULL,
                             formula_override = NULL,
                             save_models = FALSE
                             )

## ----var_data-----------------------------------------------------------------
head(mx_data$var_data, 4)

## ----mx_var-------------------------------------------------------------------
plot_mx_proportions(mx_data)

## ----ex_str-------------------------------------------------------------------
summary(mx_data)

## ----out.width="100%",fig.cap="Basic structure of the `mxnorm` package and associated functions",echo=FALSE----
knitr::include_graphics("mxnorm_structure.png")

## ----flex_example-------------------------------------------------------------
mx_flex = mx_dataset(data=mx_sample,
                        slide_id="slide_id",
                        image_id="image_id",
                        marker_cols=c("marker1_vals","marker2_vals","marker3_vals"),
                        metadata_cols=c("metadata1_vals"))

## ----udf----------------------------------------------------------------------
quantile_divide <- function(mx_data, ptile=0.5){
    ## data to normalize
    ndat = mx_data$data
    
    ## marker columns
    cols = mx_data$marker_cols
    
    ## slide id
    slide = mx_data$slide_id
    
    ## get column length slide medians
    y = ndat %>%
        dplyr::group_by(.data[[slide]]) %>%
        dplyr::mutate(dplyr::across(all_of(cols),quantile,ptile))
    
    ## divide to normalize
    ndat[,cols] = ndat[,cols]/y[,cols]
    
    ## rescale
    ndat = ndat %>%
        dplyr::mutate(dplyr::across(all_of(cols),function(a){a + -min(a)}))

    ## set normalized data
    mx_data$norm_data = ndat

    ## return object
    mx_data
}

## ----q_div--------------------------------------------------------------------
mx_flex_q50 = mx_normalize(mx_flex,
                           method_override = quantile_divide, 
                           method_override_name = "median_divide")

mx_flex_q75 = mx_normalize(mx_flex,
                           method_override = quantile_divide,
                           ptile=0.75, 
                           method_override_name = "75th_percentile")

## ----q_div_res----------------------------------------------------------------
summary(mx_flex_q50)
summary(mx_flex_q75)

## ----q50_iso------------------------------------------------------------------
if(skimage_available){
  thold_override = "isodata"
} else{
  thold_override = function(thold_data){quantile(thold_data, 0.5)}
}

mx_flex_q50 = run_otsu_discordance(mx_flex_q50,table = "both",threshold_override = thold_override)
summary(mx_flex_q50)

## ----q50_iso_plots------------------------------------------------------------
plot_mx_density(mx_flex_q50)
plot_mx_discordance(mx_flex_q50)

## ----q10_thold----------------------------------------------------------------
q10_threshold = function(thold_data,ptile=0.10){
    quantile(thold_data, ptile)
}

## ----q75_q10------------------------------------------------------------------
mx_flex_q75 = run_otsu_discordance(mx_flex_q75,table = "both",threshold_override = q10_threshold)
summary(mx_flex_q75)

## ----q75_q10__plots-----------------------------------------------------------
plot_mx_density(mx_flex_q75)
plot_mx_discordance(mx_flex_q75)

## ----mx_sample_cols-----------------------------------------------------------
head(mx_sample,0)

## ----reff_mod-----------------------------------------------------------------
new_RHS = "metadata1_vals + (1 | image_id) + (1 | slide_id)"

## ----var_prop_flex------------------------------------------------------------
mx_flex_q50 = run_var_proportions(mx_flex_q50,
                                  table="both",
                                  formula_override = new_RHS,
                                  save_models=TRUE)

## ----m1_vals------------------------------------------------------------------
summary(mx_flex_q50$var_models[[1]])

## ----q50_varprops_summ--------------------------------------------------------
summary(mx_flex_q50)
plot_mx_proportions(mx_flex_q50)

