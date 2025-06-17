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
    # Initialize message output to NULL, wrapped in renderUI
    output$upload_message <- renderUI({ NULL })

    # Event for loading mock data
    observeEvent(input$load_mock_data, {
      # Use the function from our ospapputils package
      data <- ospapputils::load_osp_data()
      # Validate mock data (optional, but good for consistency)
      validation_result <- ospapputils::validate_osp_data(data)

      if (isTRUE(validation_result)) {
        data_rv(data)
        output$upload_message <- renderUI({
          tags$div(class = "alert alert-success", role = "alert", "Mock data loaded and validated successfully!")
        })
      } else {
        output$upload_message <- renderUI({
          tags$div(class = "alert alert-danger", role = "alert",
                   tags$b("Validation failed for mock data:"),
                   tags$ul(lapply(validation_result, tags$li)))
        })
        data_rv(NULL) # Clear data on validation error
      }
    })

    # Event for file upload
    observeEvent(input$upload_file, {
      req(input$upload_file) # Ensure a file is actually uploaded

      file_ext <- tools::file_ext(input$upload_file$name)
      uploaded_df <- NULL
      error_message <- NULL

      # Determine reader function and handle potential read errors
      if (file_ext == "csv") {
        uploaded_df <- tryCatch(
          readr::read_csv(input$upload_file$datapath, show_col_types = FALSE), # show_col_types = FALSE to suppress console messages
          error = function(e) { error_message <<- paste0("Error reading CSV file: ", e$message); NULL }
        )
      } else if (file_ext == "xlsx") {
        if (!requireNamespace("readxl", quietly = TRUE)) {
          error_message <- "Package 'readxl' is required for .xlsx files. Please install it."
        } else {
          uploaded_df <- tryCatch(
            readxl::read_excel(input$upload_file$datapath),
            error = function(e) { error_message <<- paste0("Error reading Excel file: ", e$message); NULL }
          )
        }
      } else {
        error_message <- "Unsupported file type. Please upload CSV or XLSX."
      }

      # If there was an error during file reading, display it and stop
      if (!is.null(error_message)) {
        output$upload_message <- renderUI({
          tags$div(class = "alert alert-danger", role = "alert", error_message)
        })
        data_rv(NULL) # Clear data on reading error
        return()
      }

      # If file was read but is empty or somehow failed to produce a data frame
      if (is.null(uploaded_df) || nrow(uploaded_df) == 0) {
        output$upload_message <- renderUI({
          tags$div(class = "alert alert-danger", role = "alert", "Failed to load data or the file is empty. Please check file content.")
        })
        data_rv(NULL) # Clear data
        return()
      }

      # Perform validation using ospapputils function
      validation_result <- ospapputils::validate_osp_data(uploaded_df)

      if (isTRUE(validation_result)) {
        data_rv(uploaded_df)
        output$upload_message <- renderUI({
          tags$div(class = "alert alert-success", role = "alert", paste0("Uploaded and validated: ", input$upload_file$name))
        })
      } else {
        output$upload_message <- renderUI({
          tags$div(class = "alert alert-danger", role = "alert",
                   tags$b(paste0("Validation failed for ", input$upload_file$name, ":")),
                   tags$ul(lapply(validation_result, tags$li)))
        })
        data_rv(NULL) # Clear data on validation error
      }
    })

    # Return the reactive data for other modules
    return(data_rv)
  })
}
