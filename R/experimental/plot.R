library(httr)
library(dplyr)

words <- c("analysis", "assembly", "coding", "experiment", "noncoding", "run", "sample", "sequence", "study", "taxon", "trace", "wgsmaster")

# Convert the vector into a data frame
words_df <- data.frame(Word = words)

get_search_count <- function(db_name, target_word) {
  # URL-encode the database name and target word
  encoded_db_name <- URLencode(db_name, reserved = TRUE)
  encoded_target_word <- URLencode(target_word, reserved = TRUE)

  # Construct the URL with the target parameter
  url <- paste0("https://www.ebi.ac.uk/ena/xref/rest/tsv/searchcount?source=", encoded_db_name, "&target=", encoded_target_word)

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

# Assuming 'data' is your database DataFrame and it has a column 'Source'
data <- data %>% dplyr::filter(Source != "InterPro")

# Create an empty DataFrame to store the results
search_counts_df <- data.frame(Database = character(), Word = character(), SearchCount = numeric(), stringsAsFactors = FALSE)

# Loop through the DataFrame and words, and update the search count
for (i in 1:nrow(data)) {
  cat(paste0("Running in position ",i,"/",nrow(data)))
  for (word in words) {
    count <- get_search_count(data$Source[i], word)
    # Add the results to the DataFrame
    search_counts_df <- rbind(search_counts_df, data.frame(Database = data$Source[i], Word = word, SearchCount = count))
  }
}

write.csv(search_counts_df,"search_counts.csv")
search_counts_df = read.csv("search_counts.csv")
data = read.csv("raw-data-v1.csv")
df = search_counts_df |> filter(Word != "trace")

result_df <- df %>%
  group_by(Database, Word) %>%
  summarize(TotalWordCount = sum(SearchCount)) %>%
  group_by(Database) %>%
  summarize(TotalCount = sum(TotalWordCount)) |>
  mutate(Database2 = "ENA") |>
  select(Database,Database2,TotalCount)

df9= df9 |> select(Source,Internal) |> rename(Database = Source)

df1 = result_df
df2 = edge_list

df1 = left_join(df1,df9)

df_word_summary <- df %>%
  group_by(Word) %>%
  summarise(TotalSearchCount = sum(SearchCount)) %>%
  arrange(desc(TotalSearchCount))

df_database_summary <- df %>%
  group_by(Database) %>%
  summarise(TotalSearchCount = sum(SearchCount)) %>%
  arrange(desc(TotalSearchCount)) %>%
  rename(Source = Database) %>%
  rename(Database = Source)

# Bar chart of leading Words
a <- ggplot(df_word_summary, aes(x = reorder(Word, TotalSearchCount), y = TotalSearchCount)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_text(aes(label = TotalSearchCount), hjust = 2.9, color = "white", face = "bold") +
  theme_minimal() +
  hrbrthemes::theme_ipsum_pub() +
  labs(title = "Total Xref Count by Target(Data Type)", x = "Target", y = "Total XREF Count") +
  coord_flip() +
  scale_y_log10() +
  theme(legend.position = "right",
        legend.title = element_text(size = 12, color = "white"),
        legend.text = element_text(size = 10, color = "white"),
        legend.key.size = unit(0.5, "cm"),
        plot.title = element_text(size = 14, face = "bold", color = "white"),
        plot.caption = element_text(size = 8, face = "bold", color = "white"),
        plot.background = element_rect(fill = "black"),
        plot.subtitle = element_text(size = 10, face = "bold", color = "white"),
        panel.background = element_rect(fill = "black"),
        axis.text = element_text(color = "white"),  # Remove axis text
        axis.title = element_blank(),  # Remove axis titles
        axis.ticks = element_blank(),  # Remove axis ticks
        axis.line = element_blank(),  # Remove axis lines
        legend.background = element_rect(fill = "#333333", color = NA),  # Grey legend background
        legend.key = element_rect(fill = "#333333", color = NA))

# Box plot of each word and their SearchCounts
b <- ggplot(df, aes(x = reorder(Word, SearchCount), y = SearchCount)) +
  geom_boxplot(fill = "steelblue", color = "red") +
  theme_minimal() +
  labs(title = "Xref Search Count Distribution per Target (Data Type)", x = "Target", y = "XREF Count") +
  coord_flip() +
  scale_y_log10() +
  theme(legend.position = "right",
        legend.title = element_text(size = 12, color = "white"),
        legend.text = element_text(size = 10, color = "white"),
        legend.key.size = unit(0.5, "cm"),
        plot.title = element_text(size = 14, face = "bold", color = "white"),
        plot.caption = element_text(size = 8, face = "bold", color = "white"),
        plot.background = element_rect(fill = "black"),
        plot.subtitle = element_text(size = 10, face = "bold", color = "white"),
        panel.background = element_rect(fill = "black"),
        axis.text = element_text(color = "white"),  # Remove axis text
        axis.title = element_blank(),  # Remove axis titles
        axis.ticks = element_blank(),  # Remove axis ticks
        axis.line = element_blank(),  # Remove axis lines
        legend.background = element_rect(fill = "#333333", color = NA),  # Grey legend background
        legend.key = element_rect(fill = "#333333", color = NA))


# Bar chart of the Databases
library(ggplot2)
library(hrbrthemes)
library(dplyr)
library(ggplot2)
library(hrbrthemes)
library(scales)  # For formatting numbers
library(dplyr)   # For data manipulation

# Assuming df_database_summary is your data frame
# and it has columns 'Database', 'TotalSearchCount', and 'internal'

# Renaming 'internal' for clarity
df_database_summary <- df_database_summary %>%
  mutate(ResourceType = ifelse(internal == "TRUE", "Internal Resource", "External Resource"))

# Calculate summary statistics
summary_stats <- df_database_summary %>%
  group_by(ResourceType) %>%
  summarise(
    Mean = mean(TotalSearchCount),
    Median = median(TotalSearchCount),
    SD = sd(TotalSearchCount)
  )

c <- ggplot(df_database_summary, aes(x = reorder(Database, TotalSearchCount), y = TotalSearchCount, fill = ResourceType)) +
  geom_bar(stat = "identity") +
  geom_text(
    aes(label = scales::comma(TotalSearchCount)),
    vjust = -0.3,
    color = "black",
    check_overlap = TRUE,
    size = 3.5
  ) +
  hrbrthemes::theme_ipsum_pub() +
  labs(
    title = "A) Total XREF Count by Database",
    subtitle = "Comparing Internal vs. External Resources",
    x = "Database",
    y = "Total XREF Count (log scale)",
  ) +
  coord_flip() +
  scale_y_log10(labels = scales::comma) +
  scale_fill_manual(values = c("Internal Resource" = "blue", "External Resource" = "red")) +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 12),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.title = element_blank(),
    legend.position = "bottom"
  ) +
  annotate("text", x = 14, y = 1000000000,
           label = paste("External Resource Summary Stats:\n",
                         "Mean: ", round(summary_stats$Mean[1], 2),
                         "Median: ", summary_stats$Median[1],
                         "SD: ", round(summary_stats$SD[1], 2), "\n",
                         "Internal Resource Summary Stats:\n",
                         "Mean: ", round(summary_stats$Mean[2], 2),
                         "Median: ", summary_stats$Median[2],
                         "SD: ", round(summary_stats$SD[2], 2)),
           hjust = 1, vjust = 1, size = 3, color = "grey20", fontface = 2)

