counter_ui <- function(id) {
  ns <- NS(id)

  tagList(
    tags$div(class = "grid grid-cols-1 sm:grid-cols-3 gap-6 text-center",
             tags$div(class = "bg-blue-100 p-6 rounded-lg shadow",
                      tags$div(class = "text-3xl font-bold text-blue-800",
                               tags$span(id = ns("count-observations"), "0")),
                      tags$div(class = "text-blue-600 mt-1", "Total Observations")
             ),
             tags$div(class = "bg-green-100 p-6 rounded-lg shadow",
                      tags$div(class = "text-3xl font-bold text-green-800",
                               tags$span(id = ns("count-species"), "0")),
                      tags$div(class = "text-green-600 mt-1", "Unique Species")
             ),
             tags$div(class = "bg-purple-100 p-6 rounded-lg shadow",
                      tags$div(class = "text-3xl font-bold text-purple-800",
                               tags$span(id = ns("count-lastdate"), "0")),
                      tags$div(class = "text-purple-600 mt-1", "Days Since Last Observation")
             )
    )
  )
}

# counter_server <- function(id, total, unique, last) {
#   moduleServer(id, function(input, output, session) {
#     # Send message after a small delay to ensure UI is present
#     observe({
#       invalidateLater(500, session)
#       session$sendCustomMessage("startCounters", list(
#         ns = session$ns(""),
#         total = total,
#         unique = unique,
#         last = last
#       ))
#     })
#   })
# }

counter_server <- function(id, total, unique, last) {
  moduleServer(id, function(input, output, session) {
    # This only fires once, after the UI is fully flushed into the DOM
    session$onFlushed(function() {
      later::later(function() {
        session$sendCustomMessage("startCounters", list(
          ns = session$ns(""),
          total = total,
          unique = unique,
          last = last
        ))
      }, delay = 0.3)
    }, once = TRUE)
    
  })
}

