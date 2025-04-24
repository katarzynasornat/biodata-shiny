# modules/filter_module.R

filter_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(
      class = "bg-blue-50 rounded-lg shadow-lg p-4 space-y-6 border border-blue-200",
      selectInput(ns("column_choice"), "Column", choices = choices_columns ),
      uiOutput(ns("value_choice"))
    )
  )
}

filter_server <- function(id, data, unique_values_map) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Dynamic select for values based on chosen column
    output$value_choice <- renderUI({
      selectizeInput(
        ns("value_choice"),
        "Value",
        choices = NULL,
        options = list(placeholder = "Select a column first")
      )
    })
    
    observeEvent(input$column_choice, {
      updateSelectizeInput(
        session,
        "value_choice",
        choices = unique_values_map[[input$column_choice]],
        server = TRUE
      )
    })
    
    # Reactive filtered data
    filtered_data <- reactive({
      req(input$column_choice, input$value_choice)
      #data %>% filter(.data[[input$column_choice]] == input$value_choice)
      
      result_azure <- get_dataset_for_duckdb(
        scientificName_value = input$value_choice,
        group_by_columns = c(input$column_choice, "eventDate", "latitudeDecimal", "longitudeDecimal")
        # azure_container_url = azure_url,
        # sas_token = sas_token
      )
      
      result_azure$data
      
    })
    
    head(filtered_data)
    
    return(list(
      data = filtered_data,
      selected_column = reactive(input$column_choice)
    ))
  })
}