# Print the plot
print(c)

# Arrange the plots using ggarrange
ggarrange(c,b ,ncol = 2, nrow = 1, widths = c(6,4),heights = c(10,7))


name_mapping <- c(
  "uniprotkb_swiss-prot" = "UniProtKB/Swiss-Prot",
  "uniprotkb_trembl_xrefs" = "UniProtKB/TrEMBL",
  "imgt_hla_xrefs" = "IMGT/HLA"
)

# Apply the mapping to df1 and df2
df1 <- df1 %>%
  mutate(Database = recode(Database, !!!name_mapping),
         Database2 = recode(Database2, !!!name_mapping))

df2 <- df2 %>%
  mutate(V1 = recode(V1, !!!name_mapping),
         V2 = recode(V2, !!!name_mapping)) |>
  dplyr::filter(V1 != "InterPro") |>
  dplyr::filter(V2 != "InterPro")


edges_df1 <- df1 %>%
  mutate(Database2 = "ENA",
         edge_type = "Reuse of ENA Data") %>%
  select(from = Database, to = Database2, weight = TotalCount, edge_type)

# Prepare edges from df2
edges_df2 <- df2 %>%
  mutate(edge_type = "Shared reuse between databases") %>%
  select(from = V1, to = V2, weight = n, edge_type)

# Combine edge lists
combined_edges <- rbind(edges_df1, edges_df2)

