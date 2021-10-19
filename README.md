
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
#> 1   slide1   image1           15           17           28            yes
#> 2   slide1   image1           11           22           31             no
#> 3   slide1   image1           12           16           22            yes
#> 4   slide1   image1           11           19           33            yes
#> 5   slide1   image1           12           21           24            yes
#> 6   slide1   image1           11           17           19            yes
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
#>   ..$ marker1_vals  : num [1:3000] 15 11 12 11 12 11 16 12 11 10 ...
#>   ..$ marker2_vals  : num [1:3000] 17 22 16 19 21 17 18 19 19 23 ...
#>   ..$ marker3_vals  : num [1:3000] 28 31 22 33 24 19 36 32 22 25 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "no" "yes" "yes" ...
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
#> 1   slide1   image1     1.204120     1.255273     1.462398            yes
#> 2   slide1   image1     1.079181     1.361728     1.505150             no
#> 3   slide1   image1     1.113943     1.230449     1.361728            yes
#> 4   slide1   image1     1.079181     1.301030     1.531479            yes
#> 5   slide1   image1     1.113943     1.342423     1.397940            yes
#> 6   slide1   image1     1.079181     1.255273     1.301030            yes
```

And the `mx_dataset` object now includes the following attributes:

``` r
str(mx_norm)
#> List of 8
#>  $ data         :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 15 11 12 11 12 11 16 12 11 10 ...
#>   ..$ marker2_vals  : num [1:3000] 17 22 16 19 21 17 18 19 19 23 ...
#>   ..$ marker3_vals  : num [1:3000] 28 31 22 33 24 19 36 32 22 25 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "no" "yes" "yes" ...
#>  $ slide_id     : chr "slide_id"
#>  $ image_id     : chr "image_id"
#>  $ marker_cols  : chr [1:3] "marker1_vals" "marker2_vals" "marker3_vals"
#>  $ metadata_cols: chr "metadata1_vals"
#>  $ norm_data    :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 1.2 1.08 1.11 1.08 1.11 ...
#>   ..$ marker2_vals  : num [1:3000] 1.26 1.36 1.23 1.3 1.34 ...
#>   ..$ marker3_vals  : num [1:3000] 1.46 1.51 1.36 1.53 1.4 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "no" "yes" "yes" ...
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
#> 1   slide1 marker1_vals   raw        12.01758         54.89844      0.4506667
#> 2   slide2 marker1_vals   raw        20.01367         54.89844      0.4306667
#> 3   slide3 marker1_vals   raw        87.05664         54.89844      0.2573333
#> 4   slide4 marker1_vals   raw        44.00391         54.89844      0.3386667
#> 5   slide1 marker2_vals   raw        19.00977         52.90039      0.5333333
#> 6   slide2 marker2_vals   raw        19.99219         52.90039      0.5320000
```

And the `mx_dataset` object now includes the following attributes:

``` r
str(mx_otsu)
#> List of 11
#>  $ data         :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 15 11 12 11 12 11 16 12 11 10 ...
#>   ..$ marker2_vals  : num [1:3000] 17 22 16 19 21 17 18 19 19 23 ...
#>   ..$ marker3_vals  : num [1:3000] 28 31 22 33 24 19 36 32 22 25 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "no" "yes" "yes" ...
#>  $ slide_id     : chr "slide_id"
#>  $ image_id     : chr "image_id"
#>  $ marker_cols  : chr [1:3] "marker1_vals" "marker2_vals" "marker3_vals"
#>  $ metadata_cols: chr "metadata1_vals"
#>  $ norm_data    :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 1.2 1.08 1.11 1.08 1.11 ...
#>   ..$ marker2_vals  : num [1:3000] 1.26 1.36 1.23 1.3 1.34 ...
#>   ..$ marker3_vals  : num [1:3000] 1.46 1.51 1.36 1.53 1.4 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "no" "yes" "yes" ...
#>  $ scale        : chr "log10"
#>  $ method       : chr "None"
#>  $ otsu_data    :'data.frame':   24 obs. of  6 variables:
#>   ..$ slide_id        : chr [1:24] "slide1" "slide2" "slide3" "slide4" ...
#>   ..$ marker          : chr [1:24] "marker1_vals" "marker1_vals" "marker1_vals" "marker1_vals" ...
#>   ..$ table           : chr [1:24] "raw" "raw" "raw" "raw" ...
#>   ..$ slide_threshold : num [1:24] 12 20 87.1 44 19 ...
#>   ..$ marker_threshold: num [1:24] 54.9 54.9 54.9 54.9 52.9 ...
#>   ..$ misclass_error  : num [1:24] 0.451 0.431 0.257 0.339 0.533 ...
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
form (note the inclusion of `slide_id` as an identifier, which we’ll use
later):

