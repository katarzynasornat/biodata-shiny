# modules/timeline_module.R

timeline_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$head(
      tags$style(HTML("
      .chart-title-container {
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.25rem;
        font-weight: 600;
        color: #374151; /* Tailwind slate-700 */
        margin-bottom: 1rem;
      }

      .chart-title-container span {
        font-size: 1.25rem;
        font-weight: 600;
        color: #374151;
      }

      .inline-dropdown {
        background: transparent;
        border: none;
        font-weight: 600;
        color: #3b82f6; /* Tailwind blue-500 */
        font-size: 1.25rem;
        padding-left: 5px;
        padding-right: 5px;
        -webkit-appearance: none;
        -moz-appearance: none;
        appearance: none;
        margin-left: 5px; /* Add space between title and dropdown */
        height: 35px; /* Align the dropdown height with the title */
      }

      .inline-dropdown:focus {
        outline: none;
        text-decoration: underline;
      }
    "))
    ),
    # tags$div(class = "chart-title-container",
    #          span("Observations over"),
    #          div(class = "inline-dropdown",
    #              selectInput(ns("granularity"), NULL, choices = c("day", "month", "year"), selected = "day", 
    #                          width = "auto", selectize = FALSE)
    #          )
    # ),
    
    uiOutput(ns("chart_title_ui")),
    highchartOutput(ns("timeline_chart"), height = "400px")
      #DT::DTOutput(ns("highchart_table"))
    )
}

timeline_server <- function(id, filtered_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Only render title if filtered_data is available
    output$chart_title_ui <- renderUI({
      req(filtered_data())
      tags$div(class = "chart-title-container",
               span("Observations over"),
               div(class = "inline-dropdown",
                   selectInput(ns("granularity"), NULL,
                               choices = c("day", "month", "year"),
                               selected = "day",
                               width = "auto", selectize = FALSE)
               )
      )
    })
    
    aggregated_data <- reactive({
      req(input$granularity, filtered_data())
      
      df <- filtered_data()
      
      if (!"eventDate" %in% names(df)) return(NULL)
      if (!"individualCount" %in% names(df)) return(NULL)
      
      df <- df %>%
        mutate(
          date = as.Date(eventDate),
          period = case_when(
            input$granularity == "day" ~ date,
            input$granularity == "month" ~ lubridate::floor_date(date, "month"),
            input$granularity == "year" ~ lubridate::floor_date(date, "year")
          )
        )
      
      df %>%
        group_by(period) %>%
        summarise(total = sum(individualCount, na.rm = TRUE), .groups = "drop")
    })
    
    
    output$timeline_chart <- renderHighchart({
      hc_data <- aggregated_data()

      highchart() %>%
        hc_chart(type = "line") %>%
        hc_title(text = "") %>%  # Empty because we styled title above
        hc_xAxis(type = "datetime") %>%
        hc_add_series(
          name = "Observations",
          data = list_parse2(hc_data %>%
                               mutate(period = datetime_to_timestamp(period)) %>%
                               select(period, total)),
          type = "areaspline",
          color = "#60A5FA",
          fillOpacity = 0.4
        ) %>%
        hc_tooltip(shared = TRUE, xDateFormat = "%b %d, %Y", valueSuffix = " obs") %>%
        hc_credits(enabled = FALSE)
    })
    })
    
  

  #   output$highchart_table <- DT::renderDataTable({
  #     
  #     req(filtered_data())
  #     
  #     df <- filtered_data()
  #     
  #     if (!"eventDate" %in% names(df)) return(NULL)
  #     df$date <- as.Date(df$eventDate, format = "%Y-%m-%d")
  #     
  #     timeline_data <- df %>%
  #       group_by(date) %>%
  #       summarise(total = sum(individualCount))
  #     
  #     print("Timeline server triggered")
  #     
  #     DT::datatable(timeline_data, options = list(pageLength = 5, dom = 't'))
  # })
}
