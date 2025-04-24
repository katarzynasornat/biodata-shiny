navbar_ui <- function(id) {
  ns <- NS(id)
  tags$div(class = "flex items-center justify-between bg-gray-100 p-4 shadow",
           tags$div(class = "text-3xl font-bold text-gray-400", "speX - species eXplorer"),
           tags$div(class = "flex items-center space-x-10",
                    tags$div(class = "flex space-x-20", uiOutput(ns("nav_buttons"))),
                    tags$button(
                      id = ns("info_btn"),
                      class = "text-gray-600 hover:text-blue-600 text-3xl focus:outline-none",
                      `aria-label` = "Info",
                      HTML('<i class="fa-solid fa-circle-info"></i>')
                    )
           )
  )
}

navbar_server <- function(id, current_tab, tab_names, tab_labels) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    observeEvent(input$info_btn, {
      showModal(modalDialog(
        title = HTML("<i class='fa-solid fa-circle-info text-blue-500'></i> How to Use This App"),
        HTML("<ul class='list-disc pl-5 space-y-2'>
              <li>Use the tabs in the navbar to navigate between different views.</li>
              <li>On <strong>Tab 1</strong>, select a column and a value to filter data points on the map.</li>
              <li>Hover over map markers to see the ID of each item.</li>
              <li>The map will update automatically based on your selection.</li>
             </ul>"),
        easyClose = TRUE,
        footer = modalButton("Close"),
        size = "m"
      ))
    })
    
    output$nav_buttons <- renderUI({
      lapply(seq_along(tab_names), function(i) {
        tab <- tab_names[i]
        label <- tab_labels[i]
        active <- if (current_tab() == tab) "active" else ""
        actionButton(ns(tab), label, class = paste("nav-btn", active))
      })
    })
  })
}