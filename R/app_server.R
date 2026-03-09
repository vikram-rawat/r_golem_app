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

  tryCatch(
    {
      session$userData$duckdb_mng <- get_db_store(
        package = db_path$package,
        folder = db_path$folder,
        filename = db_path$filename
      )
    },
    error = function(e) {
      showNotification(
        HTML(
          sprintf(
            "<p>Something Wrong with Data in Database</p>
             <br>
             <p>
               <strong>Data Validation Error:</strong>
               %s
             </p>",
            e$message
          )
        ),
        type = "error",
        duration = 5
      )
    }
  )

  session$userData$duckdb_mng$db_connect()

  app_dt_store <- data_store$new(session$userData$duckdb_mng)

  mod_table_server("rep", data_store = app_dt_store)
}
