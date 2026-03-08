# call brand yaml file
#' Get the application theme
#' @description A function to get the application theme
#' from the brand yaml file.
#' @import bslib brand.yml
#' @return a bslib theme object
#' @export
get_brand_theme <- function() {
  # system.file looks into the installed 'inst' folder automatically
  brand_path <- system.file(
    "_brand.yml",
    package = "golem_shiny"
  )

  # Error handling to help you debug
  if (brand_path == "") {
    stop("-- Could not find _brand.yml. --")
  }

  bslib::bs_theme(
    version = 5,
    brand = brand_path
  )
}

#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny bslib brand.yml
#' @noRd
app_ui <- function(request) {
  tagList(
    # add resources
    golem_add_external_resources(),

    # application UI logic
    bslib::page_navbar(
      title = "CRUD App",
      theme = get_brand_theme(),

      bslib::nav_spacer(),

      mod_table_ui("rep"),
      nav_item(
        input_dark_mode(
          id = "dark_mode",
          mode = "light"
        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "golem_shiny"
    )
  )
}
