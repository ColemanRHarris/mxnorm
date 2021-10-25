test_that("validate params works",{
    mx_obj = mx_dataset(data=mxnorm::mx_sample,
                        slide_id="slide_id",
                        image_id="image_id",
                        marker_cols=c("marker1_vals","marker2_vals","marker3_vals"),
                        metadata_cols=c("metadata1_vals"))
    ## validate parameters
    mx_obj = mx_normalize(mx_data=mx_obj,
                          transform="log10",
                          method="ComBat")

    ## confirm both works
    u1 = run_reduce_umap(mx_obj,table="raw",marker_list = c("marker1_vals","marker2_vals","marker3_vals"))
    u2 = run_reduce_umap(mx_obj,table="both",marker_list = c("marker1_vals","marker2_vals","marker3_vals"))

    expect_equal(is.null(u1$umap_data),FALSE)
    expect_equal(dim(u2$umap_data)[1],6000)

    ## table exists in list
    expect_error(validate_reduce_umap_params(mx_obj,table="test",marker_list = c("marker1_vals","marker2_vals","marker3_vals"),1,NULL))

    ## marker cols
    mx_obj1 = mx_obj
    mx_obj1$data = mx_obj1$data[,-3]
    expect_error(validate_reduce_umap_params(mx_obj1,table="raw",marker_list = c("marker1_vals","marker2_vals","marker3_vals"),downsample_pct = 1,metadata_cols = NULL))
    expect_error(validate_reduce_umap_params(mx_obj1,table="both",marker_list = c("marker1_vals","marker2_vals","marker3_vals"),downsample_pct = 1,metadata_cols = NULL))

    ## meta cols in raw
    mx_obj1 = mx_obj
    mx_obj1$data = mx_obj$data[,-6]
    expect_error(validate_reduce_umap_params(mx_obj1,table="raw",marker_list = c("marker1_vals","marker2_vals","marker3_vals"),downsample_pct = 1,metadata_cols = "metadata1_vals"))
    expect_error(validate_reduce_umap_params(mx_obj1,table="both",marker_list = c("marker1_vals","marker2_vals","marker3_vals"),downsample_pct = 1,metadata_cols = "metadata1_vals"))

    ## downsample pct
    expect_error(validate_reduce_umap_params(mx_obj,table="both",marker_list = c("marker1_vals","marker2_vals","marker3_vals"),downsample_pct = 100,metadata_cols = "metadata1_vals"))

    ## catches Inf
    mx_obj$norm_data[1,5] = Inf
    expect_error(validate_reduce_umap_params(mx_obj,table="raw",marker_list = c("marker1_vals","marker2_vals","marker3_vals"),1,NULL))

    ## catches incorrect dims
    mx_obj$norm_data <- data.frame(matrix(rnorm(9),3,3))
    expect_error(validate_reduce_umap_params(mx_obj,table="raw",marker_list = c("marker1_vals","marker2_vals","marker3_vals"),1,NULL))

    ## normalized data exists when "normalized" or "both
    expect_error(validate_reduce_umap_params(mx_obj[-6],table="normalized",marker_list = c("marker1_vals","marker2_vals","marker3_vals"),1,NULL))
    expect_error(validate_reduce_umap_params(mx_obj[-6],table="both",marker_list = c("marker1_vals","marker2_vals","marker3_vals"),1,NULL))
})
