library(shiny)
library(highcharter)
library(dplyr)
library(lubridate)
library(data.table)

# Sample data
set.seed(123)
df <- fread("./data/occurence_PL.csv")
df$date <- as.Date(df$eventDate, format = "%Y-%m-%d")

ui <- fluidPage(
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
  
  div(class = "chart-title-container",
      span("Observations over"),
      div(class = "inline-dropdown",
          selectInput("granularity", NULL, choices = c("day", "month", "year"), selected = "day", 
                      width = "auto", selectize = FALSE)
      )
  ),
  
  highchartOutput("timeline_chart", height = "400px")
)

server <- function(input, output, session) {
  
  aggregated_data <- reactive({
    req(input$granularity)
    df %>%
      mutate(period = case_when(
        input$granularity == "day" ~ date,
        input$granularity == "month" ~ floor_date(date, "month"),
        input$granularity == "year" ~ floor_date(date, "year")
      )) %>%
      group_by(period) %>%
      summarise(total = sum(individualCount), .groups = "drop")
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
}

shinyApp(ui, server)
