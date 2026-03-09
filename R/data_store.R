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

      if (self$validate_dataset(mtcars_tbl)) {
        self$original_dt <- mtcars_tbl
        self$work_dt <- copy(mtcars_tbl)
      }
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

      temp_tbl <- copy(self$work_dt)

      if (is.null(value)) {
        temp_tbl[row, (col) := NA]
      } else {
        temp_tbl[row, (col) := cast_value]
      }

      if (self$validate_dataset(temp_tbl)) {
        self$work_dt <- temp_tbl
      } else {
        return(FALSE)
      }
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
      if (self$validate_dataset(self$work_dt)) {
        self$db_mng$db_write_table(self$work_dt, "mtcars")
        self$original_dt <- copy(self$work_dt)
      } else {
        return(FALSE)
      }
    },

    #' @description
    #' Validate the structure and content of the `mtcars` dataset.
    #' @param df Data frame to validate
    #' @return TRUE if validation passes, otherwise throws an error.
    validate_dataset = function(df) {
      # Must be a data.frame
      assert_data_frame(df, min.rows = 1, col.names = "named")

      # Required columns
      required_cols <- c(
        "cars",
        "mpg",
        "cyl",
        "disp",
        "hp",
        "drat",
        "wt",
        "qsec",
        "vs",
        "am",
        "gear",
        "carb",
        "uuid"
      )

      assert_subset(required_cols, colnames(df))

      # character checks
      assert_character(df$cars, min.chars = 1)
      assert_character(df$uuid, min.chars = 1)

      # Numeric checks
      assert_numeric(df$mpg, lower = 0, finite = TRUE)
      assert_numeric(df$cyl, lower = 1, upper = 10)
      assert_numeric(df$disp, lower = 0, finite = TRUE)
      assert_numeric(df$hp, lower = 0, finite = TRUE)
      assert_numeric(df$drat, lower = 0, finite = TRUE)
      assert_numeric(df$wt, lower = 0, finite = TRUE)
      assert_numeric(df$qsec, lower = 0, finite = TRUE)
      assert_numeric(df$vs, lower = 0, upper = 1)
      assert_numeric(df$am, lower = 0, upper = 1)
      assert_numeric(df$gear, lower = 1, upper = 10)
      assert_numeric(df$carb, lower = 1, upper = 10)

      return(TRUE)
    },

    #' @description
    #' Return a simple summary of the current dataset.
    #' @return A character string with row and column counts,
    #' or "No data loaded" if empty.
    summary = function() {
      if (is.null(self$work_dt)) {
        return("No data loaded")
      }
      return(
        list(
          rows_work_dt = self$work_dt |> nrow(),
          cols_work_dt = self$work_dt |> ncol(),
          avg_mpg_work_dt = self$work_dt$mpg |>
            mean() |>
            round(2),
          mode_mpg_work_dt = self$work_dt[,
            .N,
            by = cyl
          ][
            which.max(N),
            round(cyl, 0)
          ],
          max_hp_work_dt = self$work_dt$hp |>
            max(),
          avg_wt_work_dt = self$work_dt$wt |>
            mean() |>
            round(2)
        )
      )
    }
  )
)