``` r
head(mx_umap$umap_data)
#>      marker1_vals marker2_vals marker3_vals metadata1_vals slide_id table
#> 970            19           20           29             no   slide2   raw
#> 252            10           22           24            yes   slide1   raw
#> 1530           77           99           26            yes   slide3   raw
#> 2047           95           64           57            yes   slide3   raw
#> 2336           58           94           82             no   slide4   raw
#> 1098           15           13           28            yes   slide2   raw
#>              U1        U2
#> 970   -9.807456  1.184323
#> 252  -12.903388 -6.301204
#> 1530   8.887341 11.085225
#> 2047  10.602274  7.860260
#> 2336   9.784737 -5.957173
#> 1098 -11.371432 -2.673467
```

And the `mx_dataset` object now includes the following attributes:

``` r
str(mx_umap)
#> List of 13
#>  $ data         :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 15 11 12 11 12 11 16 12 11 10 ...
#>   ..$ marker2_vals  : num [1:3000] 17 22 16 19 21 17 18 19 19 23 ...
#>   ..$ marker3_vals  : num [1:3000] 28 31 22 33 24 19 36 32 22 25 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "no" "yes" "yes" ...
#>  $ slide_id     : chr "slide_id"
#>  $ image_id     : chr "image_id"
#>  $ marker_cols  : chr [1:3] "marker1_vals" "marker2_vals" "marker3_vals"
#>  $ metadata_cols: chr "metadata1_vals"
#>  $ norm_data    :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 1.2 1.08 1.11 1.08 1.11 ...
#>   ..$ marker2_vals  : num [1:3000] 1.26 1.36 1.23 1.3 1.34 ...
#>   ..$ marker3_vals  : num [1:3000] 1.46 1.51 1.36 1.53 1.4 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "no" "yes" "yes" ...
#>  $ scale        : chr "log10"
#>  $ method       : chr "None"
#>  $ otsu_data    :'data.frame':   24 obs. of  6 variables:
#>   ..$ slide_id        : chr [1:24] "slide1" "slide2" "slide3" "slide4" ...
#>   ..$ marker          : chr [1:24] "marker1_vals" "marker1_vals" "marker1_vals" "marker1_vals" ...
#>   ..$ table           : chr [1:24] "raw" "raw" "raw" "raw" ...
#>   ..$ slide_threshold : num [1:24] 12 20 87.1 44 19 ...
#>   ..$ marker_threshold: num [1:24] 54.9 54.9 54.9 54.9 52.9 ...
#>   ..$ misclass_error  : num [1:24] 0.451 0.431 0.257 0.339 0.533 ...
#>  $ otsu_table   : chr "both"
#>  $ threshold    : chr "otsu"
#>  $ umap_data    :'data.frame':   4800 obs. of  8 variables:
#>   ..$ marker1_vals  : num [1:4800] 19 10 77 95 58 15 83 58 11 99 ...
#>   ..$ marker2_vals  : num [1:4800] 20 22 99 64 94 13 91 75 16 98 ...
#>   ..$ marker3_vals  : num [1:4800] 29 24 26 57 82 28 39 83 25 68 ...
#>   ..$ metadata1_vals: chr [1:4800] "no" "yes" "yes" "yes" ...
#>   ..$ slide_id      : chr [1:4800] "slide2" "slide1" "slide3" "slide3" ...
#>   ..$ table         : chr [1:4800] "raw" "raw" "raw" "raw" ...
#>   ..$ U1            : num [1:4800] -9.81 -12.9 8.89 10.6 9.78 ...
#>   ..$ U2            : num [1:4800] 1.18 -6.3 11.09 7.86 -5.96 ...
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
#> 1:  0.97044681    slide marker1_vals   raw
#> 2:  0.02955319 residual marker1_vals   raw
#> 3:  0.97344941    slide marker2_vals   raw
#> 4:  0.02655059 residual marker2_vals   raw
#> 5:  0.87733930    slide marker3_vals   raw
#> 6:  0.12266070 residual marker3_vals   raw
```

