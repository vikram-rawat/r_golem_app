#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic
  store <- DataStore$new()

  session$onSessionEnded(
    function() {
      # session$userData$sqlite_db |>
      #   db_disconnect()
    }
  )

  # session$userData$sqlite_db <- sqlite_mng(global_configs$main_db_path) |>
  #   db_connect()

  mod_reports_server("rep")
}
