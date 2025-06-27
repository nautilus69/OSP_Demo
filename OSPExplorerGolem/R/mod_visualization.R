#' Visualization UI Module
#'
#' @param id Internal parameter for {shiny}.
#' @return A UI definition for the visualization module.
#' @importFrom shiny NS tagList sidebarLayout sidebarPanel mainPanel h4 h5 checkboxGroupInput checkboxInput tags uiOutput selectInput
#' @importFrom ggplot2 theme
#' @importFrom plotly plotlyOutput renderPlotly ggplotly config
mod_visualization_ui <- function(id) {
  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(
        h4("Plot Controls"),
        uiOutput(ns("study_select_ui")),   # Dynamic UI for Study selection
        uiOutput(ns("group_select_ui")),   # Dynamic UI for Group selection
        checkboxGroupInput(
          ns("data_type_filter"), "Data Type:",
          choices = c("Observed", "Simulated"),
          selected = c("Observed", "Simulated")
        ),
        tags$hr(),
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

#' Visualization Server Module
#'
#' @param id Internal parameter for {shiny}.
#' @param data A reactive data frame to use for plotting.
#' @importFrom shiny moduleServer reactive req renderUI renderPlotly
#' @importFrom dplyr filter %>%
#' @importFrom ggplot2 ggplot aes geom_line geom_point facet_wrap labs theme_minimal element_text margin element_blank element_line element_rect scale_color_manual scale_y_log10
#' @importFrom plotly ggplotly config
mod_visualization_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Update dynamic UI inputs based on incoming data
    observeEvent(data(), {
      req(data())

      if (!("StudyID" %in% names(data()))) return()
      output$study_select_ui <- renderUI({
        selectInput(
          ns("select_study"), "Select Study(s):",
          choices = unique(data()$StudyID),
          selected = unique(data()$StudyID),
          multiple = TRUE
        )
      })

      if (!("Group" %in% names(data()))) return()
      output$group_select_ui <- renderUI({
        selectInput(
          ns("select_group"), "Select Group(s):",
          choices = unique(data()$Group),
          selected = unique(data()$Group),
          multiple = TRUE
        )
      })
    })

    # Reactive filter based on UI
    filtered_data <- reactive({
      req(data())

      df <- data()
      # Guard clauses for required columns
      if (!all(c("StudyID", "Group", "DataType") %in% names(df))) return(NULL)

      req(input$select_study, input$select_group, input$data_type_filter)

      df %>%
        filter(
          StudyID %in% input$select_study,
          Group %in% input$select_group,
          DataType %in% input$data_type_filter
        )
    })

    # Render Plotly plot
    output$concentration_plot <- renderPlotly({
      df <- filtered_data()
      req(df)

      # Basic plot setup
      p <- ggplot(df, aes(x = Time, y = Concentration, color = DataType))

      if (input$show_lines) {
        p <- p + geom_line(size = 1)
      }
      if (input$show_points) {
        p <- p + geom_point(aes(shape = DataType), size = 3, alpha = 0.8)
      }

      # Defensive unit extraction
      time_unit <- if ("Units" %in% names(df)) unique(df$Units)[1] else "Time Unit"
      conc_unit <- if ("Units" %in% names(df)) unique(df$Units)[1] else "Concentration Unit"

      p <- p +
        facet_wrap(~ StudyID + Group, scales = "free_y", ncol = 2) +
        labs(
          title = "PBPK/QSP Concentration-Time Profile",
          x = paste0("Time (", time_unit, ")"),
          y = paste0("Concentration (", conc_unit, ")"),
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

      ggplotly(p) %>%
        config(displayModeBar = FALSE)
    })
  })
}
