# utils/distance_helpers.R
library(geosphere)

get_closest_species <- function(user_lat, user_lon, df, top_n = 3) {
  df$distance <- distHaversine(
    matrix(c(user_lon, user_lat), nrow = 1),
    matrix(c(df$lon, df$lat), ncol = 2)
  )
  df[order(df$distance), ][1:top_n, ]
}
