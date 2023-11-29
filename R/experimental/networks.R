# Create a bipartite graph (sources and targets) first
df = readr::read_tsv("../../../Downloads/merged_data.tsv")


response <- GET("https://www.ebi.ac.uk/ena/xref/rest/tsv/source?status=ACTIVE")

# Check if the response was successful
if (status_code(response) == 200) {
  content <- content(response, "text", encoding = "UTF-8")

  # Read the content into a data frame
  data <- read.table(text = content, sep = "\t", header = TRUE, quote = "")

  # Optionally, write the data to a local TSV file
  write.table(data, "data.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
} else {
  cat("The request failed with status code:", status_code(response))
}

data = readr::read_tsv("data.tsv")
library(httr)
library(jsonlite)

# Assuming your DataFrame is something like this
# db_df <- data.frame(db_name = c("db1", "db2", "db3"))

# Function to get search count from API
# Function to get search count from API
get_search_count <- function(db_name) {
  # URL-encode the database name
  encoded_db_name <- URLencode(db_name, reserved = TRUE)
  url <- paste0("https://www.ebi.ac.uk/ena/xref/rest/tsv/searchcount?source=", encoded_db_name)
  response <- GET(url)
  if (status_code(response) == 200) {
    content <- content(response, "text", encoding = "UTF-8")
    # Split the content by new line and extract the second element
    count_line <- strsplit(content, "\n")[[1]][2]
    # Convert the extracted count to numeric
    return(as.numeric(count_line))
  } else {
    return(NA)  # Return NA in case of an error
  }
}


# Add a new column to the DataFrame for the search counts
data$search_count <- NA
data = data |> dplyr::filter(Source != "InterPro")
# Loop through the DataFrame and update the search count
for (i in 1:nrow(data)) {
  data$search_count[i] <- get_search_count(data$Source[i])
}

# View the updated DataFrame
print(data)
write.csv(data,"../../../data.csv")


data$Source = stringr::str_replace_all(data$Source,"/","-")
data = data |> dplyr::filter(Source != "UniEuk (Inferred)")
url <- "https://www.ebi.ac.uk/ena/xref/rest/tsv/search?source="
for (i in 31:nrow(data)) {
  url <- "https://www.ebi.ac.uk/ena/xref/rest/tsv/search?source="
  cat(paste0("Printing now for ", data$Source[i]))

  new_url= paste0(url,data$Source[i],"&limit=0&download=tsv")
  download.file(new_url,method = "curl", destfile = paste0("dbs/",stringr::str_squish(data$Source[i]),".tsv"))
  cat("Bingo. on to the next one.")
}

# Specify the path to the directory containing the subfolders
main_directory <- "dbs"

# Recursively list all TSV files in the subdirectories
tsv_files <- list.files(path = main_directory, pattern = "\\.tsv$", full.names = TRUE, recursive = TRUE)

# Read each TSV file and store in a list
tsv_data_list <- lapply(tsv_files, read_tsv)

# Combine all data frames into one
combined_data <- do.call(rbind, tsv_data_list)

# Write the combined data frame to a new TSV file
write_tsv(combined_data, "dbs/combined_data.tsv")

df = read_tsv("dbs/combined_data.tsv")

## NETWORK

# Step 1: Create a two-column edge list
# For each 'Target primary accession', find all pairs of 'Source' that share it
# Create a two-column edge list
edge_list <- df %>%
  select(Source, `Target primary accession`) %>%
  group_by(`Target primary accession`) %>%
  filter(n() > 1) %>% # Ensure there's at least a pair
  summarise(Source_combinations = list(combn(unique(Source), 2, simplify = FALSE))) %>%
  unnest(cols = c(Source_combinations)) %>%
  mutate(from = sapply(Source_combinations, `[`, 1),
         to = sapply(Source_combinations, `[`, 2)) %>%
  select(from, to) %>%
  distinct() # Remove duplicate pairs

# Create the graph from the edge list
network <- graph_from_data_frame(edge_list, directed = FALSE)

# Assuming you have already created the 'network' graph object

# Calculate node degrees which can be used to size the nodes
node_degree <- degree(network)

# Define a layout for the network
layout <- layout_with_fr(network, niter = 10, area = vcount(network)^1.5, repulserad = vcount(network)^2)

# Plot the network
plot(network, layout = layout,
     vertex.size = sqrt(node_degree) * 2,  # Size nodes based on their degree
     vertex.color = "skyblue",             # Color of the nodes
     vertex.frame.color = NA,              # Remove node borders
     vertex.label = V(network)$name,       # Use the Source names as labels
     vertex.label.color = "black",         # Color of the labels
     vertex.label.cex = 0.8,               # Size of the labels
     vertex.label.dist = 0.5,
     edge.label = E(network)$name,         # Add edge labels (accession names)
     edge.label.cex = 0.6,                 # Size of the edge labels
     edge.label.color = "darkgrey",        # Color of the edge labels
     edge.width = 1,                              # Color of the
     edge.arrow.size = 0.5,                # Size of the arrows (if directed)
     main = "XREF Network Visualization",       # Main title
     sub = "Based on shared 'Target primary accession' between XREF Sources",  # Subtitle
     margin = -0.1                         # Margin around plot
)

#### PLOTS

# Assuming your original dataframe is named df
# Calculate the popularity of each 'Target primary accession'
accession_popularity <- df %>%
  group_by(`Target primary accession`) %>%
  summarise(Popularity = n_distinct(Source)) %>%
  ungroup() %>%
  arrange(desc(Popularity))  # Arrange in descending order of popularity

# Choose the top N for plotting
top_n <- 100
accession_popularity_top <- head(accession_popularity, top_n)

# Plot the top N popular accessions
ggplot(accession_popularity_top, aes(x = reorder(`Target primary accession`, -Popularity), y = Popularity)) +
  geom_bar(stat = "identity", fill = "darkgreen") +
  hrbrthemes::theme_modern_rc() +
  coord_flip() +
  labs(x = "Target Primary Accession", y = "Popularity (Number of Sources)", title = "Top 20 Popular Target Primary Accessions") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),  # Rotate x labels for readability
        plot.title = element_text(hjust = 0.5))  # Center the plot title