# Create a graph
net <- graph_from_data_frame(combined_edges, directed = TRUE)

# Add node attribute for internal/external
df1_nodes <- unique(df1$Database)
internal_status <- df1$Internal[match(V(net)$name, df1_nodes)]
V(net)$internal <- ifelse(is.na(internal_status), FALSE, internal_status)

# Plot the network

# Plot the network with a dark background
l=ggraph(net, layout = 'stress') +
  geom_edge_link(aes(width = weight, color = edge_type), edge_alpha = 0.8, lineend = "round") +
  scale_edge_width(range = c(0.5, 3),
                   breaks = waiver(),
                   labels = scales::label_number()) +
  scale_edge_color_manual(values = c("Reuse of ENA Data" = "blue", "Shared reuse between databases" = "red"),
                          name = "Edge Type") +
  geom_node_point(aes(color = internal), size = 5) +
  scale_color_manual(values = c("TRUE" = "green", "FALSE" = "orange"),
                     name = "Internal resource") +
  geom_node_text(aes(label = name), vjust = 1.8, size = 3.5, color = "white") +
  theme_graph(base_family = "Arial", base_size = 12) +
  theme(legend.position = "right",
        legend.title = element_text(size = 12, color = "white"),
        legend.text = element_text(size = 10, color = "white"),
        legend.key.size = unit(0.5, "cm"),
        plot.title = element_text(size = 14, face = "bold", color = "white"),
        plot.caption = element_text(size = 8, face = "bold", color = "white"),
        plot.background = element_rect(fill = "black"),
        plot.subtitle = element_text(size = 10, face = "bold", color = "white"),
        panel.background = element_rect(fill = "black"),
        axis.text = element_blank(),  # Remove axis text
        axis.title = element_blank(),  # Remove axis titles
        axis.ticks = element_blank(),  # Remove axis ticks
        axis.line = element_blank(),  # Remove axis lines
        legend.background = element_rect(fill = "#333333", color = NA),  # Grey legend background
        legend.key = element_rect(fill = "#333333", color = NA)) +  # Grey legend keys
  guides(width = guide_legend(override.aes = list(colour = "white", size = 3))) +  # Custom guide for edge width
  labs(title = "Tracing the Reuse of Open Data from the ENA",
       subtitle = "Exploring cross referenced accessions using the Xref system",
       color = "Edge Type",
       width = "Edge Weight")

# Load libraries
library(ggplot2)
library(dplyr)

# Example data (replace this with your actual data)
# df <- data.frame(accession = ..., database = ..., frequency = ...)

# Data Preparation
# Summing up frequencies across databases for each accession
total_freq <- combined_data %>%
  group_by(Target.primary.accession) %>%
  summarise(total = sum(N)) %>%
  arrange(desc(total))

# Selecting top 100 accessions
top_accessions <- head(total_freq, 100)$Target.primary.accession

# Filtering original data for only top accessions
filtered_df <- combined_data %>%
  filter(Target.primary.accession %in% top_accessions)

# Plotting
ggplot(filtered_df, aes(x = reorder(Target.primary.accession, -N), y = N, fill = database)) +
  geom_bar(stat = "identity") +
  labs(title = "Top 100 Accessions by Database Frequency",
       x = "Accession",
       y = "Frequency") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        plot.title = element_text(size = 14, face = "bold"),
        legend.title = element_blank()) +
  coord_flip()  # Flips the axes for better visualization of accessions

library(ggplot2)
library(dplyr)

# Summarize the data to get total counts and reference counts for each Word
df_summary <- df %>%
  group_by(Word) %>%
  summarize(TotalCount = sum(SearchCount),
            ReferenceCount = sum(SearchCount > 0))

# Join the summaries back to the original dataframe
df <- df %>%
  left_join(df_summary, by = "Word")

# Modify the Word levels to include the summaries
df$Word <- with(df, paste(Word, "\n(Total:", TotalCount, ",  DB's Ref:", ReferenceCount, ")", sep=""))

