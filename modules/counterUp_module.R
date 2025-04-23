# modules/counter_module.R
counter_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$head(
      tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/countup.js/2.0.8/countUp.umd.js"),
      tags$script(HTML(
        paste0(
          "Shiny.addCustomMessageHandler('", ns("startCounters"), "', function(message) {",
          "const opts = { duration: 1, separator: ',' };",
          "const obs = new countUp.CountUp('", ns("count-observations"), "', message.total, opts);",
          "const species = new countUp.CountUp('", ns("count-species"), "', message.unique, opts);",
          "const last = new countUp.CountUp('", ns("count-lastdate"), "', message.last, opts);",
          "if (!obs.error) obs.start(); else console.error(obs.error);",
          "if (!species.error) species.start(); else console.error(species.error);",
          "if (!last.error) last.start(); else console.error(last.error);",
          "});"
        )
      ))
    ),
    tags$div(class = "grid grid-cols-1 sm:grid-cols-3 gap-6 text-center",
             tags$div(class = "bg-blue-100 p-6 rounded-lg shadow",
                      tags$div(class = "text-3xl font-bold text-blue-800", tags$span(id = ns("count-observations"), "0")),
                      tags$div(class = "text-blue-600 mt-1", "Total Observations")
             ),
             tags$div(class = "bg-green-100 p-6 rounded-lg shadow",
                      tags$div(class = "text-3xl font-bold text-green-800", tags$span(id = ns("count-species"), "0")),
                      tags$div(class = "text-green-600 mt-1", "Unique Species")
             ),
             tags$div(class = "bg-purple-100 p-6 rounded-lg shadow",
                      tags$div(class = "text-3xl font-bold text-purple-800", tags$span(id = ns("count-lastdate"), "0")),
                      tags$div(class = "text-purple-600 mt-1", "Days Since Last Observation")
             )
    )
  )
}

counter_server <- function(id, total, unique, last) {
  moduleServer(id, function(input, output, session) {
    session$onFlushed(function() {
      session$sendCustomMessage(paste0(session$ns("startCounters")), list(
        total = total,
        unique = unique,
        last = last
      ))
    }, once = TRUE)
  })
}
