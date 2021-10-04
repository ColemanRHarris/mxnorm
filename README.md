
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mxnorm: An R package to normalize multiplexed imaging data.

<!-- badges: start -->

<!-- badges: end -->

A package designed to handle multiplexed imaging data in R, implementing
normalization methods and quality metrics detailed in our paper
[here](https://doi.org/10.1101/2021.07.16.452359).

# Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ColemanRHarris/mxnorm")
```

# Analysis Example

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

## `mx_dataset` objects

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

## Normalization with `mx_normalize()`

And now we can normalize this data using the `mx_normalize()` function:

``` r
mx_norm = mx_normalize(mx_data = mx_dataset,
                       scale = "log10",
                       method="None")
```

The `mx_dataset` object has normalized data in the following form:

``` r
head(mx_norm$norm_data)
#>   slide_id image_id marker1_vals marker2_vals marker3_vals metadata1_vals
#> 1   slide1   image1     1.963788     2.439333     3.391993            yes
#> 2   slide1   image1     1.977724     2.975432     3.724604            yes
#> 3   slide1   image1     1.477121     2.650308     3.330617            yes
#> 4   slide1   image1     1.924279     2.734800     2.413300            yes
#> 5   slide1   image1     1.812913     2.212188     3.534153            yes
#> 6   slide1   image1     1.724276     2.841359     3.595717            yes
```

And the `mx_dataset` object now includes the following attributes:

``` r
str(mx_norm)
#> List of 8
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
#>  $ norm_data    :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 1.96 1.98 1.48 1.92 1.81 ...
#>   ..$ marker2_vals  : num [1:3000] 2.44 2.98 2.65 2.73 2.21 ...
#>   ..$ marker3_vals  : num [1:3000] 3.39 3.72 3.33 2.41 3.53 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "yes" "yes" "yes" ...
#>  $ scale        : chr "log10"
#>  $ method       : chr "None"
#>  - attr(*, "class")= chr "mx_dataset"
```

## Otsu misclassification metrics with `otsu_misclass()`

Using the above normalized data, we can run misclassification metrics to
determine how well our normalization method performs:

``` r
mx_otsu = run_otsu_misclass(mx_norm,
                        table="both",
                        threshold_override = NULL,
                        plot_out = FALSE)
```

This adds an Otsu misclassification table to the `mx_dataset` object in
the following form:

``` r
head(mx_otsu$otsu_data)
#>   slide_id       marker table slide_threshold marker_threshold misclass_error
#> 1   slide1 marker1_vals   raw        50.19531         49.02344    0.008000000
#> 2   slide2 marker1_vals   raw        47.85156         49.02344    0.013333333
#> 3   slide3 marker1_vals   raw        47.85156         49.02344    0.018666667
#> 4   slide4 marker1_vals   raw        50.97656         49.02344    0.008000000
#> 5   slide1 marker2_vals   raw       515.61719        498.04688    0.018666667
#> 6   slide2 marker2_vals   raw       493.64648        498.04688    0.001333333
```

And the `mx_dataset` object now includes the following attributes:

``` r
str(mx_otsu)
#> List of 10
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
#>  $ norm_data    :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 1.96 1.98 1.48 1.92 1.81 ...
#>   ..$ marker2_vals  : num [1:3000] 2.44 2.98 2.65 2.73 2.21 ...
#>   ..$ marker3_vals  : num [1:3000] 3.39 3.72 3.33 2.41 3.53 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "yes" "yes" "yes" ...
#>  $ scale        : chr "log10"
#>  $ method       : chr "None"
#>  $ otsu_data    :'data.frame':   24 obs. of  6 variables:
#>   ..$ slide_id        : chr [1:24] "slide1" "slide2" "slide3" "slide4" ...
#>   ..$ marker          : chr [1:24] "marker1_vals" "marker1_vals" "marker1_vals" "marker1_vals" ...
#>   ..$ table           : chr [1:24] "raw" "raw" "raw" "raw" ...
#>   ..$ slide_threshold : num [1:24] 50.2 47.9 47.9 51 515.6 ...
#>   ..$ marker_threshold: num [1:24] 49 49 49 49 498 ...
#>   ..$ misclass_error  : num [1:24] 0.008 0.0133 0.0187 0.008 0.0187 ...
#>  $ table        : chr "both"
#>  - attr(*, "class")= chr "mx_dataset"
```

# Visualizations

We can also begin to visualize these results using some of `mxnorm`’s
plotting features built using `ggplot2`.

First, we can visualize the densities of the marker values as follows:

``` r
plot_mx_density(mx_otsu)
```

<img src="man/figures/README-mx_dens-1.png" width="100%" />

We can also visualize the results of the Otsu misclassification analysis
stratified by slide and marker:

``` r
plot_mx_misclass(mx_otsu)
```

<img src="man/figures/README-mx_var-1.png" width="100%" />
