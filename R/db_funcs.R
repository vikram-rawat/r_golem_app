#' Get Database Manager
#' A helper function to create and return an instance of the DuckDB manager class.
#' @param db_path The file path to the DuckDB database. Defaults to the bundled
#' mtcars.duckdb file in the package's extdata directory.
#' @return An instance of the duckdb_mng class, connected to the specified database
#' @export
get_db_store <- function(
  db_path = system.file("extdata", "mtcars.duckdb", package = "golem_shiny")
) {
  dbm <- duckdb_mng$new(db_path = db_path)

  return(dbm)
}
