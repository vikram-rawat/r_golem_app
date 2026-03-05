#' DuckDB Manager Class
#' This R6 class provides a simple interface for managing a DuckDB connection
#' and executing queries. It includes methods for connecting to the database,
#' checking the connection status, executing SQL queries, and disconnecting
#' from the database.
#' @import R6
#' @import DBI
#' @import duckdb
#' @export

duckdb_mng <- R6::R6Class(
  "duckdb_mng",

  public = list(
    # Properties
    db_path = NULL,
    connection = NULL,

    # Constructor
    initialize = function(db_path = ":memory:") {
      self$db_path <- db_path
    },

    # Print method
    print = function(...) {
      cat("DuckDBManager\n")
      cat("  Database:", self$db_path, "\n")
      cat("  Connected:", self$is_connected(), "\n")
      invisible(self)
    },

    # Connect to DB
    db_connect = function() {
      tryCatch(
        {
          self$connection <- DBI::dbConnect(
            duckdb::duckdb(),
            dbdir = self$db_path,
            read_only = FALSE
          )
          message("Connected to DuckDB: ", self$db_path)
          invisible(self)
        },
        error = function(e) {
          stop("Failed to connect to DuckDB: ", e$message)
        }
      )
    },

    # Check connection
    is_connected = function() {
      !is.null(self$connection) && DBI::dbIsValid(self$connection)
    },

    # Execute query
    db_get_query = function(sql_query, ...) {
      if (!self$is_connected()) {
        stop("No active connection. Call db_connect() first.")
      }
      DBI::dbGetQuery(self$connection, sql_query, ...) |>
        data.table::as.data.table()
    },

    # Disconnect
    db_disconnect = function() {
      if (self$is_connected()) {
        DBI::dbDisconnect(self$connection, shutdown = TRUE)
        self$connection <- NULL
        message("Disconnected from DuckDB: ", self$db_path)
      } else {
        message("No active connection to disconnect")
      }
      invisible(self)
    }
  )
)
