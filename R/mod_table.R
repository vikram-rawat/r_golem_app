#' reports UI Function
#' @description A shiny Module.
#' @param id: a random chr string
mod_table_ui <- function(id) {
  ns <- NS(id)
  nav_panel(
    tagList(icon("file-alt"), "DataSet"),
    div(
      class = "container-md",
      layout_column_wrap(
        width = 1,
        h1("MTCars DataSet"),
        h6("interactive data table with real-time editing"),
        div(
          class = "d-flex justify-content-between",
          actionButton(
            inputId = ns("save_btn"),
            label = "Save Changes",
            icon = icon("save")
          ),
          actionButton(
            inputId = ns("reset_btn"),
            label = "Reset Changes",
            icon = icon("undo")
          )
        )
      ),
      layout_columns(
        col_widths = c(9, 3),
        card(
          card_header("DataSet"),
          card_body(
            hotwidgetOutput(ns("table"))
          )
        ),
        card(
          card_header("Summary"),
          "nothing"
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
