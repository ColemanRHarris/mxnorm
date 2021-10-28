#' Internal function to setup variance proportions table
#'
#' @inheritParams run_var_proportions
#' @param mod `lme4::lmer()` model run using `get_var_proportions()`
#' @param m marker used in `lme4` random effects model
#'
#' @import lme4
#'
#' @return `data.frame`
get_var_data <- function(mx_data,
                         table,
                         mod,
                         m){
    ## summarise
    smod = summary(mod)

    ## calc props
    proportions = unname(c(unlist(smod$varcor)[mx_data$slide_id], (smod$sigma)^2))
    proportions = proportions/sum(proportions)

    ## setup data
    df = data.frame(proportions)
    df$level = c("slide","residual")
    df$marker = m
    df$table = table

    df
}
