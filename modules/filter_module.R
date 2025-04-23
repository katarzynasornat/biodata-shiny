# ---- filter_module.R ----

filter_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    selectInput(ns("column_choice"), "Choose Column:",
                choices = c("", "scientificName", "vernacularName"), selected = "", selectize = TRUE),
    
    selectizeInput(ns("value_choice"), "Choose Value:",
                   choices = NULL,
                   selected = NULL,
                   options = list(placeholder = 'Start typing...', maxOptions = 500))
  )
}

filter_server <- function(id, data, unique_values_map) {
  moduleServer(id, function(input, output, session) {
    
    # Reactive for selected column
    selected_column <- reactive({
      req(input$column_choice)
      input$column_choice
    })
    
    # Dynamically update value choices when column changes
    observeEvent(input$column_choice, {
      req(input$column_choice)
      updateSelectizeInput(
        session,
        inputId = "value_choice",
        choices = unique_values_map[[input$column_choice]],
        selected = "",
        server = TRUE  # Efficient for large data
      )
    })
    
    # Reactive filtered data
    filtered_data <- reactive({
      req(input$column_choice, input$value_choice)
      data %>%
        filter(.data[[input$column_choice]] == input$value_choice)
    })
    
    # Return both for downstream use
    return(list(
      data = filtered_data,
      selected_column = selected_column
    ))
  })
}
