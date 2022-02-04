---
title: 'mxnorm: An R Package to Normalize Multiplexed Imaging Data'
tags:
  - R
  - multiplexed imaging
  - normalization
  - statistics
authors:
  - name: Coleman Harris
    orcid: 0000-0002-6325-0694
    affiliation: "1, 3"
  - name: Simon Vandekar
    affiliation: 1
  - name: Julia Wrobel
    affiliation: 2
affiliations:
 - name: Department of Biostatistics, Vanderbilt University Medical Center, Nashville, TN, USA
   index: 1
 - name: Department of Biostatistics & Informatics, Colorado School of Public Health, Aurora, CO, USA
   index: 2
 - name: Corresponding author ([email](mailto:coleman.r.harris@vanderbilt.edu))
   index: 3
date: 4 February 2022
bibliography: mxnorm_pcitations.bib
link-citations: true
---

# Summary

The field of multiplexed imaging has emerged in the biological research space as a major development in methods to understand and analyze complex processes like cancer, tumor development, and more. These imaging methods leverage single-cell analyses that provide detailed information about interactions between cells. This field is rapidly growing with a noted lack of standardized pipelines and a necessity for methods that address sources of technical variation within this complex data source. One key area of research in the multiplexed imaging field is the normalization of intensity data, with current state-of-the-art methods varying heavily between labs and technical implementations.

This paper introduces `mxnorm`, an R package to normalize multiplexed imaging data. As an open-source software built with R and S3 methods, `mxnorm` extends normalization techniques and comparison metrics introduced for the analysis of multiplexed imaging data in R [@harris2022quantifying]. It intends to set a foundation for the analysis of multiplexed imaging data in R, extend normalization methods into the field in a user-friendly way, and provide easy applications of a robust evaluation framework to measure both technical variability and the efficacy of various normalization methods. Core features, usage details, and extensive tutorials are available in the package documentation & vignette.

# Statement of need

Multiplexed imaging is at the forefront of imaging methods developed to measure dozens of marker channels at the single-cell level while preserving their spatial coordinates. This allows for single-cell analyses performed on biological samples like tissues and tumors, much like single-cell RNA sequencing, with the added benefit of *in situ* coordinates to better capture spatial interactions between individual cells [@mckinley2022miriam,@chen2021differential]. Current methods like multiplexed immunofluorescence imaging (MxIF) and multiplexed ion beam imaging (MIBI) demonstrate this growing body of research that seeks to better understand cell-cell populations in cancer, pre-cancer, and various biological research contexts [@ptacek2020multiplexed; @gerdes2013highly].

In contrast to the field of sequencing & micro-array data and the established software, analysis, and methods therein, the multiplexed imaging field lacks a clear set of analysis standards, pipelines, and methods. Standard software in the sequencing field include open-source software developed in R like `DESeq2` & `limma` [@love2014moderated; @smyth2005limma], and further methods developed in Python like `HTSeq` and `featureCounts` [@anders2015htseq; @liao2014featurecounts]. This is a well-documented problem in multiplexed imaging, where robust, open-source software does exist at the same scale. However, recent developments seek to address this disparity -- the MCMICRO pipeline seeks to provide a set of open-source, reproducible analyses to transform whole-slide images into single-cell data [@schapiro2021mcmicro], researchers in the field have also developed a ground truth dataset to evaluate differences in batch effects and normalization methods [@graf2022flino], and other open issues in the field that may produce open-source solutions include tissue segmentation, end-to-end image processing, and removal of image artifacts. Nevertheless, these technical challenges lead to a disparate landscape for combining tools in multiplexed imaging across methodologies, imaging pipelines, programming languages & software, making it difficult for researchers across the world to collaborate and compare results.

In addition to the lack of standardized pipelines and methods, we previously addressed the lack of normalization methods for intensity data in the multiplexed imaging field. Normalization methods were shown to be very important in multiplexed imaging, where slide-to-slide variation is significant and disrupts statistical inference. Further, there is a noted lack of software in open-source programming languages like R to address normalization challenges in multiplexed imaging. Algorithms like the RESTORE algorithm & associated work are the beginning of contributions to normalization literature [@chang2020restore; @burlingame2021toward], but do not address the technical challenges of intensity normalization at the marker level and lack a simple implementation analogous to an open-source R package. Further, implementations of multiplexed imaging are limited mostly to Matlab, Python, and only a scattered few R packages exist. Two prominent packages, `cytomapper` and `giotto`, contain open-source implementations for analysis and visualization of highly multiplexed images [@eling2020cytomapper; @dries2021giotto], but do not explicitly address normalization of the single-cell intensity data. Hence, the `mxnorm` package provides easy-to-implement normalization methods and a foundation for evaluating their utility in the multiplexed imaging field.

# Functionality

![Figure 1: Basic structure of the `mxnorm` package and associated functions](mxnorm_structure.png){width=100%}

As shown in **Figure 1**, there are three main types of functions implemented in the `mxnorm` package -- infrastructure, analysis, and visualization. The first infrastructure function, `mx_dataset()`, specifies & creates the S3 object used throughout the analysis, while the `mx_normalize()` function provides a routine to normalize the multiplexed imaging data. Each of the three analysis functions provides methods to run specific analyses that test for slide-to-slide variation and preservation of biological signal for the normalized and unnormalized data, while the four visualization functions provide methods to generate `ggplot2` plots to visualize the results. We also extend the `summary()` generic function to apply to the `mx_dataset` S3 object to provide further statistics & summaries. All of the normalization and analysis methods are detailed further in our package [vignette](https://google.com) and in the methods paper [@harris2022quantifying].

# A minimal example

The following code is a simplified example of a normalization method applied to the sample dataset included in the `mxnorm` package, `mx_sample`. Here we specify the creation of the S3 object, normalize using the `mean_divide` method, and run a set of analyses to compare our normalized data with the unnormalized data.

```{r}
## load package
library(mxnorm)

## create S3 object & normalize
mx_data = mx_dataset(mx_sample, "slide_id", "image_id", c("marker1_vals","marker2_vals","marker3_vals"), c("metadata1_vals"))
mx_data = mx_normalize(mx_data, "mean_divide", "None")

## run analyses
mx_data = run_otsu_discordance(mx_data, "both")
mx_data = run_reduce_umap(mx_data, "both", c("marker1_vals","marker2_vals","marker3_vals"))
mx_data = run_var_proportions(mx_data, "both")

## results and plots
summ_mx_data = summary(mx_data)
p1 = plot_mx_density(mx_data)
p2 = plot_mx_discordance(mx_data)
p3 = plot_mx_umap(mx_data, "slide_id")
p4 = plot_mx_proportions(mx_data)
```

# Acknowledgements

The corresponding author would like to thank his co-authors for their ideas, suggestions, and contributions to the development of `mxnorm`, and the numerous collaborators who helped make this possible.

# Notes
- https://joss.readthedocs.io/en/latest/submitting.html#what-should-my-paper-contain

# References