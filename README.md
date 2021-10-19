
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
simulated data to demonstrate the package’s functionality with slide
effects.

``` r
library(mxnorm)
head(mx_sample)
#>   slide_id image_id marker1_vals marker2_vals marker3_vals metadata1_vals
#> 1   slide1   image1           91          171         7766            yes
#> 2   slide1   image1           94          560          267            yes
#> 3   slide1   image1           29          572          597            yes
#> 4   slide1   image1           83          922         8551            yes
#> 5   slide1   image1           64          575         9454            yes
#> 6   slide1   image1           52          971         9870            yes
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
#>   ..$ marker2_vals  : num [1:3000] 171 560 572 922 575 971 471 788 499 32 ...
#>   ..$ marker3_vals  : num [1:3000] 7766 267 597 8551 9454 ...
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
#> 1   slide1   image1     1.963788     2.235528     3.890253            yes
#> 2   slide1   image1     1.977724     2.748963     2.428135            yes
#> 3   slide1   image1     1.477121     2.758155     2.776701            yes
#> 4   slide1   image1     1.924279     2.965202     3.932068            yes
#> 5   slide1   image1     1.812913     2.760422     3.975662            yes
#> 6   slide1   image1     1.724276     2.987666     3.994361            yes
```

And the `mx_dataset` object now includes the following attributes:

``` r
str(mx_norm)
#> List of 8
#>  $ data         :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 91 94 29 83 64 52 74 13 66 71 ...
#>   ..$ marker2_vals  : num [1:3000] 171 560 572 922 575 971 471 788 499 32 ...
#>   ..$ marker3_vals  : num [1:3000] 7766 267 597 8551 9454 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "yes" "yes" "yes" ...
#>  $ slide_id     : chr "slide_id"
#>  $ image_id     : chr "image_id"
#>  $ marker_cols  : chr [1:3] "marker1_vals" "marker2_vals" "marker3_vals"
#>  $ metadata_cols: chr "metadata1_vals"
#>  $ norm_data    :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 1.96 1.98 1.48 1.92 1.81 ...
#>   ..$ marker2_vals  : num [1:3000] 2.24 2.75 2.76 2.97 2.76 ...
#>   ..$ marker3_vals  : num [1:3000] 3.89 2.43 2.78 3.93 3.98 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "yes" "yes" "yes" ...
#>  $ scale        : chr "log10"
#>  $ method       : chr "None"
#>  - attr(*, "class")= chr "mx_dataset"
```

## Otsu misclassification metrics with `run_otsu_misclass()`

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
#> 1   slide1 marker1_vals   raw    5.019531e+01         288.5742      0.4773333
#> 2   slide2 marker1_vals   raw    5.859375e-03         288.5742      0.6280000
#> 3   slide3 marker1_vals   raw    8.702734e+01         288.5742      0.7440000
#> 4   slide4 marker1_vals   raw    3.740371e+02         288.5742      0.1146667
#> 5   slide1 marker2_vals   raw    4.829395e+02         341.7969      0.1266667
#> 6   slide2 marker2_vals   raw    4.003906e+00         341.7969      0.6773333
```

And the `mx_dataset` object now includes the following attributes:

``` r
str(mx_otsu)
#> List of 11
#>  $ data         :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 91 94 29 83 64 52 74 13 66 71 ...
#>   ..$ marker2_vals  : num [1:3000] 171 560 572 922 575 971 471 788 499 32 ...
#>   ..$ marker3_vals  : num [1:3000] 7766 267 597 8551 9454 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "yes" "yes" "yes" ...
#>  $ slide_id     : chr "slide_id"
#>  $ image_id     : chr "image_id"
#>  $ marker_cols  : chr [1:3] "marker1_vals" "marker2_vals" "marker3_vals"
#>  $ metadata_cols: chr "metadata1_vals"
#>  $ norm_data    :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 1.96 1.98 1.48 1.92 1.81 ...
#>   ..$ marker2_vals  : num [1:3000] 2.24 2.75 2.76 2.97 2.76 ...
#>   ..$ marker3_vals  : num [1:3000] 3.89 2.43 2.78 3.93 3.98 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "yes" "yes" "yes" ...
#>  $ scale        : chr "log10"
#>  $ method       : chr "None"
#>  $ otsu_data    :'data.frame':   24 obs. of  6 variables:
#>   ..$ slide_id        : chr [1:24] "slide1" "slide2" "slide3" "slide4" ...
#>   ..$ marker          : chr [1:24] "marker1_vals" "marker1_vals" "marker1_vals" "marker1_vals" ...
#>   ..$ table           : chr [1:24] "raw" "raw" "raw" "raw" ...
#>   ..$ slide_threshold : num [1:24] 5.02e+01 5.86e-03 8.70e+01 3.74e+02 4.83e+02 ...
#>   ..$ marker_threshold: num [1:24] 289 289 289 289 342 ...
#>   ..$ misclass_error  : num [1:24] 0.477 0.628 0.744 0.115 0.127 ...
#>  $ otsu_table   : chr "both"
#>  $ threshold    : chr "otsu"
#>  - attr(*, "class")= chr "mx_dataset"
```

## UMAP dimension reduction with `run_reduce_umap()`

We can also use the UMAP algorithm to reduce the dimensions of our
markers in the dataset as follows, using the `metadata_col` parameter
for later (e.g., similar to a tissue type in practice with multiplexed
data):

``` r
mx_umap = run_reduce_umap(mx_otsu,
                        table="both",
                        marker_list = c("marker1_vals","marker2_vals","marker3_vals"),
                        downsample_pct = 0.8,
                        metadata_col = "metadata1_vals")
