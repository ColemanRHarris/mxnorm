% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mx_dataset.R
\name{mx_dataset}
\alias{mx_dataset}
\title{Generates mx_dataset}
\usage{
mx_dataset(data, slide_id, image_id, marker_cols, metadata_cols = NULL)
}
\arguments{
\item{data}{multiplexed data to normalize. Data assumed to be a data.frame with cell-level data.}

\item{slide_id}{String slide identifier of input \code{data}. This must be a column in the \code{data} data.frame.}

\item{image_id}{String image identifier of input \code{data}. This must be a column in the \code{data} data.frame.}

\item{marker_cols}{vector of column name(s) in \code{data} corresponding to marker values.}

\item{metadata_cols}{other identifiers of the input \code{data} (default=NULL). This must be a vector of column name(s) in the \code{data} data.frame.}
}
\value{
data.frame object in the mx_dataset format with attribute for input type
}
\description{
Takes in data from data.frame of cell-level multiplexed data to create a mx_dataset S3 object.
}
\examples{
mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
  c("marker1_vals","marker2_vals","marker3_vals"),
  c("metadata1_vals"))
}
