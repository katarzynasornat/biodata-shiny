library(shiny)

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css"),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/countup.js/2.0.8/countUp.umd.js"),
    tags$script(HTML("
      Shiny.addCustomMessageHandler('startCounters', function(message) {
        const opts = { duration: 1, separator: ',' };
        const obs = new countUp.CountUp('count-observations', message.total, opts);
        const species = new countUp.CountUp('count-species', message.unique, opts);
        const last = new countUp.CountUp('count-lastdate', message.last, opts);

        if (!obs.error) obs.start(); else console.error(obs.error);
        if (!species.error) species.start(); else console.error(species.error);
        if (!last.error) last.start(); else console.error(last.error);
      });"
    ))
  ),
  
  tags$div(class = "max-w-4xl mx-auto mt-10 px-6",
           tags$h1(class = "text-4xl font-bold text-center mb-6 text-gray-800", "speX Stats"),
           
           tags$div(class = "grid grid-cols-1 sm:grid-cols-3 gap-6 text-center",
                    tags$div(class = "bg-blue-100 p-6 rounded-lg shadow",
                             tags$div(class = "text-3xl font-bold text-blue-800", tags$span(id = "count-observations", "0")),
                             tags$div(class = "text-blue-600 mt-1", "Total Observations")
                    ),
                    tags$div(class = "bg-green-100 p-6 rounded-lg shadow",
                             tags$div(class = "text-3xl font-bold text-green-800", tags$span(id = "count-species", "0")),
                             tags$div(class = "text-green-600 mt-1", "Unique Species")
                    ),
                    tags$div(class = "bg-purple-100 p-6 rounded-lg shadow",
                             tags$div(class = "text-3xl font-bold text-purple-800", tags$span(id = "count-lastdate", "0")),
                             tags$div(class = "text-purple-600 mt-1", "Days Since Last Observation")
                    )
           )
  )
)

server <- function(input, output, session) {
  total <- 2345
  unique <- 123
  last <- 14
  
  session$onFlushed(function() {
    session$sendCustomMessage("startCounters", list(
      total = total,
      unique = unique,
      last = last
    ))
  }, once = TRUE)
}

shinyApp(ui, server)
