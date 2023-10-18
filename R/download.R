#' Download data from the European Nucleotide Archive (ENA)
#'
#' This function allows you to download data from the European Nucleotide Archive (ENA)
#' using either a query or accession numbers.
#'
#' @param download_type A character specifying the type of download: 'q' for query or 'a' for accession.
#' @param query A character string containing the query to retrieve specific data (required for 'q' download type).
#' @param accession A character string containing accession numbers (required for 'a' download type).
#' @param format A character string specifying the format of the data to download.
#'               It must be one of: 'READS_FASTQ', 'READS_SUBMITTED', 'ANALYSIS_SUBMITTED', 'ANALYSIS_GENERATED'.
#' @param location A character string specifying the download location (default is the current working directory).
#' @param email A character string specifying the email address for notifications (default is "NONE").
#'
#' @return None (downloads data to the specified location)
#'
#' @details This function downloads data from the ENA using the ENA file downloader tool.
#' It supports two types of downloads:
#' - Query-based download ('q'): You provide a query string to retrieve specific data.
#' - Accession-based download ('a'): You provide accession numbers to download specific data.
#'
#' @examples
#' # Download data using a query
#' q = "result=read_run&query=country=%22Japan%22AND%20depth=168"
#' ena_download("q", query = q, format = "READS_FASTQ")
#'
#' # Download data using accession numbers
#' ena_download("a", accession = "SAMEA3231268,SAMEA3231287", format = "READS_FASTQ")
#'
#'
#' @export
ena_download <- function(download_type,
                         query = NULL,
                         accession = NULL,
                         format,
                         location = getwd(),
                         email = "NONE") {
  # Semantic validation of variables
  download_type <- tolower(download_type)
  valid_types <- c("q", "a")
  valid_formats <-
    c("READS_FASTQ",
      "READS_SUBMITTED",
      "ANALYSIS_SUBMITTED",
      "ANALYSIS_GENERATED")

  if (!download_type %in% valid_types) {
    stop("Wrong download type has been given. Please use 'q' for query or 'a' for accession.")
  }
  if (!format %in% valid_formats) {
    stop(
      "Wrong format type has been given. Please use one of: READS_FASTQ, READS_SUBMITTED, ANALYSIS_SUBMITTED, ANALYSIS_GENERATED."
    )
  }

  if (location == "") {
    location <- getwd()
    message("No location has been given. Downloading in the current working directory.")
  }
  if (email == "") {
    email <- "NONE"
    message("No email has been given. No email will be sent once the download is complete.")
  }

  ena_command <-
    paste0(
      "java -jar inst/extdata/ena-file-downloader/ena-file-downloader.jar",
      " --format=",
      format,
      " --location=",
      location,
      " --protocol=FTP --asperaLocation=null --email=",
      email
    )

  if (download_type == "q") {
    if (is.null(query)) {
      stop("Query is required for download type 'q'.")
    }
    ena_command <- paste0(ena_command, " --query=", query)
  } else if (download_type == "a") {
    if (is.null(accession)) {
      stop("Accession is required for download type 'a'.")
    }
    ena_command <- paste0(ena_command, " --accessions=", accession)
  } else {
    stop("Invalid download type. Use 'q' for query or 'a' for accession.")
  }

  # Execute the system command
  system(ena_command)
}


#' Download data from the European Nucleotide Archive (ENA) DataHub (Restricted Access)
#'
#' This function allows you to download data from the European Nucleotide Archive (ENA)
#' using either a query or accession numbers.
#'
#' @param download_type A character specifying the type of download: 'q' for query or 'a' for accession.
#' @param query A character string containing the query to retrieve specific data (required for 'q' download type).
#' @param accession A character string containing accession numbers (required for 'a' download type).
#' @param format A character string specifying the format of the data to download.
#'               It must be one of: 'READS_FASTQ', 'READS_SUBMITTED', 'ANALYSIS_SUBMITTED', 'ANALYSIS_GENERATED'.
#' @param location A character string specifying the download location (default is the current working directory).
#' @param email A character string specifying the email address for notifications (default is "NONE").
#' @param dataHubUsername A character string specifying the username for ENA data hub account.
#' @param dataHubPassword A character string specifying the password for ENA data hub account.
#'
#' @return None (downloads data to the specified location)
#'
#' @details This function downloads data from the ENA using the ENA file downloader tool.
#' It supports two types of downloads:
#' - Query-based download ('q'): You provide a query string to retrieve specific data.
#' - Accession-based download ('a'): You provide accession numbers to download specific data.
#'
#' @examples
#' # Download data using a query
#' q = "result=read_run&query=country=%22Japan%22AND%20depth=168"
#' ena_download("q", query = q, format = "READS_FASTQ")
#'
#' # Download data using accession numbers
#' ena_download("a", accession = "SAMEA3231268,SAMEA3231287", format = "READS_FASTQ")
#'
#'
#' @export
ena_datahub_download <- function(download_type,
                                 query = NULL,
                                 accession = NULL,
                                 format,
                                 location = getwd(),
                                 email = "NONE",
                                 dataHubUsername = NULL,
                                 dataHubPassword = NULL) {
  # Semantic validation of variables
  download_type <- tolower(download_type)
  valid_types <- c("q", "a")
  valid_formats <-
    c("READS_FASTQ",
      "READS_SUBMITTED",
      "ANALYSIS_SUBMITTED",
      "ANALYSIS_GENERATED")

  if (!download_type %in% valid_types) {
    stop("Wrong download type has been given. Please use 'q' for query or 'a' for accession.")
  }
  if (!format %in% valid_formats) {
    stop(
      "Wrong format type has been given. Please use one of: READS_FASTQ, READS_SUBMITTED, ANALYSIS_SUBMITTED, ANALYSIS_GENERATED."
    )
  }

  if (location == "") {
    location <- getwd()
    message("No location has been given. Downloading in the current working directory.")
  }
  if (email == "") {
    email <- "NONE"
    message("No email has been given. No email will be sent once the download is complete.")
  }

  ena_command <-
    paste0(
      "java -jar inst/extdata/ena-file-downloader/ena-file-downloader.jar",
      " --format=",
      format,
      " --location=",
      location,
      " --protocol=FTP --asperaLocation=null --email=",
      email,
      " --dataHubUsername=",
      dataHubUsername,
      " --dataHubPassword=",
      dataHubPassword
    )

  if (download_type == "q") {
    if (is.null(query)) {
      stop("Query is required for download type 'q'.")
    }
    ena_command <- paste0(ena_command, " --query=", query)
  } else if (download_type == "a") {
    if (is.null(accession)) {
      stop("Accession is required for download type 'a'.")
    }
    ena_command <- paste0(ena_command, " --accessions=", accession)
  } else {
    stop("Invalid download type. Use 'q' for query or 'a' for accession.")
  }

  # Execute the system command
  system(ena_command)
}

