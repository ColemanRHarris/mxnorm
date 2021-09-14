test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

# --- validate params works
## scale param wrong
## method param wrong
## mx_data not mx_dataset
## method_override not NULL and method is not "None"
## method_override not NULL and method_override not a function

# --- scale works
## norm_data is in mx_dataset obj
## if scale is "None", norm_data = data
## min of norm_data is >= 0
## scale == mx_dataset scale attr
