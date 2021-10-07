#' Internal function to run variance proportions random effects modeling
#'
#' @inheritParams run_var_proportions
#' @param m marker to run `lme4` random effects model
#' @param ... additional parameters to set for `lme4::lmer()` model.
#'
#' @return `lme4` model
get_var_proportions <- function(mx_data,
                                metadata_cols,
                                table,
                                m,
                                formula_override,
                                ...){
    ## set table
    if(table == "normalized"){
        dat = mx_data$norm_data
    } else {
        dat = mx_data$data
    }

    ## set formula
    f = paste0(m,"~","(1|",mx_data$slide_id,")")

    if(!is.null(formula_override)){
        f = paste0(m,"~",formula_override)
    } else if(!is.null(metadata_cols)){
        f = stats::formula(paste(f,paste(metadata_cols,collapse="+"),sep="+"))
    } else{
        f = stats::as.formula(f)
    }

    ## run model
    mod = lme4::lmer(f, data = dat,...)

    mod
}
