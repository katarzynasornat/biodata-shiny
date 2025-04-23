# options(shiny.autoreload = TRUE)
# 
# library(shiny)
# library(leaflet)
# library(dplyr)
# library(data.table)
# library(highcharter)

# options(shiny.host = "0.0.0.0")
# options(shiny.port = 8180)

source("globals.R")
source("modules/map_module.R")
source("modules/filter_module.R")
source("modules/timeline_module1.R")
source("modules/counterUp_module.R")

ui <- fluidPage(
  # Tailwind CSS
  tags$head(
    tags$link(
      rel = "stylesheet", 
      href = "https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css"
    ),
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"),
    tags$link(rel = "stylesheet", href = "styles.css"),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/countup.js/2.0.8/countUp.umd.js"),
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
")),
    tags$script(HTML("
  document.addEventListener('DOMContentLoaded', function() {
    var infoBtn = document.getElementById('info_btn');
    if (infoBtn) {
      infoBtn.addEventListener('click', function() {
        Shiny.setInputValue('info_btn', Math.random());
      });
    }
  });
"))
    
  ),
  
  # Navbar
  tags$div(class = "flex items-center justify-between bg-gray-100 p-4 shadow",
           tags$div(class = "text-3xl font-bold text-gray-400", "speX - species eXplorer"),
           tags$div(class = "flex items-center space-x-10",
                    tags$div(class = "flex space-x-20", uiOutput("nav_buttons")),  # Add spacing here
                    tags$button(
                      id = "info_btn",
                      class = "text-gray-600 hover:text-blue-600 text-3xl focus:outline-none",
                      `aria-label` = "Info",
                      HTML('<i class="fa-solid fa-circle-info"></i>')
                    )
           )
  ),
  
  tags$div(class = "p-6", uiOutput("main_ui")),
  
  # Footer
  tags$div(class = "border-t border-gray-300 mb-2 pt-4 px-6 flex justify-between text-gray-500 text-m",
           span(HTML("Created by <strong>SorKa</strong> with ❤️")),
           span("2025")
  )
)

server <- function(input, output, session) {
  tabs <- c("tab1", "tab2", "tab3", "tab4")
  tab_labels <- c("Species on the Map", "Tab 2", "Tab 3", "Tab 4")
  current_tab <- reactiveVal("tab1")
  
  observeEvent(input$tab1, current_tab("tab1"))
  observeEvent(input$tab2, current_tab("tab2"))
  observeEvent(input$tab3, current_tab("tab3"))
  observeEvent(input$tab4, current_tab("tab4"))
  
  observeEvent(input$info_btn, {
    showModal(modalDialog(
      title = HTML("<i class='fa-solid fa-circle-info text-blue-500'></i> How to Use This App"),
      HTML("
      <ul class='list-disc pl-5 space-y-2'>
        <li>Use the tabs in the navbar to navigate between different views.</li>
        <li>On <strong>Tab 1</strong>, select a column and a value to filter data points on the map.</li>
        <li>Hover over map markers to see the ID of each item.</li>
        <li>The map will update automatically based on your selection.</li>
      </ul>
    "),
      easyClose = TRUE,
      footer = modalButton("Close"),
      size = "m"
    ))
  })
  
  # Render navbar buttons dynamically with style
  output$nav_buttons <- renderUI({
    lapply(seq_along(tabs), function(i) {
      tab <- tabs[i]
      label <- tab_labels[i]
      active <- if (current_tab() == tab) "active" else ""
      actionButton(
        inputId = tab,
        label = label,
        class = paste("nav-btn", active)
      )
    })
  })
  
  # Track if user made a selection (first time only)
  user_selection <- reactiveValues(selected = FALSE)
  
  debounce(observe({
    req(input[["filter_mod-column_choice"]], input[["filter_mod-value_choice"]])
    
    isolate({
      if (!user_selection$selected &&
          input[["filter_mod-column_choice"]] != "" &&
          input[["filter_mod-value_choice"]] != "") {
        user_selection$selected <- TRUE
      }
    })
  }), millis = 500)
  
  # Main UI render logic
  
  output$main_ui <- renderUI({
    tagList(
      tags$div(class = "flex h-full",
               
               # Sidebar (always visible)
               tags$div(class = "w-1/4 p-6",
                        filter_ui("filter_mod")
               ),
               
               # Main panel changes depending on selection
               tags$div(class = "flex-1 p-6",
                        uiOutput("dynamic_main_ui") 
               )
      ),
      
      tags$div(class = "mt-10", timeline_ui("timeline_mod"))
    )
  })
  

  
  output$dynamic_main_ui <- renderUI({
    if (!user_selection$selected) {
      tags$div(class = "max-w-4xl mx-auto mt-10 px-6",
               tags$h1(class = "text-4xl font-bold text-center mb-6 text-gray-800", "speX Stats"),
               counter_ui("counter")
      )
    } else {
      tagList(
        map_ui("map_mod"),
        DT::dataTableOutput("summary_table")
      )
    }
  })
  
  # Call counterUp module using raw dataset for now
  counter_server("counter",
                 total = 2345,
                 unique = 123,
                 last = 14)
  
  # Call the map server module
  # Get filtered dataset from the module
  filter_result <- filter_server("filter_mod", data, unique_values_map)
  filtered_data <- filter_result$data
  selected_column <- filter_result$selected_column
  
  # Reactively update selection status
  observeEvent(input$filter_mod_column_choice, {
    if (!is.null(input$filter_mod_column_choice) && !is.null(input$filter_mod_value_choice)) {
      column_selected(TRUE)
      value_selected(TRUE)
    }
  })
  
  observeEvent(input$filter_mod_value_choice, {
    if (!is.null(input$filter_mod_column_choice) && !is.null(input$filter_mod_value_choice)) {
      column_selected(TRUE)
      value_selected(TRUE)
    }
  })
  
  # Stats - Display total observations and most/last observed species
  output$total_observations <- renderText({
    nrow(data)  # Replace with your actual data summary function
  })
  
  output$last_observed_species <- renderText({
    data %>% 
      arrange(desc(eventDate)) %>% 
      slice(1) %>%
      pull(scientificName)
  })
  
  output$most_observed_species <- renderText({
    data %>%
      count(scientificName) %>%
      arrange(desc(n)) %>%
      slice(1) %>%
      pull(scientificName)
  })
  
  # Map gets filtered data
  map_module_server("map_mod", filtered_data)
  timeline_server("timeline_mod", filtered_data)
  
  # Summary table
  output$summary_table <- DT::renderDataTable({
    req(filtered_data(), selected_column())
    summary_table <- filtered_data() %>%
      group_by(.data[[selected_column()]]) %>%
      summarise(Total = sum(individualCount))
    
    DT::datatable(summary_table, options = list(pageLength = 5, dom = 't'))
  })
  
}

shinyApp(ui, server)
