#' reports UI Function
#' @description A shiny Module.
#' @param id: a random chr string
mod_table_ui <- function(id) {
  ns <- NS(id)
  nav_panel(
    tagList(icon("file-alt"), "DataSet"),
    layout_column_wrap(
      width = 1,
      card(
        card_header("DataSet Module"),
        card_body("This is the reports tab content.")
      )
    )
  )
}

#' reports Server Function
#' @description A shiny Module.
#' @param id: a random chr string but similar to ui module id
mod_table_server <- function(id, data_store) {
  moduleServer(id, function(input, output, session) {
    # Add server logic here
  })
}