And the `mx_dataset` object now includes the following attributes:

``` r
str(mx_var)
#> List of 14
#>  $ data         :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 15 11 12 11 12 11 16 12 11 10 ...
#>   ..$ marker2_vals  : num [1:3000] 17 22 16 19 21 17 18 19 19 23 ...
#>   ..$ marker3_vals  : num [1:3000] 28 31 22 33 24 19 36 32 22 25 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "no" "yes" "yes" ...
#>  $ slide_id     : chr "slide_id"
#>  $ image_id     : chr "image_id"
#>  $ marker_cols  : chr [1:3] "marker1_vals" "marker2_vals" "marker3_vals"
#>  $ metadata_cols: chr "metadata1_vals"
#>  $ norm_data    :'data.frame':   3000 obs. of  6 variables:
#>   ..$ slide_id      : chr [1:3000] "slide1" "slide1" "slide1" "slide1" ...
#>   ..$ image_id      : chr [1:3000] "image1" "image1" "image1" "image1" ...
#>   ..$ marker1_vals  : num [1:3000] 1.2 1.08 1.11 1.08 1.11 ...
#>   ..$ marker2_vals  : num [1:3000] 1.26 1.36 1.23 1.3 1.34 ...
#>   ..$ marker3_vals  : num [1:3000] 1.46 1.51 1.36 1.53 1.4 ...
#>   ..$ metadata1_vals: chr [1:3000] "yes" "no" "yes" "yes" ...
#>  $ scale        : chr "log10"
#>  $ method       : chr "None"
#>  $ otsu_data    :'data.frame':   24 obs. of  6 variables:
#>   ..$ slide_id        : chr [1:24] "slide1" "slide2" "slide3" "slide4" ...
#>   ..$ marker          : chr [1:24] "marker1_vals" "marker1_vals" "marker1_vals" "marker1_vals" ...
#>   ..$ table           : chr [1:24] "raw" "raw" "raw" "raw" ...
#>   ..$ slide_threshold : num [1:24] 12 20 87.1 44 19 ...
#>   ..$ marker_threshold: num [1:24] 54.9 54.9 54.9 54.9 52.9 ...
#>   ..$ misclass_error  : num [1:24] 0.451 0.431 0.257 0.339 0.533 ...
#>  $ otsu_table   : chr "both"
#>  $ threshold    : chr "otsu"
#>  $ umap_data    :'data.frame':   4800 obs. of  8 variables:
#>   ..$ marker1_vals  : num [1:4800] 19 10 77 95 58 15 83 58 11 99 ...
#>   ..$ marker2_vals  : num [1:4800] 20 22 99 64 94 13 91 75 16 98 ...
#>   ..$ marker3_vals  : num [1:4800] 29 24 26 57 82 28 39 83 25 68 ...
#>   ..$ metadata1_vals: chr [1:4800] "no" "yes" "yes" "yes" ...
#>   ..$ slide_id      : chr [1:4800] "slide2" "slide1" "slide3" "slide3" ...
#>   ..$ table         : chr [1:4800] "raw" "raw" "raw" "raw" ...
#>   ..$ U1            : num [1:4800] -9.81 -12.9 8.89 10.6 9.78 ...
#>   ..$ U2            : num [1:4800] 1.18 -6.3 11.09 7.86 -5.96 ...
#>  $ umap_table   : chr "both"
#>  $ var_data     :Classes 'data.table' and 'data.frame':  12 obs. of  4 variables:
#>   ..$ proportions: num [1:12] 0.9704 0.0296 0.9734 0.0266 0.8773 ...
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

Note that since the sample data is simulated, we don’t see separation of
the groups like we would expect with biological samples that have some
underlying correlation. What we can observe, however, is the separation
of slides in the `raw` data and subsequent mixing of these slides in the
`normalized` data:

``` r
plot_mx_umap(mx_umap,metadata_col = "slide_id")
```

<img src="man/figures/README-mx_umap_slide-1.png" width="100%" />

And we can also visualize the results of the variance proportions (note
that this is sample data, hence the proportions of variance at the slide
level are \(\approx 0\)):

``` r
plot_mx_proportions(mx_var)
```

<img src="man/figures/README-mx_var-1.png" width="100%" />
