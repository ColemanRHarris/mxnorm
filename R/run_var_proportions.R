#' Run random effects modeling on `mx_dataset` object to determine proportions of variance at the slide level
#'
#' @param mx_data `mx_dataset` object used to compute UMAP dimensions
#' @param table dataset in `mx_data` used to compute metrics. Options include: c("raw","normalized","both"), e.g. a y-axis parameter.
#' @param metadata_cols other identifiers of the input `data` to use in the modeling process (default=NULL). This must be a vector of column name(s) in the `mx_dataset` object
#' @param formula_override String with user-defined formula to use for variance proportions modeling analysis (default=NULL). This will be the RHS of a formula with `marker~` as the LHS.
#' @param save_models Boolean flag to save `lme4::lmer()` models in a list to the `mx_dataset` object
#' @param ... optional additional arguments for `lme4::lmer()` modeling
#'
#' @return `mx_dataset` object with modeling results in `var_data` table
#' @export
#'
#' @examples
#' mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
#'   c("marker1_vals","marker2_vals","marker3_vals"),
#'   c("metadata1_vals"))
#' mx_data = mx_normalize(mx_data, scale="log10",method="None")
#' mx_data = run_var_proportions(mx_data, table="both")
run_var_proportions <- function(mx_data,
                                table,
                                metadata_cols=NULL,
                                formula_override=NULL,
                                save_models=FALSE,
                                ...){
    ## validate params
    mx_data = validate_var_proportions_params(mx_data,
                                              table,
                                              metadata_cols,
                                              formula_override,
                                              save_models)

    if(save_models) mod_list = list();idx=1

    ## get proportions for all marker
    if(table == "both"){
        ## run for raw
        lraw = list(); ridx = 1
        for(marker in mx_data$marker_cols){
            mod = get_var_proportions(mx_data,
                                      metadata_cols,
                                      table="raw",
                                      m=marker,
                                      formula_override)

            if(save_models) mod_list[[idx]] = mod

            lraw[[ridx]] = get_var_data(mx_data,
                                        mod,
                                        table="raw",
                                        m=marker)
            idx = idx+1; ridx = ridx + 1
        }
        lraw = data.table::rbindlist(lraw)

        ## run for normalized
        lnorm = list(); nidx = 1
        for(marker in mx_data$marker_cols){
            mod = get_var_proportions(mx_data,
                                      metadata_cols,
                                      table="normalized",
                                      m=marker,
                                      formula_override)

            if(save_models) mod_list[[idx]] = mod

            lnorm[[nidx]] = get_var_data(mx_data,
                                         mod,
                                         table="normalized",
                                         m=marker)
            idx = idx+1; nidx = nidx + 1

        }
        lnorm = data.table::rbindlist(lnorm)

        var_data = rbind(lraw,lnorm)
    } else{
        l = list(); lidx = 1
        for(marker in mx_data$marker_cols){
            mod = get_var_proportions(mx_data,
                                      metadata_cols,
                                      table=table,
                                      m=marker,
                                      formula_override)

            if(save_models) mod_list[[idx]] = mod

            l[[lidx]] = get_var_data(mx_data,
                                     mod,
                                     table=table,
                                     m=marker)
            idx = idx+1; lidx = lidx+1
        }
        var_data = data.table::rbindlist(l)
    }

    ## add list of model(s) as attr
    if(save_models) mx_data$var_models = mod_list

    ## add data to object
    mx_data$var_data = var_data

    mx_data
}
