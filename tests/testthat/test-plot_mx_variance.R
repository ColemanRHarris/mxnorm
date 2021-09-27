test_that("plotting ok", {
    mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
      c("marker1_vals","marker2_vals","marker3_vals"),
      c("metadata1_vals"))
    mx_data = mx_normalize(mx_data, scale="log10",method="None")

    ## no otsu data
    expect_error(plot_mx_variance(mx_data))

    ## not mx_dataset
    expect_error(plot_mx_variance(rnorm(100)))

    mx_data = otsu_misclass(mx_data, table="normalized")
    mx_data$otsu_data$misclass_error[10] = NA
    expect_error(plot_mx_variance(mx_data))
})
