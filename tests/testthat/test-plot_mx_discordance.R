# helper function to skip tests if we don't have the 'foo' module
skip_if_no_skf <- function() {
  have_skf <- reticulate::py_module_available("skimage.filters")
  if (!have_skf)
    skip("skimage.filters not available for testing")
}


test_that("plotting ok", {
    mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
      c("marker1_vals","marker2_vals","marker3_vals"),
      c("metadata1_vals"))
    mx_data = mx_normalize(mx_data, transform="log10",method="None")

    ## no otsu data
    expect_error(plot_mx_discordance(mx_data))

    ## not mx_dataset
    expect_error(plot_mx_discordance(rnorm(100)))

    skip_if_no_skf()
    mx_data = run_otsu_discordance(mx_data, table="normalized")
    mx_data$otsu_data$discordance_score[10] = NA
    expect_error(plot_mx_discordance(mx_data))
})
