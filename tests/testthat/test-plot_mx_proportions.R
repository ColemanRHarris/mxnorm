test_that("plotting works", {
    mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
      c("marker1_vals","marker2_vals","marker3_vals"),
      c("metadata1_vals"))
    mx_data = mx_normalize(mx_data, scale="log10",method="None")

    ## expect error (no var prop)
    expect_error(plot_mx_proportions(mx_data))

    ## not obj
    expect_error(plot_mx_proportions(rnorm(100)))

    mx_data = run_var_proportions(mx_data, table="both")
    expect_equal(class(plot_mx_proportions(mx_data)),c("gg","ggplot"))
})
