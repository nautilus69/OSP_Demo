# OSPExplorerApp/R/mod_data_loader.R

mod_data_loader_ui <- function(id){
  ns <- NS(id)
  tagList(
    h4("Data Input Options"),
    actionButton(ns("load_mock_data"), "Load Mock OSP Data (Demo)", class = "btn-primary mb-3"),
    tags$hr(), # Horizontal rule for separation
    fileInput(ns("upload_file"), "Upload OSP Data (CSV/Excel)",
              accept = c(".csv", ".xlsx"),
              buttonLabel = "Browse...",
              placeholder = "No file selected",
              multiple = FALSE), # Only one file at a time
    uiOutput(ns("upload_message")) # To display upload status
  )
}

mod_data_loader_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Reactive value to store the loaded data
    data_rv <- reactiveVal(NULL)
    output$upload_message <- renderUI(NULL) # Initialize message
    
    # Event for loading mock data
    observeEvent(input$load_mock_data, {
      # Use the function from our ospapputils package
      data_rv(ospapputils::load_osp_data())
      output$upload_message <- renderUI({
        tags$div(class = "alert alert-success", role = "alert", "Mock data loaded!")
      })
    })
    
    # Event for file upload
    observeEvent(input$upload_file, {
      file_ext <- tools::file_ext(input$upload_file$name)
      if (file_ext == "csv") {
        tryCatch({
          data_rv(readr::read_csv(input$upload_file$datapath))
          output$upload_message <- renderUI({
            tags$div(class = "alert alert-success", role = "alert", paste0("Uploaded CSV: ", input$upload_file$name))
          })
        }, error = function(e) {
          output$upload_message <- renderUI({
            tags$div(class = "alert alert-danger", role = "alert", paste0("Error reading CSV file: ", e$message))
          })
          data_rv(NULL) # Clear data on error
        })
      } else if (file_ext == "xlsx") {
        # Requires 'readxl' package. Ensure it's in ospapputils Suggests and mentioned to user.
        if (!requireNamespace("readxl", quietly = TRUE)) {
          output$upload_message <- renderUI({
            tags$div(class = "alert alert-danger", role = "alert", "Package 'readxl' is required for .xlsx files. Please install it.")
          })
          data_rv(NULL)
          return()
        }
        tryCatch({
          data_rv(readxl::read_excel(input$upload_file$datapath))
          output$upload_message <- renderUI({
            tags$div(class = "alert alert-success", role = "alert", paste0("Uploaded Excel: ", input$upload_file$name))
          })
        }, error = function(e) {
          output$upload_message <- renderUI({
            tags$div(class = "alert alert-danger", role = "alert", paste0("Error reading Excel file: ", e$message))
          })
          data_rv(NULL) # Clear data on error
        })
      } else {
        output$upload_message <- renderUI({
          tags$div(class = "alert alert-warning", role = "alert", "Unsupported file type. Please upload CSV or XLSX.")
        })
        data_rv(NULL)
      }
    })
    
    # Return the reactive data for other modules
    return(data_rv)
  })
}