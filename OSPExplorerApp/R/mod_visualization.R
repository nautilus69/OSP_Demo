# OSPExplorerApp/R/mod_visualization.R

mod_visualization_ui <- function(id){
  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(
        h4("Plot Controls"),
        uiOutput(ns("study_select_ui")), # Dynamic UI for Study selection
        uiOutput(ns("group_select_ui")), # Dynamic UI for Group selection
        checkboxGroupInput(ns("data_type_filter"), "Data Type:",
                           choices = c("Observed", "Simulated"),
                           selected = c("Observed", "Simulated")),
        tags$hr(), # Add a separator for the new controls
        h5("Plot Display Options"),
        checkboxInput(ns("log_scale_y"), "Log Scale Y-axis", value = FALSE),
        checkboxInput(ns("show_points"), "Show Points", value = TRUE),
        checkboxInput(ns("show_lines"), "Show Lines", value = TRUE)
      ),
      mainPanel(
        plotlyOutput(ns("concentration_plot"), height = "500px")
      )
    )
  )
}


mod_visualization_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {

    # Update select input choices dynamically based on loaded data
    observeEvent(data(), {
      req(data())
      # Update StudyID selector
      output$study_select_ui <- renderUI({
        selectInput(session$ns("select_study"), "Select Study(s):",
                    choices = unique(data()$StudyID),
                    selected = unique(data()$StudyID),
                    multiple = TRUE)
      })
      # Update Group selector
      output$group_select_ui <- renderUI({
        selectInput(session$ns("select_group"), "Select Group(s):",
                    choices = unique(data()$Group),
                    selected = unique(data()$Group),
                    multiple = TRUE)
      })
    })

    # Filter data for plotting based on user selections
    filtered_data <- reactive({
      req(data(), input$select_study, input$select_group, input$data_type_filter)

      # Ensure inputs are not NULL after initial rendering but before choices are populated
      if (is.null(input$select_study) || is.null(input$select_group) || is.null(input$data_type_filter)) {
        return(NULL)
      }

      data() %>%
        filter(StudyID %in% input$select_study,
               Group %in% input$select_group,
               DataType %in% input$data_type_filter)
    })

    # Render the concentration-time plot
    output$concentration_plot <- renderPlotly({
      req(filtered_data())

      p <- ggplot(filtered_data(), aes(x = Time, y = Concentration, color = DataType))

      if (input$show_lines) {
        p <- p + geom_line(size = 1)
      }
      if (input$show_points) {
        p <- p + geom_point(aes(shape = DataType), size = 3, alpha = 0.8)
      }

      p <- p +
        facet_wrap(~ StudyID + Group, scales = "free_y", ncol = 2) +
        labs(
          title = "PBPK/QSP Concentration-Time Profile",
          x = paste0("Time (", unique(filtered_data()$Units)[1], ")"),
          y = paste0("Concentration (", unique(filtered_data()$Units[grep("Concentration", colnames(filtered_data()))])[1], ")"),
          color = "Data Type",
          shape = "Data Type"
        ) +
        theme_minimal(base_size = 11) +
        theme(
          plot.title = element_text(hjust = 0.5, face = "bold", margin = margin(b = 25)),
          axis.title = element_text(face = "bold"),
          legend.position = "bottom",
          legend.title = element_text(face = "bold"),
          panel.grid.major = element_line(color = "#e0e0e0", linetype = "dotted"),
          panel.grid.minor = element_blank(),
          strip.background = element_rect(fill = "#e9ecef", color = NA),
          strip.text = element_text(face = "bold", color = "#343a40")
        ) +
        scale_color_manual(values = c("Observed" = "#007bff", "Simulated" = "#28a745"))

      if (input$log_scale_y) {
        p <- p + scale_y_log10()
      }

      plotly::ggplotly(p) %>%
        plotly::config(displayModeBar = FALSE) # Hide plotly mode bar for cleaner look
    })
  })
}
