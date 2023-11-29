#' Query Active Xref Sources
#'
#' This function queries active xref sources from the EBI database and returns the results as a data frame.
#' Optionally, it writes the data to a local TSV file named "data.tsv".
#'
#' @return A data frame containing the query results.
#' @export
#' @importFrom httr GET
#' @importFrom httr status_code
#' @importFrom utils read.table
xref_active = function(){
  response <- GET("https://www.ebi.ac.uk/ena/xref/rest/tsv/source?status=ACTIVE")
  # Check if the response was successful
  if (status_code(response) == 200) {
    content <- content(response, "text", encoding = "UTF-8")

    # Read the content into a data frame
    data <- read.table(text = content, sep = "\t", header = TRUE, quote = "")

  } else {
    cat("The request failed with status code:", status_code(response))
  }
  return(data)
}


#' Query Xref Targets
#'
#' Queries xref targets based on a specified source from the EBI database.
#' The results are returned as a data frame and optionally written to a local TSV file named "data.tsv".
#'
#' @param target The target source to query.
#' @return A data frame containing the query results.
#' @importFrom httr GET
#' @importFrom httr status_code
#' @importFrom utils read.table
#' @export
xref_target = function(target){
  response <- GET(paste0("https://www.ebi.ac.uk/ena/xref/rest/tsv/target?source=",target))
  # Check if the response was successful
  if (status_code(response) == 200) {
    content <- content(response, "text", encoding = "UTF-8")

    # Read the content into a data frame
    data <- read.table(text = content, sep = "\t", header = TRUE, quote = "")


  } else {
    cat("The request failed with status code:", status_code(response))
  }
  return(data)
}

#' Count Xref Search Results
#'
#' Performs a search count query in the EBI xref database based on provided parameters.
#' Returns the count of search results as a data frame.
#'
#' @param source Optional source parameter for the query.
#' @param target Optional target parameter for the query.
#' @param accession Optional accession parameter for the query.
#' @return A data frame containing the count of search results.
#' @importFrom httr GET
#' @importFrom httr status_code
#' @importFrom utils read.table
#' @export
xref_searchcount <- function(source = NULL, target = NULL, accession = NULL) {
  # Base URL
  base_url <- "https://www.ebi.ac.uk/ena/xref/rest/tsv/searchcount?"

  # Initialize query parameters
  params <- list()

  # Add parameters if they are not NULL
  if (!is.null(source)) params$source <- source
  if (!is.null(target)) params$target <- target
  if (!is.null(accession)) params$accession <- accession

  # Check if no parameters were provided
  if (length(params) == 0) {
    stop("No parameters provided for the query")
  }

  # Construct the query string
  query_string <- paste0(names(params), "=", params, collapse = "&")

  # Complete URL
  url <- paste0(base_url, query_string)

  # Make the GET request
  response <- httr::GET(url)

  # Check if the response was successful
  if (httr::status_code(response) == 200) {
    content <- httr::content(response, "text", encoding = "UTF-8")

    # Read the content into a data frame
    data <- read.table(text = content, sep = "\t", header = TRUE, quote = "")

  } else {
    cat("The request failed with status code:", httr::status_code(response), "\n")
    return(NULL)
  }

  return(data)
}

#' Perform Xref Search
#'
#' Searches the EBI xref database based on provided parameters.
#' Returns the search results as a data frame.
#'
#' @param source Optional source parameter for the query.
#' @param target Optional target parameter for the query.
#' @param accession Optional accession parameter for the query.
#' @param limit Optional limit parameter for the query.
#' @return A data frame containing the search results.
#' @importFrom httr GET
#' @importFrom httr status_code
#' @importFrom utils read.table
#' @export
xref_search <- function(source = NULL, target = NULL, accession = NULL,limit=NULL) {
  # Base URL
  base_url <- "https://www.ebi.ac.uk/ena/xref/rest/tsv/search?"

  # Initialize query parameters
  params <- list()

  # Add parameters if they are not NULL
  # Add parameters if they are not NULL
  if (!is.null(source)) params$source <- source
  if (!is.null(target)) params$target <- target
  if (!is.null(accession)) params$accession <- accession
  if (!is.null(limit)) params$limit <- limit  # Corrected this line

  # Check if no parameters were provided
  if (length(params) == 0) {
    stop("No parameters provided for the query")
  }

  # Construct the query string
  query_string <- paste0(names(params), "=", params, collapse = "&")

  # Complete URL
  url <- paste0(base_url, query_string)

  # Make the GET request
  response <- httr::GET(url)

  # Check if the response was successful
  if (httr::status_code(response) == 200) {
    content <- httr::content(response, "text", encoding = "UTF-8")

    # Read the content into a data frame
    data <- read.table(text = content, sep = "\t", header = TRUE, quote = "")

  } else {
    cat("The request failed with status code:", httr::status_code(response), "\n")
    return(NULL)
  }

  return(data)
}