```

This adds UMAP dimensions to our `mx_dataset` object in the following
form:

``` r
head(mx_umap$umap_data)
#>      marker1_vals marker2_vals marker3_vals metadata1_vals table          U1
#> 1717           98           68           74             no   raw  -5.8276359
#> 2279           29           29           29             no   raw  -0.6148791
#> 335            68          146         7149            yes   raw   7.3799556
#> 1055            0            6            6            yes   raw -16.3709385
#> 251            33          905         9365            yes   raw   8.8375052
#> 1088            0            4            4            yes   raw  -3.3954894
#>              U2
#> 1717  -2.776944
#> 2279   4.420231
#> 335  -17.569706
#> 1055   5.339620
#> 251  -22.088848
#> 1088  17.994051
```

And the `mx_dataset` object now includes the following attributes:

``` r
str(mx_umap)
#> List of 13
#>  $ data         :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 91 94 29 83 64 52 74 13 66 71 ...
#>   ..$ marker2_vals  : num [1:3000] 171 560 572 922 575 971 471 788 499 32 ...
#>   ..$ marker3_vals  : num [1:3000] 7766 267 597 8551 9454 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "yes" "yes" "yes" ...
#>  $ slide_id     : chr "slide_id"
#>  $ image_id     : chr "image_id"
#>  $ marker_cols  : chr [1:3] "marker1_vals" "marker2_vals" "marker3_vals"
#>  $ metadata_cols: chr "metadata1_vals"
#>  $ norm_data    :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 1.96 1.98 1.48 1.92 1.81 ...
#>   ..$ marker2_vals  : num [1:3000] 2.24 2.75 2.76 2.97 2.76 ...
#>   ..$ marker3_vals  : num [1:3000] 3.89 2.43 2.78 3.93 3.98 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "yes" "yes" "yes" ...
#>  $ scale        : chr "log10"
#>  $ method       : chr "None"
#>  $ otsu_data    :'data.frame':   24 obs. of  6 variables:
#>   ..$ slide_id        : chr [1:24] "slide1" "slide2" "slide3" "slide4" ...
#>   ..$ marker          : chr [1:24] "marker1_vals" "marker1_vals" "marker1_vals" "marker1_vals" ...
#>   ..$ table           : chr [1:24] "raw" "raw" "raw" "raw" ...
#>   ..$ slide_threshold : num [1:24] 5.02e+01 5.86e-03 8.70e+01 3.74e+02 4.83e+02 ...
#>   ..$ marker_threshold: num [1:24] 289 289 289 289 342 ...
#>   ..$ misclass_error  : num [1:24] 0.477 0.628 0.744 0.115 0.127 ...
#>  $ otsu_table   : chr "both"
#>  $ threshold    : chr "otsu"
#>  $ umap_data    :'data.frame':   4800 obs. of  7 variables:
#>   ..$ marker1_vals  : num [1:4800] 98 29 68 0 33 0 300 8 70 96 ...
#>   ..$ marker2_vals  : num [1:4800] 68 29 146 6 905 4 300 644 160 46 ...
#>   ..$ marker3_vals  : num [1:4800] 74 29 7149 6 9365 ...
#>   ..$ metadata1_vals: chr [1:4800] "no" "no" "yes" "yes" ...
#>   ..$ table         : chr [1:4800] "raw" "raw" "raw" "raw" ...
#>   ..$ U1            : num [1:4800] -5.828 -0.615 7.38 -16.371 8.838 ...
#>   ..$ U2            : num [1:4800] -2.78 4.42 -17.57 5.34 -22.09 ...
#>  $ umap_table   : chr "both"
#>  - attr(*, "class")= chr "mx_dataset"
```

## Variance components analysis with `run_var_proportions()`

We can also leverage `lmer()` from the `lme4` package to perform random
effect modeling on the data to determine how much variance is present at
the slide level, as follows:

``` r
mx_var = run_var_proportions(mx_umap,
                             table="both",
                             metadata_cols = "metadata1_vals")
