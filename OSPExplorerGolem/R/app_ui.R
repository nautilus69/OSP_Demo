#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import DT
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leaving this function for adding external resources
    golem_add_external_resources(),

    # Your application UI logic starts here:
    fluidPage(
      titlePanel(h1("OSP Data Explorer (Golem Demo)",
                    style = "color: #007bff; text-align: center; margin-bottom: 30px;")),

      sidebarLayout(
        sidebarPanel(
          class = "sidebar",
          width = 2,
          h3("Controls", style = "margin-top: 0; color: #343a40;"),
          # Data Loader Module UI
          mod_data_loader_ui("data_input")
        ),
        mainPanel(
          class = "main-panel",
          width = 10,
          tabsetPanel(
            id = "main_tabs",
            tabPanel("Visualization", mod_visualization_ui("data_plot")),
            tabPanel("Raw Data", DT::dataTableOutput("raw_data_table"))
          )
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
      app_title = "OSPExplorerGolem"
    ),
    # Add Inter font from Google Fonts
    tags$link(rel = "stylesheet",
              href = "https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap"),

    # Custom CSS styles
    tags$style(HTML("
      body {
        font-family: 'Inter', sans-serif;
        background-color: #f8f9fa;
        color: #333;
      }
      .container-fluid {
        padding-top: 20px;
        padding-bottom: 20px;
      }
      .panel {
        border-radius: 8px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        background-color: #ffffff;
        padding: 20px;
        margin-bottom: 20px;
      }
      .well {
        border-radius: 8px;
        background-color: #e9ecef;
        border: 1px solid #dee2e6;
      }
      h1, h2, h3, h4, h5, h6 {
        color: #212529;
      }
      .sidebar {
        background-color: #f0f2f5;
        border-right: 1px solid #dee2e6;
        padding: 15px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
      }
      .main-panel {
        padding: 15px;
      }
      .tab-content {
        border: 1px solid #dee2e6;
        border-top: none;
        padding: 15px;
        border-radius: 0 0 8px 8px;
        background-color: #ffffff;
      }
      .nav-tabs .nav-link.active {
        background-color: #ffffff !important;
        border-color: #dee2e6 #dee2e6 #fff !important;
        color: #007bff !important;
      }
      .btn-primary {
        background-color: #007bff;
        border-color: #007bff;
        border-radius: 6px;
        padding: 8px 15px;
      }
      .btn-primary:hover {
        background-color: #0056b3;
        border-color: #0056b3;
      }
    "))
  )
}
