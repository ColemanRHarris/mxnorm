test_that("trim works", {
    x = trim_dataset(mx_sample,"slide_id","image_id",c("marker1_vals"),c("metadata1_vals"))
    y = trim_dataset(mx_sample,"slide_id","image_id",c("marker1_vals"),NULL)

    expect_equal(any(c("marker2_vals","marker_3_vals") %in% colnames(x)),FALSE)
    expect_equal(any(c("marker2_vals","marker_3_vals","metadata1_vals") %in% colnames(y)),FALSE)
})

test_that("trim error messages work", {
    expect_error(trim_dataset(mx_sample,"slide_id","image_id",c("marker5_vals"),c("metadata1_vals")))
    expect_error(trim_dataset(mx_sample,"slide_id","image_id",c("marker5_vals"),NULL))
})

test_that("object works", {
    x = mx_dataset(mx_sample, "slide_id", "image_id", c("marker1_vals","marker2_vals","marker3_vals"), c("metadata1_vals"))
    expect_equal(class(x),"mx_dataset")
    expect_equal(attributes(x)$names, c("data","slide_id","image_id","marker_cols","metadata_cols"))
})

test_that("object error messages works", {
    expect_error(new_mx_dataset(mx_sample, 1, "image_id", c("marker1_vals","marker2_vals","marker3_vals"), c("metadata1_vals")))
    expect_error(new_mx_dataset(mx_sample, "slide_id", 1, c("marker1_vals","marker2_vals","marker3_vals"), c("metadata1_vals")))
    expect_error(new_mx_dataset(matrix(mx_sample), "slide_id", "image_id", c("marker1_vals","marker2_vals","marker3_vals"), c("metadata1_vals")))
})

test_that("validate works", {
    x <- mx_sample
    y <- mx_sample

    x$marker1_vals[5] = Inf
    y$marker1_vals[6] = "7"

    expect_error(mx_dataset(x, "slide_id", "image_id", c("marker1_vals","marker2_vals","marker3_vals"), c("metadata1_vals")))
    expect_error(mx_dataset(y, "slide_id", "image_id", c("marker1_vals","marker2_vals","marker3_vals"), c("metadata1_vals")))
})