```

This adds UMAP dimensions to our `mx_dataset` object in the following
form:

``` r
head(mx_var$var_data)
#>    proportions    level       marker table
#> 1:   0.6349562    slide marker1_vals   raw
#> 2:   0.3650438 residual marker1_vals   raw
#> 3:   0.7357441    slide marker2_vals   raw
#> 4:   0.2642559 residual marker2_vals   raw
#> 5:   0.7338357    slide marker3_vals   raw
#> 6:   0.2661643 residual marker3_vals   raw
```

And the `mx_dataset` object now includes the following attributes:

``` r
str(mx_var)
#> List of 14
#>  $ data         :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 91 94 29 83 64 52 74 13 66 71 ...
#>   ..$ marker2_vals  : num [1:3000] 171 560 572 922 575 971 471 788 499 32 ...
#>   ..$ marker3_vals  : num [1:3000] 7766 267 597 8551 9454 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "yes" "yes" "yes" ...
#>  $ slide_id     : chr "slide_id"
#>  $ image_id     : chr "image_id"
#>  $ marker_cols  : chr [1:3] "marker1_vals" "marker2_vals" "marker3_vals"
#>  $ metadata_cols: chr "metadata1_vals"
#>  $ norm_data    :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 1.96 1.98 1.48 1.92 1.81 ...
#>   ..$ marker2_vals  : num [1:3000] 2.24 2.75 2.76 2.97 2.76 ...
#>   ..$ marker3_vals  : num [1:3000] 3.89 2.43 2.78 3.93 3.98 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "yes" "yes" "yes" ...
#>  $ scale        : chr "log10"
#>  $ method       : chr "None"
#>  $ otsu_data    :'data.frame':   24 obs. of  6 variables:
#>   ..$ slide_id        : chr [1:24] "slide1" "slide2" "slide3" "slide4" ...
#>   ..$ marker          : chr [1:24] "marker1_vals" "marker1_vals" "marker1_vals" "marker1_vals" ...
#>   ..$ table           : chr [1:24] "raw" "raw" "raw" "raw" ...
#>   ..$ slide_threshold : num [1:24] 5.02e+01 5.86e-03 8.70e+01 3.74e+02 4.83e+02 ...
#>   ..$ marker_threshold: num [1:24] 289 289 289 289 342 ...
#>   ..$ misclass_error  : num [1:24] 0.477 0.628 0.744 0.115 0.127 ...
#>  $ otsu_table   : chr "both"
#>  $ threshold    : chr "otsu"
#>  $ umap_data    :'data.frame':   4800 obs. of  7 variables:
#>   ..$ marker1_vals  : num [1:4800] 98 29 68 0 33 0 300 8 70 96 ...
#>   ..$ marker2_vals  : num [1:4800] 68 29 146 6 905 4 300 644 160 46 ...
#>   ..$ marker3_vals  : num [1:4800] 74 29 7149 6 9365 ...
#>   ..$ metadata1_vals: chr [1:4800] "no" "no" "yes" "yes" ...
#>   ..$ table         : chr [1:4800] "raw" "raw" "raw" "raw" ...
#>   ..$ U1            : num [1:4800] -5.828 -0.615 7.38 -16.371 8.838 ...
#>   ..$ U2            : num [1:4800] -2.78 4.42 -17.57 5.34 -22.09 ...
#>  $ umap_table   : chr "both"
#>  $ var_data     :Classes 'data.table' and 'data.frame':  12 obs. of  4 variables:
#>   ..$ proportions: num [1:12] 0.635 0.365 0.736 0.264 0.734 ...
#>   ..$ level      : chr [1:12] "slide" "residual" "slide" "residual" ...
#>   ..$ marker     : chr [1:12] "marker1_vals" "marker1_vals" "marker2_vals" "marker2_vals" ...
#>   ..$ table      : chr [1:12] "raw" "raw" "raw" "raw" ...
#>   ..- attr(*, ".internal.selfref")=<externalptr> 
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

<img src="man/figures/README-mx_misc-1.png" width="100%" />

We can further visualize the results of the UMAP dimension reduction as
follows:

``` r
plot_mx_umap(mx_umap,metadata_col = "metadata1_vals")
```

<img src="man/figures/README-mx_umap-1.png" width="100%" />

And we can also visualize the results of the variance proportions (note
that this is sample data, hence the proportions of variance at the slide
level are \(\approx 0\)):

``` r
plot_mx_proportions(mx_var)
```

<img src="man/figures/README-mx_var-1.png" width="100%" />
