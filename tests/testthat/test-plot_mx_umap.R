test_that("plotting works", {
    mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
      c("marker1_vals","marker2_vals","marker3_vals"),
      c("metadata1_vals"))
    mx_data = mx_normalize(mx_data, scale="log10",method="None")

    ## no umap
    expect_error(plot_mx_umap(mx_data))

    ## not obj
    expect_error(plot_mx_umap(rnorm(100)))

    mx_data = run_reduce_umap(mx_data, table="normalized",
                              c("marker1_vals","marker2_vals","marker3_vals"))

    expect_equal(class(plot_mx_umap(mx_data)),c("gg","ggplot"))
})
