% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ca.R
\name{ca}
\alias{ca}
\alias{ca.ca_ca}
\alias{ca.vegan_cca}
\title{Correspondence Analysis}
\usage{
ca.ca_ca(..., raw_output = TRUE)

ca.vegan_cca(..., raw_output = TRUE)
}
\arguments{
\item{...}{Input arguments of the relevant wrapped functions.}

\item{raw_output}{Logical. Should the raw output of the wrapped functions be stored as
an additional output attribute "raw"? Default: TRUE.}
}
\value{
A tibble with the ca results for variables (columns) and objects (rows).
Additional values are stored in object attributes. See \code{attributes(result)$raw}.

name: Character. Names of rows and columns.

type: Character. Type of entry ("row" or "col").

...: Additional variables as provided by the wrapped functions.

CA1...CAX: Numeric. Resulting coordinates.
}
\description{
Correspondence Analysis function wrappers that give the result in a tidy data.frame.
}
\examples{
ca.ca_ca(matuskovo_material)
ca.vegan_cca(matuskovo_material)

}
