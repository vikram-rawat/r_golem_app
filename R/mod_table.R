#' reports UI Function
#' @description A shiny Module.
#' @param id: a random chr string
#' @import bsicons
mod_table_ui <- function(id) {
  ns <- NS(id)
  nav_panel(
    tagList(icon("file-alt"), "DataSet"),
    div(
      # class = "container-lg",
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
        col_widths = c(9, 3),
        card(
          card_header("DataSet"),
          card_body(
            div(
              div(
                class = "d-flex gap-2",
                selectInput(
                  inputId = ns("theme_select"),
                  label = "Theme:",
                  choices = c(
                    "Main" = "main",
                    "Horizon" = "horizon",
                    "Classic" = "classic"
                  ),
                  selected = "horizon",
                  width = "120px"
                ),
                selectInput(
                  inputId = ns("theme_mode_select"),
                  label = "Mode:",
                  choices = c(
                    "Light" = "light",
                    "Dark" = "dark",
                    "Auto" = "auto"
                  ),
                  selected = "light",
                  width = "100px"
                )
              )
            ),
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
              value = textOutput(ns("sm_cyl")),
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
        colHeaders = names(data_store$work_dt[, -"uuid"]),
        colTypes = c(
          "text",
          "numeric",
          "numeric",
          "numeric",
          "numeric",
          "numeric",
          "numeric",
          "numeric",
          "numeric",
          "numeric",
          "numeric"
        ),
        enableSorting = TRUE,
        enableFiltering = TRUE,
        theme = input$theme_select,
        themeMode = input$theme_mode_select
      )
    })

    data_summary <- reactive({
      req(mod_store$update_dt) # Trigger re-render when update_dt changes
      req(mod_store$store_dt) # Trigger re-render when store_dt changes
      return(
        data_store$summary()
      )
    })

    output$sm_records <- renderText({
      # req(mod_store$update_dt) # Trigger re-render when update_dt changes
      # req(mod_store$store_dt) # Trigger re-render when store_dt changes
      sprintf(
        fmt = "%d Rows & %d columns",
        data_summary()$rows_work_dt,
        data_summary()$cols_work_dt
      )
    })

    output$sm_mpg <- renderText({
      # req(mod_store$update_dt) # Trigger re-render when update_dt changes
      # req(mod_store$store_dt) # Trigger re-render when store_dt changes
      sprintf(
        fmt = "%.2f MPG",
        data_summary()$avg_mpg_work_dt
      )
    })

    output$sm_cyl <- renderText({
      # req(mod_store$update_dt) # Trigger re-render when update_dt changes
      # req(mod_store$store_dt) # Trigger re-render when store_dt changes
      sprintf(
        fmt = "%.2f Cylinders",
        data_summary()$mode_mpg_work_dt
      )
    })

    output$sm_hp <- renderText({
      # req(mod_store$update_dt) # Trigger re-render when update_dt changes
      # req(mod_store$store_dt) # Trigger re-render when store_dt changes

      sprintf(
        fmt = "%d HP",
        data_summary()$max_hp_work_dt
      )
    })

    output$sm_wt <- renderText({
      # req(mod_store$update_dt) # Trigger re-render when update_dt changes
      # req(mod_store$store_dt) # Trigger re-render when store_dt changes

      sprintf(
        fmt = "%.2f (1000 lbs)",
        data_summary()$avg_wt_work_dt
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
