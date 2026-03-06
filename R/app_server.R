#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic
  db_path <- get_golem_config("database_path")

  session$onSessionEnded(
    function() {
      session$userData$duckdb_mng$db_disconnect()
    }
  )

  session$userData$duckdb_mng <- get_db_store(
    package = db_path$package,
    folder = db_path$folder,
    filename = db_path$filename
  )

  session$userData$duckdb_mng$db_connect()

  store <- DataStore$new(session$userData$duckdb_mng)

  mod_reports_server("rep")
}
