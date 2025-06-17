# OSPExplorerApp/app.R

# Load required packages
library(plotly)
library(shiny)
library(dplyr)
library(ggplot2)
library(DT) # For displaying data tables
library(ospapputils)# Our custom utility package
library(readxl)

# Source R modules

source("R/mod_data_loader.R")
source("R/mod_visualization.R")

# Define UI for application
ui <- fluidPage(
  # Add a script tag for Inter font from Google Fonts (Tailwind-like aesthetic)
  tags$head(
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap"),
    tags$style(HTML("
      body {
        font-family: 'Inter', sans-serif;
        background-color: #f8f9fa; /* Light gray background */
        color: #333;
      }
      .container-fluid {
        padding-top: 20px;
        padding-bottom: 20px;
      }
      .panel {
        border-radius: 8px; /* Rounded corners */
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* Subtle shadow */
        background-color: #ffffff;
        padding: 20px;
        margin-bottom: 20px;
      }
      .well {
        border-radius: 8px;
        background-color: #e9ecef; /* Slightly darker background for panels */
        border: 1px solid #dee2e6;
      }
      h1, h2, h3, h4, h5, h6 {
        color: #212529;
      }
      .sidebar {
        background-color: #f0f2f5; /* Light sidebar background */
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
  ),
  titlePanel(h1("OSP Data Explorer (Demo)", style = "color: #007bff; text-align: center; margin-bottom: 30px;")),

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

# Define server logic
server <- function(input, output, session) {
  # Call the data loader module server
  # This returns a reactive expression holding the loaded data
  loaded_data_reactive <- mod_data_loader_server("data_input") # Use moduleServer implicitly

  # Call the visualization module server, passing the loaded data
  mod_visualization_server("data_plot", data = loaded_data_reactive) # Use moduleServer implicitly

  # Display raw data in a data table
  output$raw_data_table <- DT::renderDataTable({
    req(loaded_data_reactive()) # Ensure data is available
    DT::datatable(
      loaded_data_reactive(),
      options = list(pageLength = 10, scrollX = TRUE), # Enable horizontal scrolling
      filter = 'top', # Add column filters
      class = 'display compact'
    )
  })
}
# Run the application
shinyApp(ui = ui, server = server)
