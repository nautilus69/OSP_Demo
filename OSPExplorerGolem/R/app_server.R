#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import DT
#' @import dplyr
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic starts here

  # Call the data loader module server
  # This returns a reactive expression holding the loaded data
  loaded_data_reactive <- mod_data_loader_server("data_input")

  # Call the visualization module server, passing the loaded data
  mod_visualization_server("data_plot", data = loaded_data_reactive)

  # Display raw data in a data table
  output$raw_data_table <- DT::renderDataTable({
    req(loaded_data_reactive()) # Ensure data is available
    DT::datatable(
      loaded_data_reactive(),
      options = list(
        pageLength = 10,
        scrollX = TRUE
      ), # Enable horizontal scrolling
      filter = 'top', # Add column filters
      class = 'display compact'
    )
  })
}
