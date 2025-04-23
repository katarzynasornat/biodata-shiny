# modules/filter_module.R

filter_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(
      class = "bg-blue-50 rounded-lg shadow-lg p-4 space-y-6 border border-blue-200",
      selectInput(ns("column_choice"), "Column", choices = c("scientificName", "vernacularName")),
      uiOutput(ns("value_choice"))
    )
  )
}

filter_server <- function(id, data) {
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
        choices = unique(data[[input$column_choice]]),
        server = TRUE
      )
    })
    
    # Reactive filtered data
    filtered_data <- reactive({
      req(input$column_choice, input$value_choice)
      data %>% filter(.data[[input$column_choice]] == input$value_choice)
    })
    
    return(list(
      data = filtered_data,
      selected_column = reactive(input$column_choice)
    ))
  })
}
