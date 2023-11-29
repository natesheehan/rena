library(data.table)
library(igraph)
library(parallel)

# Function to process a single file with progress updates
process_file <- function(file_path, chunk_size) {
  total_size <- file.info(file_path)$size
  processed_size <- 0
  dt_result <- data.table('Target primary accession' = character())

  # OPEN CONNECTION TO FILE
  con <- file(file_path, open = "r")
  repeat {
    # READ FIRST CHUNK
    lines <- readLines(con, n = chunk_size, warn = FALSE)
    if (length(lines) == 0) {
      break
    }
    # TAAKE DATA FROM TARGET COLUMN
    dt_chunk <- fread(text = lines, sep = "\t", select = "Target primary accession")
    # MERGE CHUNK INTO DATAFRAME
    dt_result <- rbindlist(list(dt_result, dt_chunk), use.names = TRUE, fill = TRUE)

    # CALCULATE PROCESSED SIZE
    processed_size <- processed_size + sum(nchar(lines))
    cat(sprintf("Processing %s: %.2f%% done\n", basename(file_path), 100 * processed_size / total_size))

  }
  close(con)

  return(dt_result)

}


# LIST FILES TO PROCESS
folder_path = "dbs/"
files <- list.files(folder_path, pattern = "\\.tsv$", full.names = TRUE)
file_sizes <- file.info(files)$size
files <- as.data.frame(files[order(file_sizes)])
colnames(files) = "file"

# SET CHUNK SIZE
chunk_size <- 1000000

# LOOP
for(i in 1:nrow(files)){
  dt_result = process_file(files$file[i],chunk_size)
  # CONVERT RESULTS INTO DATAFRAME TO SAVE
  count_results <- dt_result[, .N, by = 'Target primary accession']
  output_file <- paste0(folder_path,gsub("\\.tsv$", "_accession_counts.tsv", basename(files$file[i])))
  fwrite(count_results, file = output_file, sep = "\t", row.names = FALSE)
  cat("Results written to", output_file, "\n")
}

# Set the working directory
setwd("dbs/")  # Replace with your folder path

# List all files that end with "accession_count.tsv"
file_list <- list.files(pattern = ".*accession_counts\\.tsv$")

# Initialize an empty data frame to store the combined data
combined_data <- data.frame()

# Loop through the files and merge them
for (file in file_list) {
  # Read the current file
  temp_data <- read.table(file, sep = "\t", header = TRUE, stringsAsFactors = FALSE)

  # Extract the database name from the file name
  # Remove the "_accession_count.tsv" part to get the database name
  db_name <- sub("_accession_counts\\.tsv$", "", file)

  # Add the database name as a new column
  temp_data$database <- db_name

  # Combine with the main data frame
  combined_data <- rbind(combined_data, temp_data)
}

saveRDS(combined_data,"combined_data.rds")
combined_data = readRDS("combined_data.rds")
combined_data_min = combined_data |> dplyr::filter(N > 1) |>
  dplyr::rename(accession = Target.primary.accession)


# Custom function for efficient pair generation
generate_pairs <- function(db_list) {
  if (length(db_list) < 2) return(NULL)
  t(combn(unique(db_list), 2))
}

# Split the data frame by accession
df_split <- split(combined_data_min, combined_data_min$accession)

# Set up a cluster using available cores
no_cores <- detectCores() - 1
cl <- makeCluster(no_cores)
clusterExport(cl, "generate_pairs")

# Use parallel processing with parLapply
pairs <- parLapply(cl, df_split, function(x) generate_pairs(unique(x$database)))

# Stop the cluster
stopCluster(cl)

# Combine the results and use data.table for efficient aggregation
pair_list <- do.call(rbind, pairs)
pair_list <- unique(pair_list)
setDT(pair_list)
edge_list <- pair_list[, .N, by = .(db1, db2)]
