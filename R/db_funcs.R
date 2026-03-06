#' Get Database Manager
#' A helper function to create and return an instance of the DuckDB manager class.
#' @param package The package name containing the DuckDB database file.
#' @param folder The folder within the package where the DuckDB database file is located.
#' @param filename The name of the DuckDB database file.
#' @return An instance of the duckdb_mng class, connected to the specified database
#' @export
get_db_store <- function(
  package = "golem_shiny",
  folder = "extdata",
  filename = "mtcars.duckdb"
) {
  db_path <- system.file(
    folder,
    filename,
    package = package
  )

  dbm <- duckdb_mng$new(db_path = db_path)

  return(dbm)
}
