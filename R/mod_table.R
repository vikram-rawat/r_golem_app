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
    # Render the table
    output$table <- renderHotwidget({
      # Get data from data_store and pass to hotwidget
      work_dt <- data_store$work_dt[, -"uuid"]
      hotwidget(data = work_dt, colHeaders = names(work_dt))
    })

    # Listen for cell changes from hotwidget
    observeEvent(input$table_cell_change, {
      # Extract row, column, and value from the change event
      row <- input$table_cell_change$row
      col <- input$table_cell_change$col
      value <- input$table_cell_change$value

      # Update the data store using the update_cell method
      data_store$update_cell(row, col, value)
      data_store$work_dt
    })
  })
}
