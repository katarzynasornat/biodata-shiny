# Map Module UI
map_ui <- function(id) {
  ns <- NS(id)
  
  fluidRow(
    column(
      width = 6,
      # Select column
      selectInput(ns("column_choice"), "Column", choices = c("scientificName", "vernacularName")),
      # Select value dynamically
      uiOutput(ns("value_choice")),
      # Map output
      leafletOutput(ns("map"), height = 500),
      # Summary table output
      DT::dataTableOutput(ns("summary_table"))
    )
  )
}


# Map Module Server
# map_module_server.R

map_module_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    filtered_data <- reactive({
      req(input$column_choice, input$value_choice)
      data %>%
        filter(.data[[input$column_choice]] == input$value_choice)
    })
    
    # Render empty selectizeInput using renderUI
    output$value_choice <- renderUI({
      selectizeInput(
        ns("value_choice"),
        "Value",
        choices = NULL,
        options = list(placeholder = "Select a column first")
      )
    })
    
    # Dynamically update selectizeInput with server-side option
    observeEvent(input$column_choice, {
      req(input$column_choice)
      
      updateSelectizeInput(
        session = session,
        inputId = "value_choice",
        choices = unique(data[[input$column_choice]]),
        server = TRUE
      )
    })
    
    # Render filtered map
    output$map <- renderLeaflet({
      req(filtered_data())
      leaflet(filtered_data()) %>%
        addTiles() %>%
        addCircleMarkers(
          lng = ~longitudeDecimal, lat = ~latitudeDecimal,
          radius = 5,
          color = "blue",
          stroke = FALSE,
          fillOpacity = 0.7,
          label = ~paste("ID:", id)
        )
    })
    output$summary_table <- DT::renderDataTable({
      req(filtered_data())
      
      # Create a summary table with count of occurrences
      summary_table <- filtered_data() %>%
        group_by(.data[[input$column_choice]]) %>%
        summarise(Count = n()) %>%
        arrange(desc(Count))
      
      # Render as DataTable
      DT::datatable(summary_table, options = list(pageLength = 5, dom = 't'))
    })
  })
}
