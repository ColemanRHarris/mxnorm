% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_mx_proportions.R
\name{plot_mx_proportions}
\alias{plot_mx_proportions}
\title{Visualize variance proportions by marker and table}
\usage{
plot_mx_proportions(mx_data)
}
\arguments{
\item{mx_data}{\code{mx_dataset} object that been used with \code{run_var_proportions()} to run random effects modeling. Note that the table attribute must be set when running \code{run_var_proportions()}.}
}
\value{
\code{ggplot2} object with proportions plot
}
\description{
Visualize variance proportions by marker and table
}
\examples{
mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
  c("marker1_vals","marker2_vals","marker3_vals"),
  c("metadata1_vals"))
mx_data = mx_normalize(mx_data, transform="log10",method="None")
mx_data = run_var_proportions(mx_data, table="both")
plot_mx_proportions(mx_data)
}