# Create the plot using the original dataframe
b <- ggplot(df, aes(x = reorder(Word, SearchCount), y = SearchCount)) +
  geom_boxplot(fill = "steelblue", color = "red") +
  theme_minimal() +
  labs(title = "Xref Search Count Distribution per Target (Data Type)",
       x = "Target",
       y = "XREF Count") +
  coord_flip() +
  scale_y_log10() +
  theme(legend.position = "right",
        legend.title = element_text(size = 12, color = "white"),
        legend.text = element_text(size = 10, color = "white"),
        legend.key.size = unit(0.5, "cm"),
        plot.title = element_text(size = 14, face = "bold", color = "white"),
        plot.caption = element_text(size = 8, face = "bold", color = "white"),
        plot.background = element_rect(fill = "black"),
        plot.subtitle = element_text(size = 10, face = "bold", color = "white"),
        panel.background = element_rect(fill = "black"),
        axis.text = element_text(color = "white"),
        axis.title.x = element_text(size = 12, color = "white"),  # Add x-axis title
        axis.title.y = element_text(size = 12, color = "white"),  # Add y-axis title
        axis.ticks = element_blank(),  # Remove axis ticks
        axis.line = element_blank(),  # Remove axis lines
        legend.background = element_rect(fill = "#333333", color = NA),  # Grey legend background
        legend.key = element_rect(fill = "#333333", color = NA))

print(b)

## Pruned Network matching EBI Search
prunes = df1 |> dplyr::filter(
  Database == "ArrayExpress" |
    Database == "Assembly" |
    Database == "EnsemblGenomes" |
    Database == "EnsemblGenomes-Gn" |
    Database == "EuropePMC" |
    Database == "MGnify" |
    Database == "SARS-CoV-2" |
    Database == "UniEuk" |
    Database == "WGS" |
    Database == "WormBase"
)
prunes$Domain.identifier = c(
  "arrayexpress-repository",
  "genome_assembly",
  "ensembl_gene",
  "ensemblGenomes_gene",
  "europepmc",
  "metagenomics_projects",
  "embl-covid19",
  "taxonomy",
  "coding_wgs_1",
  "wormbaseParasite"
)
v=left_join(prunes,bob)


library(tidyverse)

# Assuming your dataframe is named db_data
db_data <- v %>%
  mutate(PercentShare = TotalCount / Number.of.entries * 100)

# Create edges (connections) from each database to ENA
edges <- db_data %>%
  select(Database, Database2, PercentShare)


# Create edges (connections) from each database to ENA
# Create edges (connections) from each database to ENA
edges <- db_data %>%
  select(Database, Database2, PercentShare) %>%
  mutate(PercentShareCategory = factor(case_when(
    PercentShare <= 25 ~ "0-25%",
    PercentShare > 25 & PercentShare <= 50 ~ "25-50%",
    PercentShare > 50 & PercentShare <= 75 ~ "50-75%",
    PercentShare > 75 & PercentShare <= 100 ~ "75-100%",
    TRUE ~ "100+"
  ), levels = c("0-25%", "25-50%", "50-75%", "75-100%", "100+"))) |>
  dplyr::rename()

# Create nodes
nodes <- data.frame(name = unique(c(db_data$Database, db_data$Database2)))

# Create a graph from the edges data
network <- graph_from_data_frame(d = edges, vertices = nodes, directed = TRUE)

ggraph(network, layout = 'stress') +
  geom_edge_link(aes(width = PercentShareCategory, color = PercentShareCategory), arrow = arrow(length = unit(4, 'mm'))) +
  geom_node_point(size = 3, color = "darkblue") +
  geom_node_text(aes(label = name), vjust = 1, hjust = -0, color = "white", face = "bold",size=5) +
  scale_color_manual(values = c("0-25%" = "blue", "25-50%" = "green", "50-75%" = "red", "75-100%" = "orange", "100+" = "purple"),
                     name = "Percent of resources cross-referenced in xref") +
  ggtitle("Pruned tree of EMBL-EBI resources cross-referenced in ENA xref") +
  theme_graph(base_family = "Arial", base_size = 12) +
  theme(legend.position = "right",
        legend.title = element_text(size = 12, color = "white"),
        legend.text = element_text(size = 10, color = "white"),
        legend.key.size = unit(0.5, "cm"),
        plot.title = element_text(size = 14, face = "bold", color = "white"),
        plot.caption = element_text(size = 8, face = "bold", color = "white"),
        plot.background = element_rect(fill = "black"),
        plot.subtitle = element_text(size = 10, face = "bold", color = "white"),
        panel.background = element_rect(fill = "black"),
        axis.text = element_blank(),  # Remove axis text
        axis.title = element_blank(),  # Remove axis titles
        axis.ticks = element_blank(),  # Remove axis ticks
        axis.line = element_blank(),  # Remove axis lines
        legend.background = element_rect(fill = "#333333", color = NA),  # Grey legend background
        legend.key = element_rect(fill = "#333333", color = NA))
