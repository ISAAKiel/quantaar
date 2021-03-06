#' Seriation
#'
#' Seriation function wrappers that give the result in a long tidy data.frame.
#' The result table can be transformed to a wide format with \code{spread_seriation}.
#'
#' @param ... Input arguments of \code{seriation::seriate}.
#' @param raw_output Logical. Should the raw output of the wrapped functions be stored as
#' an additional output attribute "raw"? Default: TRUE.
#'
#' @return A tibble with the seriation result in a long format.
#' Additional values are stored in object attributes. See \code{attributes(result)$raw}.
#'
#' row: Character. Names of rows.
#'
#' row_order: Integer. Order of rows.
#'
#' col: Character. Names of columns.
#'
#' col_order: Integer. Order of columns.
#'
#' value: Numeric. Value in input matrix for respective row and col.
#'
#' @examples
#' seriation.seriation_seriate(matuskovo_material, method = "PCA")
#'
#' library(tabula)
#' matuskovo_CountMatrix <- as(matuskovo_material, "CountMatrix")
#' seriation.tabula_seriate(matuskovo_CountMatrix, method = "correspondance")
#'
#' # transform back to wide format
#' spread_seriation(seriation.seriation_seriate(matuskovo_material, method = "PCA"))
#'
#' @name seriation
#' @rdname seriation
NULL

#' @rdname seriation
#'
#' @export
seriation.seriation_seriate <- function(..., raw_output = TRUE) {

  check_if_packages_are_available(c("seriation"))

  # modify input
  other_params <- list()
  if ("x" %in% names(list(...))) {
    x <- list(...)$x
    if (length(list(...)) > 1) {
      other_params <- list(...)[names(list(...)) != "x"]
    }
  } else {
    x <- list(...)[[1]]
    if (length(list(...)) > 1) {
      other_params <- list(...)[2:length(list(...))]
    }
  }
  if (length(other_params) == 0) {
    other_params$method <- "PCA"
  } else if (length(other_params) == 1 & is.null(other_params[[1]])) {
    other_params$method <- "PCA"
  }

  if (is.data.frame(x)) {
    x_matrix <- as.matrix(x)
  } else if (is.matrix(x)) {
    x_matrix <- x
  } else {
    stop("x is not a data.frame.")
  }

  # run seriation
  q <- do.call(
    what = seriation::seriate,
    args = list(
      x = x_matrix,
      unlist(other_params)
    )
  )
  seriation_order_rows <- seriation::get_order(q, dim = 1)
  seriation_order_cols <- seriation::get_order(q, dim = 2)

  x_matrix_reordered <- x_matrix[seriation_order_rows, seriation_order_cols]
  x_tibble_reordered <- tibble::as_tibble(x_matrix_reordered)
  x_tibble_reordered$row <- rownames(x)[seriation_order_rows]
  x_tibble_reordered$row_order <- 1:nrow(x_tibble_reordered)

  x_gathered <- tidyr::gather(
    x_tibble_reordered,
    key = "col",
    value = "value",
    -"row", -"row_order"
  )

  x_gathered$col_order <- rep(1:length(seriation_order_cols), each = length(seriation_order_rows))

  res <- dplyr::select(
    x_gathered,
    "row",
    "row_order",
    "col",
    "col_order",
    "value"
  )

  # set factor levels
  res$row <- forcats::fct_inorder(res$row)
  res$col <- forcats::fct_inorder(res$col)

  # raw output
  if (raw_output) {
    attr(res, "raw") <- q
  }

  return(res)
}

#' @rdname seriation
#'
#' @export
seriation.tabula_seriate <- function(..., raw_output = TRUE) {

  check_if_packages_are_available(c("tabula"))

  if ("object" %in% names(list(...))) {
    object <- list(...)$object
  } else {
    object <- list(...)[[1]]
  }

  # run seriation
  q <- tabula::seriate(...)

  seriation_order_rows <- q@rows
  seriation_order_cols <- q@columns

  x_matrix_reordered <- object[seriation_order_rows, seriation_order_cols]
  x_tibble_reordered <- tibble::as_tibble(x_matrix_reordered)
  x_tibble_reordered$row <- rownames(object)[seriation_order_rows]
  x_tibble_reordered$row_order <- 1:nrow(x_tibble_reordered)

  x_gathered <- tidyr::gather(
    x_tibble_reordered,
    key = "col",
    value = "value",
    -"row", -"row_order"
  )

  x_gathered$col_order <- rep(1:length(seriation_order_cols), each = length(seriation_order_rows))

  res <- dplyr::select(
    x_gathered,
    "row",
    "row_order",
    "col",
    "col_order",
    "value"
  )

  # set factor levels
  res$row <- forcats::fct_inorder(res$row)
  res$col <- forcats::fct_inorder(res$col)

  # raw output
  if (raw_output) {
    attr(res, "raw") <- q
  }

  return(res)
}

#' @rdname seriation
#'
#' @param x Data.frame. Output of the seriation wrapper functions.
#'
#' @export
spread_seriation <- function(x) {

  x_simple <- dplyr::select(
    x,
    -"row_order",
    -"col_order"
  )

  x_spread <- tidyr::spread(
    x_simple,
    key = "col",
    value = "value"
  )

  res <- tibble::column_to_rownames(
    x_spread,
    "row"
  )

  return(res)
}