### HIST
# Calculate mean and median for the overlay
mean_frequency <- mean(accession_popularity$Popularity)
median_frequency <- median(accession_popularity$Popularity)

# Now, plot the histogram using ggplot2 with overlays for mean and median
ggplot(accession_popularity, aes(x = Popularity)) +
  geom_histogram(binwidth = 1, fill = "steelblue", color = "black") +
  geom_vline(aes(xintercept = mean_frequency), color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = median_frequency), color = "darkgreen", linetype = "dashed", size = 1) +
  hrbrthemes::theme_modern_rc() +
  labs(x = "Number of Sources per Accession",
       y = "Count of Accessions",
       title = "Distribution of Accession Popularity") +
  annotate("text", x = mean_frequency, y = 5, label = paste("Mean =", round(mean_frequency, 2)), hjust = 1.1, color = "red") +
  annotate("text", x = median_frequency, y = 5, label = paste("Median =", round(median_frequency, 2)), hjust = -0.1, color = "darkgreen") +
  theme(plot.title = element_text(hjust = 0.5),  # Center the plot title
        text = element_text(size = 12))  # Adjust text size for readability

#### SOURCE
library(ggplot2)
library(dplyr)
library(forcats) # for fct_reorder

# Assuming your dataframe is named df and has columns 'Source' and 'Target primary accession'
# Calculate the number of accessions for each source
source_accession_counts <- df %>%
  group_by(Source) %>%
  summarise(AccessionCount = n_distinct(`Target primary accession`)) %>%
  ungroup() %>%
  mutate(Source = fct_reorder(Source, AccessionCount)) # Reorder factors for plotting

# Now, plot the bar chart using ggplot2
ggplot(source_accession_counts, aes(x = Source, y = AccessionCount, fill = Source)) +
  geom_col(show.legend = FALSE) + # Use geom_col() which is the same as geom_bar(stat = "identity")
  coord_flip() + # Flip the coordinates to make a horizontal bar chart
  theme_minimal() +
  scale_fill_viridis_d(option = "D", direction = -1) + # Use a pleasing color scale from viridis
  labs(x = "Source",
       y = "Number of Accessions",
       title = "Number of Accessions per Source",
       subtitle = "A TidyTuesday-inspired visualization",
       caption = "Source: Your Dataset") +
  theme(text = element_text(size = 12), # Adjust text size for readability
        plot.title = element_text(size = 16, face = "bold", hjust = 0.5), # Bold plot title
        plot.subtitle = element_text(size = 14, hjust = 0.5), # Subtitle
        plot.caption = element_text(hjust = 0), # Caption
        axis.title.y = element_blank(), # Remove the y-axis title for cleaner look
        axis.text.y = element_text(size = 10)) # Adjust y-axis text size

