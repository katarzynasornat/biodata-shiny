# globals.R

# Load libraries used across the app
library(duckdb)
library(DBI)
library(data.table)
library(dplyr)
library(shiny)
library(leaflet)
library(highcharter)
library(shinyjs)
library(glue)

# === Configuration ===

# Ports
options(shiny.host = "0.0.0.0")
options(shiny.port = 8180)

# Azure storage account and container
AZURE_STORAGE_ACCOUNT <- "shinyappdevdata"
AZURE_CONTAINER <- "biodata"

# SAS Tokens (loaded securely from environment variables — set these in .Renviron or Azure App Settings)
AZURE_SAS_TOKEN_OCCURENCE <- Sys.getenv("SPEX_OCCURENCE_SAS_TOKEN")
AZURE_SAS_TOKEN_MULTIMEDIA <- Sys.getenv("SPEX_MULTIMEDIA_SAS_TOKEN")

# === URLs for Parquet Files ===

URL_OCCURRENCE_PARQUET <- glue::glue("https://{AZURE_STORAGE_ACCOUNT}.blob.core.windows.net/{AZURE_CONTAINER}/occurence.parquet?{AZURE_SAS_TOKEN_OCCURENCE}")
URL_MULTIMEDIA_PARQUET <- glue::glue("https://{AZURE_STORAGE_ACCOUNT}.blob.core.windows.net/{AZURE_CONTAINER}/multimedia.parquet?{AZURE_SAS_TOKEN_MULTIMEDIA}")


# === Static data loading ===
data <- fread("data/occurence_PL.csv")
data <- data %>% mutate(scientificName = toupper(scientificName), vernacularName = toupper(vernacularName))
# data$date <- as.Date(data$eventDate, format = "%Y-%m-%d")


load("./data/unique_scientific_names.RData")
load("./data/unique_vernacular_names.RData")

library(shiny)
library(duckdb)
library(dplyr)
library(DBI)

# library(conflicted)
# library(duckplyr)
# conflict_prefer("filter", "dplyr", quiet = TRUE)
# 
# db_exec("INSTALL httpfs")
# db_exec("LOAD httpfs")
# 
# duck_tbl <- read_parquet_duckdb(URL_OCCURRENCE_PARQUET)
# data <- duck_tbl 



# === Precompute unique values per column one time when the app starts ===
# unique_values_map <- list(
#   scientificName = c("", sort(unique(data$scientificName))),
#   vernacularName = c("", sort(unique(data$vernacularName)))
# )
# 
# 


unique_values_map <- list(
  scientificName = c("", sort(unique_scientific_names)),
  vernacularName = c("", sort(unique_vernacular_names))
)

TOTAL_OBS = length(unique_values_map$scientificName)
UNIQUE_SCIENTIFICNAME = length(unique_values_map$scientificName)
DAYS_TO_LAST_OBS = length(unique_values_map$scientificName)

choices_columns <- c("", "scientificName", "vernacularName")


# === DuckDB Connection ===

# Use an in-memory DuckDB database
duckdb_con <- dbConnect(duckdb::duckdb(), dbdir = ":memory:")
dbExecute(duckdb_con, "INSTALL httpfs; LOAD httpfs;")
dbExecute(duckdb_con, "INSTALL parquet; LOAD parquet;")


# #Register Parquet files directly from Azure Blob (without downloading)
# dbExecute(duckdb_con, glue::glue("
#   CREATE OR REPLACE VIEW occurence AS
#   SELECT * FROM read_parquet('{URL_OCCURRENCE_PARQUET}')
# "))
# 
# dbExecute(duckdb_con, glue::glue("
#   CREATE OR REPLACE VIEW multimedia AS
#   SELECT * FROM read_parquet('{URL_MULTIMEDIA_PARQUET}')
# "))

# # === Helper Queries ===
# 
# # Example: Load unique scientific names (you can use this in modules)
# unique_scientific_names <- dbGetQuery(duckdb_con, "SELECT DISTINCT scientificName FROM occurrence")
# 
# # You can preload other helper variables here
