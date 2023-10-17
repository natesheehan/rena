
# Ena File Downloader

This software is authored by EMBL-EBI and distributed as is. License: https://www.apache.org/licenses/LICENSE-2.0

The `rena` package provides tools for bulk downloading read/analysis files from ENA via FTP using the `ena-ftp-downloader`.
download data from the European Nucleotide Archive (ENA). 

The function supports two types of downloads:

* Query-based download: Provide a query string to retrieve specific data.
* Accession-based download: Provide accession numbers to download specific data.

## Installation

You can install the released version of abstr from
[CRAN](https://CRAN.R-project.org) with:

Install the development version from GitHub as follows:

``` r
remotes::install_github("natesheehan/rena")
```

## Usage
``` r
ena_download(download_type, query = NULL, accession = NULL, format, location = getwd(), email = "NONE")
```

### Arguments
* `download_type`: A character specifying the type of download. Use 'q' for query-based download or 'a' for accession-based download.
* `query`: A character string containing the query to retrieve specific data. This is required when using the 'q' download type.
* `accession`: A character string containing accession numbers. This is required when using the 'a' download type.
* `format`: A character string specifying the format of the data to download. Valid options are 'READS_FASTQ', 'READS_SUBMITTED', 'ANALYSIS_SUBMITTED', and 'ANALYSIS_GENERATED'.
* `location`: A character string specifying the download location. By default, it uses the current working directory.
* `email:` A character string specifying the email address for notifications. By default, no email is sent.

### Download data using a query
```r
ena_download("q", query = "country=%22Japan%22AND%20depth=168", format = "READS_FASTQ")
```

### Download data using accession numbers
```r
ena_download("a", accession = "SAMEA3231268,SAMEA3231287", format = "READS_FASTQ")
```

## Issues
For support/issues, please contact us at https://www.ebi.ac.uk/ena/browser/support or drop an issue on the github.

## Privacy Notice 
The execution of this tool may require limited processing of your personal data to function. By using
this tool you are agreeing to this as outlined in our Privacy Notice: https://www.ebi.ac.uk/data-protection/privacy-notice/ena-presentation and Terms of Use: https://www.ebi.ac.uk/about/terms-of-use.

*******************************************************************************

* Copyright 2023 EMBL-EBI, Hinxton outstation
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.

******************************************************************************
