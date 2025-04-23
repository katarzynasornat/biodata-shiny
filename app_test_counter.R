# # # app.R
# # 
# # library(shiny)
# # 
# # source("modules/counterUp_module.R")
# # 
# # ui <- fluidPage(
# #   tags$head(
# #     tags$link(
# #       rel = "stylesheet",
# #       href = "https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css"
# #     ),
# #     tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/countup.js/2.0.8/countUp.umd.js"),
# #     tags$script(HTML("
# #   Shiny.addCustomMessageHandler('startCounters', function(message) {
# #     const opts = { duration: 1, separator: ',' };
# #     const obs = new countUp.CountUp(message.ns + 'count-observations', message.total, opts);
# #     const species = new countUp.CountUp(message.ns + 'count-species', message.unique, opts);
# #     const last = new countUp.CountUp(message.ns + 'count-lastdate', message.last, opts);
# # 
# #     if (!obs.error) obs.start(); else console.error(obs.error);
# #     if (!species.error) species.start(); else console.error(species.error);
# #     if (!last.error) last.start(); else console.error(last.error);
# #   });
# # "))
# #   ),
# # 
# #   tags$div(class = "max-w-4xl mx-auto mt-10 px-6",
# #            tags$h1(class = "text-4xl font-bold text-center mb-6 text-gray-800", "speX Stats"),
# #            uiOutput("counter_ui")
# #   )
# # )
# # 
# # server <- function(input, output, session) {
# #   # Dynamically render the UI
# #   output$counter_ui <- renderUI({
# #     counter_ui("counter")
# #   })
# # 
# #   # Initialize the server logic for the module
# #   counter_server("counter",
# #                  total = 2345,
# #                  unique = 123,
# #                  last = 14)
# # }
# # 
# # shinyApp(ui, server)
# 
# 
# 
# library(shiny)
# 
# source("modules/counterUp_module.R")  # Your original module with head script removed
# 
# ui <- fluidPage(
#   tags$head(
#     tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css"),
#     tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/countup.js/2.0.8/countUp.umd.js"),
# 
#     # HANDLER REGISTERED AT TOP-LEVEL
#     tags$script(HTML("
#       Shiny.addCustomMessageHandler('startCounters', function(message) {
#         const opts = { duration: 1, separator: ',' };
#         const obs = new countUp.CountUp(message.ns + 'count-observations', message.total, opts);
#         const species = new countUp.CountUp(message.ns + 'count-species', message.unique, opts);
#         const last = new countUp.CountUp(message.ns + 'count-lastdate', message.last, opts);
# 
#         if (!obs.error) obs.start(); else console.error(obs.error);
#         if (!species.error) species.start(); else console.error(species.error);
#         if (!last.error) last.start(); else console.error(last.error);
#       });
#     "))
#   ),
# 
#   uiOutput("inner_ui")
# )
# 
# server <- function(input, output, session) {
# 
#   # NEST 1: outer_ui -> middle_ui
#   # output$outer_ui <- renderUI({
#   #   tagList(
#   #     tags$h1(class = "text-center text-4xl my-8", "Double-Nested CountUp Test"),
#   #     uiOutput("middle_ui")
#   #   )
#   # })
# 
#   # NEST 2: middle_ui -> inner_ui
#   output$counter_ui <- renderUI({
#     uiOutput("inner_ui")
#   })
# 
#   # NEST 3: inner_ui renders the actual counter module
#   output$inner_ui <- renderUI({
#     counter_ui("counter")
#   })
# 
#   # Server call
#   counter_server("counter",
#                  total = 5678,
#                  unique = 234,
#                  last = 21)
# }
# 
# shinyApp(ui, server)


library(shiny)
source("modules/counterUp1_module.R")  # Your original module with head script removed

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css"),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/countup.js/2.0.8/countUp.umd.js"),
    
    # Register the handler at the global level
    tags$script(HTML("
      Shiny.addCustomMessageHandler('startCounters', function(message) {
        const opts = { duration: 1, separator: ',' };
        const obs = new countUp.CountUp(message.ns + 'count-observations', message.total, opts);
        const species = new countUp.CountUp(message.ns + 'count-species', message.unique, opts);
        const last = new countUp.CountUp(message.ns + 'count-lastdate', message.last, opts);
        
        if (!obs.error) obs.start(); else console.error(obs.error);
        if (!species.error) species.start(); else console.error(species.error);
        if (!last.error) last.start(); else console.error(last.error);
      });
    "))
  ),
  
  # Outer UI which will trigger nested UIs
  uiOutput("outer_ui")
)

server <- function(input, output, session) {
  
  # Outer UI level
  output$outer_ui <- renderUI({
    tagList(
      tags$div(class = "max-w-3xl mx-auto my-12",
               tags$h1(class = "text-center text-4xl font-bold text-gray-800 mb-6", "Triple-Nested CountUp Example"),
               uiOutput("middle_ui")  # Render middle UI next
      )
    )
  })
  
  # Middle UI level
  output$middle_ui <- renderUI({
    uiOutput("inner_ui")  # Finally render the innermost UI with the counter
  })
  
  # Inner UI level, where we call the counter UI
  output$inner_ui <- renderUI({
    counter_ui("counter")
  })
  
  # Initialize counter module with values
  counter_server("counter", total = 5678, unique = 234, last = 21)
}

shinyApp(ui, server)
