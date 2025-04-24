library(stringr)
library(duckdb)
library(AzureStor)

endpoint <- "shinyappdevdata"
container <- "partitioneddata"
sas_token <- Sys.getenv("PARTITIONED_DATA_SAS_TOKEN")
azure_url <- "https://shinyappdevdata.blob.core.windows.net/partitioneddata"
# 
# get_dataset_for_scientificName_duckdb <- function(folder_path = "/home/kasia/Documents/speX/data/parquet_files/scientificName_partitioned", scientificName_value){
#   time_start <- Sys.time()
#   partition_indicator <- substr(toupper(scientificName_value), 1, 1)
#   parquet_path <- paste0(folder_path, "/first_letter_scientificName=", partition_indicator, "/part-0.parquet")
#   duck_query <- str_interp("
#     select eventDate, country, sum(individualCount) as total
#     from parquet_scan('${parquet_path}')
#     where scientificName = '${scientificName_value}'
#     group by eventDate, country")
#   
#   res <- dbGetQuery(
#     conn = dbConnect(duckdb()),
#     statement = duck_query
#   )
#   time_end <- Sys.time()
#   
#   return(list(
#     data = res,
#     runtime = as.numeric(time_end - time_start)
#   ))
# }

get_dataset_for_duckdb <- function(folder_path = "/home/kasia/Documents/speX/data/parquet_files/scientificName_partitioned",
                                   group_by_columns = c("eventDate", "country"),
                                   scientificName_value, 
                                   azure_container_url = NULL, 
                                   sas_token = NULL) {
  time_start <- Sys.time()
  
  conn <- dbConnect(duckdb())
  dbExecute(conn, "INSTALL httpfs;")
  dbExecute(conn, "LOAD httpfs;")
  
  # If using Azure Blob Storage
  if (!is.null(azure_container_url) && !is.null(sas_token)) {
    # Construct the full Azure Blob Storage URL to the Parquet file
    partition_indicator <- substr(toupper(scientificName_value), 1, 1)
    parquet_path <- paste0(azure_container_url, "/first_letter_scientificName=", partition_indicator, "/part-0.parquet", sas_token)
  } else {
    # Default local path
    partition_indicator <- substr(toupper(scientificName_value), 1, 1)
    parquet_path <- paste0(folder_path, "/first_letter_scientificName=", partition_indicator, "/part-0.parquet")
  }
  
  group_by_clause <- paste(group_by_columns, collapse = ", ")
  
  # Construct the DuckDB query
  duck_query <- str_interp("
  SELECT ${group_by_clause}, SUM(individualCount) AS individualCount
  FROM parquet_scan('${parquet_path}')
  WHERE scientificName = '${scientificName_value}'
  GROUP BY ${group_by_clause}")
  
  # Connect to DuckDB and execute the query
  res <- dbGetQuery(conn, duck_query)
  dbDisconnect(conn)
  time_end <- Sys.time()
  
  return(list(
    data = res,
    runtime = as.numeric(time_end - time_start)
  ))
}


# result_azure <- get_dataset_for_duckdb(
#   scientificName_value = "PARUS MAJOR",
#   group_by_columns = c("eventDate", "latitudeDecimal", "longitudeDecimal"),
#   azure_container_url = azure_url,
#   sas_token = sas_token
# )