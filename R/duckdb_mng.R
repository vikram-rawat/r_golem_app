#' DuckDB Manager R6 Class
#'
#' An R6 class to manage DuckDB connections, queries, and disconnection.
#' Provides a lightweight interface for connecting to a DuckDB database,
#' executing SQL queries, and closing the connection.
#'
#' @examples
#' \dontrun{
#' # Create a new manager for an in-memory DuckDB
#' dbm <- duckdb_mng$new(":memory:")
#'
#' # Connect to the database
#' dbm$db_connect()
#'
#' # Run a query
#' result <- dbm$db_get_query("SELECT 42 AS answer")
#' print(result)
#'
#' # Disconnect
#' dbm$db_disconnect()
#' }
#'
#' @import R6 DBI duckdb
#'
#' @export

duckdb_mng <- R6::R6Class(
  "duckdb_mng",

  public = list(
    # Properties
    #' @field db_path The file path to the DuckDB database.
    #' Defaults to "\:memory:\" for an in-memory database.
    db_path = NULL,
    #' @field connection The active DBI connection object.
    #' Initially NULL until a connection is established.
    connection = NULL,

    # Constructor
    #' Initialize the DuckDB manager with an optional database path.
    #' @param db_path The file path to the DuckDB database.
    #' Defaults to ":memory" for an in-memory database.
    #' You can specify a file path to use a persistent database.
    #' Example usage:
    #'   dbm <- duckdb_mng$new(
    #'            db_path = "my_database.duck
    #'            db"
    #'  )
    #'
    initialize = function(db_path = ":memory:") {
      self$db_path <- db_path
    },

    # Print method
    #' @description
    #' Print a summary of the DuckDB manager object.
    #' Shows database path and connection status.
    #' @param ... Additional arguments (ignored).
    print = function(...) {
      cat("DuckDBManager\n")
      cat("  Database:", self$db_path, "\n")
      cat("  Connected:", self$is_connected(), "\n")
      invisible(self)
    },

    # Connect to DB
    #' @description
    #' Establish a connection to the DuckDB database.
    #' @return The manager object (invisible).
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
    #' @description
    #' Check if the connection is active and valid.
    #' @return Logical value indicating connection status.

    is_connected = function() {
      !is.null(self$connection) && DBI::dbIsValid(self$connection)
    },

    # Execute query
    #' @description
    #' Execute a SQL query on the connected DuckDB database.
    #' @param sql_query SQL query string.
    #' @param ... Additional arguments passed to `DBI::dbGetQuery`.
    #' @return A `data.table` containing the query results.

    db_get_query = function(sql_query, ...) {
      if (!self$is_connected()) {
        stop("No active connection. Call db_connect() first.")
      }
      DBI::dbGetQuery(self$connection, sql_query, ...) |>
        data.table::as.data.table()
    },
    #' Write Table
    #' @description
    #' Write a data frame or data table to the DuckDB database as a new table.
    #' @param dt A data frame or data table to write to the database.
    #' @param table_name The name of the table to create in the database.
    #' @return The manager object (invisible).
    db_write_table = function(dt, table_name) {
      if (!self$is_connected()) {
        stop("No active connection. Call db_connect() first.")
      }
      DBI::dbWriteTable(
        conn = self$connection,
        name = table_name,
        value = dt,
        overwrite = TRUE
      )

      message("Table '", table_name, "' written to DuckDB.")
      invisible(self)
    },

    # Disconnect
    #' @description
    #' Disconnect from the DuckDB database.
    #' Cleans up the connection and shuts down DuckDB.
    #' @return The manager object (invisible).

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
