DataStore <- R6::R6Class(
  "DataStore",
  public = list(
    db_mng = NULL, # duckdb manager object
    data = NULL, # working data frame currently in use
    original = NULL, # original baseline snapshot of the data

    initialize = function(db_mng) {
      self$db_mng <- db_mng
      #
      # 3. Query the "mtcars" table from the database
      #    using DBI::dbGetQuery()
      #
      # 4. Store the result in:
      #    - self$data     (the working, mutable copy)
      #    - self$original (the immutable original snapshot)
    },

    update_cell = function(row, col, value) {
      # PURPOSE:
      # --------
      # Update a single cell in the working dataset.
      #
      # Args:
      #  row   : integer row index
      #  col   : column name or column index
      #  value : new value to assign
      #
      # EXPECTED BEHAVIOR:
      # - Modify the corresponding cell in self$data
      # - Do NOT modify self$original
      # - Ensure that data types remain consistent when possible
    },

    revert = function() {
      # PURPOSE:
      # --------
      # Reset the working data (self$data) back to the original snapshot.
      #
      # EXPECTED BEHAVIOR:
      # - self$data should become identical to self$original
      # - Does not affect the database or the connection
    },

    summary = function() {
      # PURPOSE:
      # --------
      # Return a simple human-readable summary of the current dataset.
      #
      # EXPECTED BEHAVIOR:
      # - If no data has been loaded yet, return a message like:
      #       "No data loaded"
      # - Otherwise return something like:
      #       "Rows: X | Columns: Y"
      #
      # This is meant for display in the Shiny UI.
    }
  )
)
