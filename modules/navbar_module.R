# modules/navbar_module.R

navbar_ui <- function(id) {
  ns <- NS(id)

  tagList(
    # Info button activation script
    tags$script(HTML(sprintf("
      document.addEventListener('DOMContentLoaded', function() {
        var infoBtn = document.getElementById('%s');
        if (infoBtn) {
          infoBtn.addEventListener('click', function() {
            Shiny.setInputValue('%s', Math.random());
          });
        }
      });
    ", ns("info_btn"), ns("info_btn")))),

    # Navbar bar
    div(class = "flex items-center justify-between bg-gray-100 p-4 shadow",
        div(class = "text-3xl font-bold text-gray-800", "speX - species eXplorer"),
        div(class = "flex space-x-10",
            uiOutput(ns("nav_buttons")),
            tags$button(
              id = ns("info_btn"),
              class = "text-gray-600 hover:text-blue-600 text-3xl focus:outline-none",
              `aria-label` = "Info",
              HTML('<i class="fa-solid fa-circle-info"></i>')
            )
        )
    ),

    # Main UI area rendered based on selected tab
    div(class = "p-6", uiOutput(ns("main_ui")))
  )
}

navbar_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Tab definitions
    tabs <- c("tab1", "tab2", "tab3", "tab4")
    tab_labels <- c("Species on the Map", "Tab 2", "Tab 3", "Tab 4")

    current_tab <- reactiveVal(NULL)  # No tab selected initially

    # Observe tab button clicks
    lapply(tabs, function(tab) {
      observeEvent(input[[tab]], {
        current_tab(tab)
      })
    })

    # Render navigation buttons
    output$nav_buttons <- renderUI({
      lapply(seq_along(tabs), function(i) {
        tab <- tabs[i]
        label <- tab_labels[i]
        active <- if (current_tab() == tab) "active" else ""
        actionButton(
          inputId = ns(tab),
          label = label,
          class = paste("nav-btn", active)
        )
      })
    })

    # Show info modal
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

    # Render main UI
    output$main_ui <- renderUI({
      if (is.null(current_tab())) {
        # Landing page
        fluidRow(
          column(
            width = 12,
            h2("Welcome to speX"),
            p("Use the navigation tabs above to explore the species data.")
          )
        )
      } else if (current_tab() == "tab1") {
        map_ui(ns("map_mod"))
      } else {
        h2(paste("This is", current_tab()))
      }
    })

    # Launch the map module within the navbar module
    map_module_server("map_mod", data)
  })
}
