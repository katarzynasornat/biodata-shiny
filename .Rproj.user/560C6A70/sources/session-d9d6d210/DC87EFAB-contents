# map_ui <- function(id) {
#   ns <- NS(id)
#   
#   # Outer container
#   tags$div(class = "flex h-full",
#            
#            tags$div(class = "w-1/4 p-6",
#                     
#                     tags$div(
#                       class = "bg-blue-50 rounded-lg shadow-lg p-4 space-y-6 border border-blue-200",
#                       
#                       selectInput(ns("column_choice"), "Column", choices = c("scientificName", "vernacularName")),
#                       uiOutput(ns("value_choice")),
#                       DT::dataTableOutput(ns("summary_table"))
#                     )
#            ),
#            
#            # Right panel with map
#            tags$div(class = "w-1/2 p-4",
#                     leafletOutput(ns("map"), height = "500px")
#            )
#   )
# }
# 
# 
# 
# 
# # Map Module Server
# # map_module_server.R
# 
# map_module_server <- function(id, data) {
#   moduleServer(id, function(input, output, session) {
#     ns <- session$ns
#     
#     filtered_data <- reactive({
#       req(input$column_choice, input$value_choice)
#       data %>%
#         filter(.data[[input$column_choice]] == input$value_choice)
#     })
#     
#     # Render empty selectizeInput using renderUI
#     output$value_choice <- renderUI({
#       selectizeInput(
#         ns("value_choice"),
#         "Value",
#         choices = NULL,
#         options = list(placeholder = "Select a column first")
#       )
#     })
#     
#     # Dynamically update selectizeInput with server-side option
#     observeEvent(input$column_choice, {
#       req(input$column_choice)
#       
#       updateSelectizeInput(
#         session = session,
#         inputId = "value_choice",
#         choices = unique(data[[input$column_choice]]),
#         server = TRUE
#       )
#     })
#     
#     # Render filtered map
#     output$map <- renderLeaflet({
#       req(filtered_data())
#       leaflet(filtered_data()) %>%
#         addTiles() %>%
#         addCircleMarkers(
#           lng = ~longitudeDecimal, lat = ~latitudeDecimal,
#           radius = 5,
#           color = "blue",
#           stroke = FALSE,
#           fillOpacity = 0.7,
#           label = ~paste("ID:", id)
#         )
#     })
#     output$summary_table <- DT::renderDataTable({
#       req(filtered_data())
#       
#       # Create a summary table with count of occurrences
#       summary_table <- filtered_data() %>%
#         group_by(.data[[input$column_choice]]) %>%
#         summarise(Count = n()) %>%
#         arrange(desc(Count))
#       
#       # Render as DataTable
#       DT::datatable(summary_table, options = list(pageLength = 5, dom = 't'))
#     })
#   })
# }


# modules/map_module.R

map_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(class = "w-1/2 p-4",
             leafletOutput(ns("map"), height = "500px"))
  )
}

map_module_server <- function(id, filtered_data) {
  moduleServer(id, function(input, output, session) {
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
  })
}
