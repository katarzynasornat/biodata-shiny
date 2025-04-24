# # modules/geolocation_module.R
# library(shiny)
# library(jsonlite)
# library(httr)
# 
# get_user_location <- function(ip) {
#   req <- httr::GET(paste0("https://ipapi.co/", ip, "/json/"))
#   if (httr::status_code(req) != 200) return(NULL)
#   content <- httr::content(req, as = "text", encoding = "UTF-8")
#   jsonlite::fromJSON(content)
# }
# 
# geo_server <- function(id) {
#   moduleServer(id, function(input, output, session) {
#     user_info <- reactiveVal(NULL)
#     
#     observe({
#       ip <- session$request$REMOTE_ADDR
#       # fallback for testing in localhost
#       if (ip == "::1" || ip == "127.0.0.1") ip <- "8.8.8.8"
#       user_info(get_user_location(ip))
#     })
#     
#     return(user_info)
#   })
# }

get_real_ip <- function(session) {
  headers <- session$request$HTTP_X_FORWARDED_FOR
  if (!is.null(headers)) {
    # Extract the first IP from the comma-separated list
    strsplit(headers, ",")[[1]][1]
  } else {
    session$request$REMOTE_ADDR
  }
}


library(httr)
library(jsonlite)

get_ip_info <- function(ip = NULL) {
  url <- if (is.null(ip)) {
    "https://ipapi.co/json/"
  } else {
    paste0("https://ipapi.co/", ip, "/json/")
  }
  
  response <- httr::GET(url)
  if (response$status_code == 200) {
    content <- httr::content(response, as = "text", encoding = "UTF-8")
    data <- jsonlite::fromJSON(content)
    return(list(
      ip = data$ip,
      country = data$country_name,
      city = data$city,
      latitude = data$latitude,
      longitude = data$longitude
    ))
  } else {
    return(NULL)
  }
}
