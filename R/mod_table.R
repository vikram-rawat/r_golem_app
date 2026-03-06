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
        card_body(
          hotwidgetOutput(ns("table"))
        )
      )
    )
  )
}


#' reports Server Function
#' @description A shiny Module.
#' @param id: a random chr string but similar to ui module id
mod_table_server <- function(id, data_store) {
  moduleServer(id, function(input, output, session) {
    output$table <- renderHotwidget({
      # Get data from data_store and pass to hotwidget
      work_dt <- data_store$work_dt
      hotwidget(data = work_dt, colHeaders = names(work_dt))
    })
  })
}
