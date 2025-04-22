library(conflicted)
library(dplyr)
library(duckplyr)

#conflicts_prefer(duckplyr::filter)

db_exec("INSTALL httpfs")
db_exec("LOAD httpfs")

dataset <- read_parquet_duckdb(URL_OCCURRENCE_PARQUET)

# Load Parquet into a DuckDB table (in memory)
dbExecute(duckdb_con, sprintf("CREATE TABLE occurence_table AS SELECT * FROM read_parquet('%s')", URL_OCCURRENCE_PARQUET))

# Now you can query repeatedly without reading from disk
df1 <- dbGetQuery(duckdb_con, "SELECT * FROM my_data WHERE column_x = 'value1'")
df2 <- dbGetQuery(duckdb_con, "SELECT COUNT(*) FROM my_data WHERE column_y > 10")