test_that("props works", {
    mx_obj = mx_dataset(data=mxnorm::mx_sample,
                        slide_id="slide_id",
                        image_id="image_id",
                        marker_cols=c("marker1_vals","marker2_vals","marker3_vals"),
                        metadata_cols=c("metadata1_vals"))
    ## validate parameters
    mx_obj = mx_normalize(mx_data=mx_obj,
                          transform="log10",
                          method="ComBat")

    ## confirm all work usually
    v1 = run_var_proportions(mx_obj,table="raw")
    v2 = run_var_proportions(mx_obj,table="both")
    v3 = run_var_proportions(mx_obj,table="both",save_models = TRUE)

    expect_equal(is.null(v1$var_data),FALSE)
    expect_equal(dim(v2$var_data)[1],12)
    expect_equal(unique(v2$var_data$table),c("raw","normalized"))
    expect_equal(is.null(v3$var_models),FALSE)

    ## test exists in list
    expect_error(run_var_proportions(mx_obj,table="none"))

    ## metadata cols
    mx_obj1 = mx_obj
    mx_obj1$data = mx_obj$data[,-6]
    expect_error(run_var_proportions(mx_obj1,table="both",metadata_cols="metadata1_vals"))

    ## formula overrides work
    v4 = run_var_proportions(mx_obj,table="raw",formula_override = "(1|slide_id)")
    v5 = run_var_proportions(mx_obj,table="raw",formula_override = "(1|slide_id)+metadata1_vals",metadata_cols = "metadata1_vals")
    expect_equal(is.null(v4$var_data),FALSE)
    expect_equal(is.null(v5$var_data),FALSE)

    expect_error(run_var_proportions(mx_obj,table="raw",formula_override = "none"))
    expect_error(run_var_proportions(mx_obj,table="raw",formula_override = rnorm(100)))
})
