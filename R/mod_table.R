#' reports UI Function
#' @description A shiny Module.
#' @param id: a random chr string
#' @import bsicons
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
            class = "btn-outline-warning",
            label = "Save Changes",
            icon = icon("save")
          ),
          actionButton(
            inputId = ns("reset_btn"),
            class = "btn-outline-primary",
            label = "Reset Changes",
            icon = icon("undo")
          )
        )
      ),
      layout_columns(
        col_widths = c(8, 4),
        card(
          card_header("DataSet"),
          card_body(
            hotwidgetOutput(ns("table"))
          )
        ),
        card(
          card_header("Summary"),
          layout_column_wrap(
            width = 1,
            heights_equal = "all",
            value_box(
              title = "Dataset Summary",
              value = textOutput(ns("sm_records")),
              showcase = bsicons::bs_icon("car-front-fill"),
              theme = "primary"
            ),
            value_box(
              title = "Avg. Fuel Efficiency (MPG)",
              value = textOutput(ns("sm_mpg")),
              showcase = icon("tachometer-alt"),
              theme_color = "primary"
            ),
            value_box(
              title = "Most Common Cylinders",
              value = names(which.max(table(mtcars$cyl))),
              showcase = icon("cogs"),
              theme_color = "primary"
            ),
            value_box(
              title = "Top Horsepower",
              value = textOutput(ns("sm_hp")),
              showcase = icon("bolt"),
              theme_color = "primary"
            ),
            value_box(
              title = "Avg. Weight (1000 lbs)",
              value = textOutput(ns("sm_wt")),
              showcase = icon("weight"),
              theme_color = "primary"
            )
          )
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
    mod_store <- reactiveValues(
      update_dt = 1,
      store_dt = 1
    )

    # Render the table
    output$table <- renderHotwidget({
      req(mod_store$update_dt) # Trigger re-render when update_dt changes
      req(mod_store$store_dt) # Trigger re-render when store_dt changes
      hotwidget(
        data = data_store$work_dt[, -"uuid"],
        colHeaders = names(data_store$work_dt[, -"uuid"])
      )
    })

    output$sm_records <- renderText({
      req(mod_store$update_dt) # Trigger re-render when update_dt changes
      req(mod_store$store_dt) # Trigger re-render when store_dt changes
      sprintf(
        fmt = "%d Rows & %d columns",
        nrow(data_store$work_dt),
        ncol(data_store$work_dt)
      )
    })

    output$sm_mpg <- renderText({
      req(mod_store$update_dt) # Trigger re-render when update_dt changes
      req(mod_store$store_dt) # Trigger re-render when store_dt changes
      sprintf(
        fmt = "%.2f MPG",
        data_store$work_dt$mpg |>
          mean() |>
          round(2)
      )
    })

    output$sm_hp <- renderText({
      req(mod_store$update_dt) # Trigger re-render when update_dt changes
      req(mod_store$store_dt) # Trigger re-render when store_dt changes

      sprintf(
        fmt = "%d HP",
        data_store$work_dt$hp |>
          max()
      )
    })

    output$sm_wt <- renderText({
      req(mod_store$update_dt) # Trigger re-render when update_dt changes
      req(mod_store$store_dt) # Trigger re-render when store_dt changes

      sprintf(
        fmt = "%.2f (1000 lbs)",
        data_store$work_dt$wt |>
          mean() |>
          round(2)
      )
    })

    # Listen for cell changes from hotwidget
    observe({
      # Extract row, column, and value from the change event
      row <- input$table_cell_change$row
      col <- input$table_cell_change$col
      value <- input$table_cell_change$value

      # Update the data store using the update_cell method
      data_store$update_cell(row, col, value)
      data_store$work_dt
      mod_store$update_dt <- mod_store$update_dt + 1
    }) |>
      bindEvent(input$table_cell_change)

    # Listen for reset button click
    observe({
      data_store$revert()
      mod_store$store_dt <- mod_store$store_dt + 1
      # Call showNotification to display the message
      showNotification(
        "MTCars table reverted to original state successfully!",
        type = "message",
        duration = 5
      )
    }) |>
      bindEvent(input$reset_btn)

    # Listen for Save button click
    observe({
      data_store$save_table()
      # Call showNotification to display the message
      showNotification(
        "MTCars table updated successfully!",
        type = "message",
        duration = 5
      )
    }) |>
      bindEvent(input$save_btn)
  })
}
