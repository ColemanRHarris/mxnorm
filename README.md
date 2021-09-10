
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mxnorm

<!-- badges: start -->

<!-- badges: end -->

A package designed to handle multiplexed imaging data in R, implementing
normalization methods and quality metrics detailed in our paper
[here](https://doi.org/10.1101/2021.07.16.452359).

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ColemanRHarris/mxnorm")
```

## Example

This is a basic example using the `mx_sample` dataset, which is
simulated data to demonstrate the package’s functionality.

``` r
library(mxnorm)
head(mx_sample)
#>   slide_id image_id marker1_vals marker2_vals marker3_vals metadata1_vals
#> 1   slide1   image1           91          274         2465            yes
#> 2   slide1   image1           94          944         5303            yes
#> 3   slide1   image1           29          446         2140            yes
#> 4   slide1   image1           83          542          258            yes
#> 5   slide1   image1           64          162         3420            yes
#> 6   slide1   image1           52          693         3941            yes
```

How to build the `mx_dataset` object with `mx_sample` data in the
`mxnorm` package:

``` r
mx_dataset = mx_dataset(data=mx_sample,
                        slide_id="slide_id",
                        image_id="image_id",
                        marker_cols=c("marker1_vals","marker2_vals","marker3_vals"),
                        metadata_cols=c("metadata1_vals"))
```

The structure of the now built `mx_dataset` object:

``` r
str(mx_dataset)
#> List of 5
#>  $ data         :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 91 94 29 83 64 52 74 13 66 71 ...
#>   ..$ marker2_vals  : num [1:3000] 274 944 446 542 162 693 797 774 213 204 ...
#>   ..$ marker3_vals  : num [1:3000] 2465 5303 2140 258 3420 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "yes" "yes" "yes" ...
#>  $ slide_id     : chr "slide_id"
#>  $ image_id     : chr "image_id"
#>  $ marker_cols  : chr [1:3] "marker1_vals" "marker2_vals" "marker3_vals"
#>  $ metadata_cols: chr "metadata1_vals"
#>  - attr(*, "class")= chr "mx_dataset"
```
