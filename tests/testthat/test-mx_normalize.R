test_that("validate params works",{
    mx_obj = mx_dataset(data=mx_sample,
                           slide_id="slide_id",
                           image_id="image_id",
                           marker_cols=c("marker1_vals","marker2_vals","marker3_vals"),
                           metadata_cols=c("metadata1_vals"))

    ## transform param wrong
    expect_error(validate_mx_normalize_params(mx_obj,"test","None",NULL))

    ## method param wrong
    expect_error(validate_mx_normalize_params(mx_obj,"None","test",NULL))

    ## mx_data not mx_dataset object
    expect_error(validate_mx_normalize_params(rnorm(1),"None","None",NULL))

    ## method_override not NULL and method is not "None"
    expect_error(validate_mx_normalize_params(mx_obj,"None","ComBat",function(x){x}))

    ## method_override not NULL and method_override not a function
    expect_error(validate_mx_normalize_params(mx_obj,"None","None",c("test")))

    ## check that object gets created correctly
    expect_true(all(names(validate_mx_normalize_params(mx_obj,"None","None",NULL)) == names(mx_obj)))
})

test_that("transform works",{
    mx_obj = mx_dataset(data=mx_sample,
                           slide_id="slide_id",
                           image_id="image_id",
                           marker_cols=c("marker1_vals","marker2_vals","marker3_vals"),
                           metadata_cols=c("metadata1_vals"))
    mx_obj = validate_mx_normalize_params(mx_obj,"None","None",NULL)

    mx_obj1 = transform_mx_dataset(mx_obj,"None")
    mx_obj2 = transform_mx_dataset(mx_obj,"log10")
    mx_obj3 = transform_mx_dataset(mx_obj,"mean_divide")
    mx_obj4 = transform_mx_dataset(mx_obj,"log10_mean_divide")


    ## norm_data is in mx_dataset obj
    expect_false(is.null(mx_obj1$norm_data))

    ## if transform is "None", norm_data = data
    expect_true(all(mx_obj1$norm_data == mx_obj1$data))

    ## min of norm_data is >= 0
    expect_true(min(mx_obj1$norm_data[,mx_obj1$marker_cols]) >= 0)
    expect_true(min(mx_obj2$norm_data[,mx_obj2$marker_cols]) >= 0)
    expect_true(min(mx_obj3$norm_data[,mx_obj3$marker_cols]) >= 0)
    expect_true(min(mx_obj4$norm_data[,mx_obj4$marker_cols]) >= 0)

    ## transform == mx_dataset transform attr
    expect_equal(mx_obj1$transform,"None")
    expect_equal(mx_obj2$transform,"log10")
    expect_equal(mx_obj3$transform,"mean_divide")
    expect_equal(mx_obj4$transform,"log10_mean_divide")
})


test_that("method override works",{
    mx_obj = mx_dataset(data=mx_sample,
                        slide_id="slide_id",
                        image_id="image_id",
                        marker_cols=c("marker1_vals","marker2_vals","marker3_vals"),
                        metadata_cols=c("metadata1_vals"))
    mx_obj = validate_mx_normalize_params(mx_obj,"None","None",NULL)
    mx_obj = transform_mx_dataset(mx_obj,"None")

    ## basic method_override example passes
    expect_equal(validate_method_override(function(mx_data){mx_data}),TRUE)
    expect_equal(validate_method_override(function(mx_data,x){mx_data},x=1),TRUE)

    ## args not passed for method_override
    expect_error(validate_method_override(function(mx_data,x){mx_data}))
})

test_that("normalization works",{
    mx_obj = mx_dataset(data=mx_sample,
                        slide_id="slide_id",
                        image_id="image_id",
                        marker_cols=c("marker1_vals","marker2_vals","marker3_vals"),
                        metadata_cols=c("metadata1_vals"))
    mx_obj = validate_mx_normalize_params(mx_obj,"None","None",NULL)
    mx_obj = transform_mx_dataset(mx_obj,"None")
    mx_obj = normalize_mx_dataset(mx_obj,"None")

    ## catches missing transform
    expect_error(validate_mx_dataset(mx_obj[-7]))

    ## catches missing method
    expect_error(validate_mx_dataset(mx_obj[-8]))

    ## catches Inf
    mx_obj$norm_data[1,5] = Inf
    expect_error(validate_mx_dataset(mx_obj))

    ## catches non-numerics
    mx_obj$norm_data[1,5] = "Inf"
    expect_error(validate_mx_dataset(mx_obj))

    ## catches NAs
    mx_obj$norm_data[1,5] = NA
    expect_error(validate_mx_dataset(mx_obj))

    ## catches incorrect dims
    mx_obj$norm_data <- data.frame(matrix(rnorm(9),3,3))
    expect_error(validate_mx_dataset(mx_obj))
})

