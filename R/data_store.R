#' DataStore R6 Class
#'
#' A lightweight utility class for managing a working dataset
#' alongside its original snapshot, with support for cell updates,
#' reverting changes, and summarizing the dataset.
#'
#' @description
#' The `DataStore` class is designed to work with a database manager
#' (e.g., DuckDB). It loads a baseline dataset, keeps a copy for
#' modifications, and provides methods to update, revert, and summarize.
#'
#' @section Fields:
#' - `db_mng`: Database manager object (DuckDB or similar).
#' - `work_dt`: Working data.table currently in use.
#' - `original_dt`: Original baseline snapshot of the dataset.
#'
#' @section Methods:
#' - `initialize(db_mng)`: Load dataset from the database and create
#'   both original and working copies.
#' - `update_cell(row, col, value)`: Update a single cell in the working
#'   dataset, preserving type consistency.
#' - `revert()`: Reset the working dataset back to the original snapshot.
#' - `summary()`: Return a human-readable summary of the dataset.
#'
#' @examples
#' \dontrun{
#'   ds <- DataStore$new(db_mng)
#'   ds$summary()
#'   ds$update_cell(1, "mpg", 25)
#'   ds$revert()
#' }
#'
data_store <- R6::R6Class(
  "data_store",
  public = list(
    #' @field db_mng Database manager object
    db_mng = NULL,

    #' @field work_dt Working dataset (modifiable copy)
    work_dt = NULL,

    #' @field original_dt Original baseline snapshot
    original_dt = NULL,

    #' @description
    #' Initialize the DataStore by loading the `mtcars` table
    #' from the database manager and creating both original and
    #' working copies.
    #' @param db_mng Database manager object with `db_get_query` method
    initialize = function(db_mng) {
      self$db_mng <- db_mng

      mtcars_tbl <- self$db_mng$db_get_query("SELECT * FROM mtcars")

      mtcars_tbl[,
        uuid := apply(.SD, 1, paste, collapse = ""),
        .SDcols = names(mtcars_tbl)
      ]
      mtcars_tbl[, uuid := paste0(1:.N, "__", uuid)]

      self$original_dt <- mtcars_tbl
      self$work_dt <- copy(mtcars_tbl)
    },

    #' @description
    #' Update a single cell in the working dataset.
    #' @param row Integer row index
    #' @param col Column name or index
    #' @param value New value to assign
    #' @details
    #' - Only modifies `work_dt`, not `original_dt`.
    #' - Attempts to coerce the new value to the existing column type.
    update_cell = function(row, col, value) {
      if (is.numeric(col)) {
        col <- names(self$work_dt)[col]
      }

      target_type <- typeof(self$work_dt[[col]])
      cast_value <- switch(
        target_type,
        "integer" = as.integer(value),
        "double" = as.numeric(value),
        "character" = as.character(value),
        "logical" = as.logical(value),
        value
      )

      self$work_dt[row, (col) := cast_value]
    },

    #' @description
    #' Reset the working dataset back to the original snapshot.
    #' @return No return value, called for side effects.
    revert = function() {
      self$work_dt <- copy(self$original_dt)
    },

    #' @description
    #' Write the current working dataset back to the database.
    #' @return No return value, called for side effects.
    save_table = function() {
      self$db_mng$db_write_table(self$work_dt, "mtcars")
      self$original_dt <- copy(self$work_dt)
    },

    #' @description
    #' Return a simple summary of the current dataset.
    #' @return A character string with row and column counts,
    #' or "No data loaded" if empty.
    summary = function() {
      if (is.null(self$work_dt)) {
        return("No data loaded")
      }
      sprintf("Rows: %d | Columns: %d", nrow(self$work_dt), ncol(self$work_dt))
    }
  )
)
