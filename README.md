
<!-- README.md is generated from README.Rmd. Please edit that file -->

## Installation

You can install the development version of rena from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("natesheehan/rena")
#> Downloading GitHub repo natesheehan/rena@HEAD
#> ── R CMD build ─────────────────────────────────────────────────────────────────
#>          checking for file 'C:\Users\ns651\AppData\Local\Temp\RtmpS0enCm\remotes54ec2e4e2514\natesheehan-rena-8b8bf33/DESCRIPTION' ...  ✔  checking for file 'C:\Users\ns651\AppData\Local\Temp\RtmpS0enCm\remotes54ec2e4e2514\natesheehan-rena-8b8bf33/DESCRIPTION'
#>       ─  preparing 'rena': (517ms)
#>    checking DESCRIPTION meta-information ...  ✔  checking DESCRIPTION meta-information
#>       ─  checking for LF line-endings in source and make files and shell scripts
#>       ─  checking for empty or unneeded directories
#>      Omitted 'LazyData' from DESCRIPTION
#>       ─  building 'rena_0.1.0.tar.gz'
#>      
#> 
#> Installing package into 'C:/Users/ns651/AppData/Local/Temp/RtmpWCakON/temp_libpath8e08357194f'
#> (as 'lib' is unspecified)
```

# Ena File Downloader

The `rena` package provides tools for bulk downloading read/analysis
files from ENA via FTP using the `ena-ftp-downloader`. download data
from the European Nucleotide Archive (ENA).

The function supports two types of downloads:

- Query-based download: Provide a query string to retrieve specific
  data.
- Accession-based download: Provide accession numbers to download
  specific data.

## Installation

You can install the released version of abstr from
[CRAN](https://CRAN.R-project.org) with:

Install the development version from GitHub as follows:

``` r
remotes::install_github("natesheehan/rena")
#> Skipping install of 'rena' from a github remote, the SHA1 (8b8bf33d) has not changed since last install.
#>   Use `force = TRUE` to force installation
library(rena)
```

## Usage

### Arguments

- `download_type`: A character specifying the type of download. Use ‘q’
  for query-based download or ‘a’ for accession-based download.
- `query`: A character string containing the query to retrieve specific
  data. This is required when using the ‘q’ download type.
- `accession`: A character string containing accession numbers. This is
  required when using the ‘a’ download type.
- `format`: A character string specifying the format of the data to
  download. Valid options are ‘READS_FASTQ’, ‘READS_SUBMITTED’,
  ‘ANALYSIS_SUBMITTED’, and ‘ANALYSIS_GENERATED’.
- `location`: A character string specifying the download location. By
  default, it uses the current working directory.
- `email:` A character string specifying the email address for
  notifications. By default, no email is sent.

### Download data using accessions ids

    rena::ena_download("a", accession = "SAMEA3231268,SAMEA3231287", format = "READS_FASTQ", location = "C:/Users/ns651/OneDrive")

### Download data using query

    rena::ena_download("q", query = "result=read_run&query=country=%22Japan%22AND%20depth=168", format = "READS_FASTQ",location = "C:/Users/ns651/OneDrive")

## Issues

For support/issues, please contact us at
<https://www.ebi.ac.uk/ena/browser/support> or drop an issue on the
github.

## Privacy Notice

The execution of this tool may require limited processing of your
personal data to function. By using this tool you are agreeing to this
as outlined in our Privacy Notice:
<https://www.ebi.ac.uk/data-protection/privacy-notice/ena-presentation>
and Terms of Use: <https://www.ebi.ac.uk/about/terms-of-use>.
