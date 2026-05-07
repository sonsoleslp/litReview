# Import Data from a Google Drive URL

Downloads an Excel file from a URL and reads a specified sheet.

## Usage

``` r
import_from_google_drive(url, sheet)
```

## Arguments

- url:

  Character. The download URL for the Excel file.

- sheet:

  Character or integer. The sheet name or index to read.

## Value

A data frame with the contents of the specified sheet.

## Examples

``` r
if (FALSE) { # \dontrun{
df <- import_from_google_drive(
  "https://drive.google.com/uc?export=download&id=FILE_ID",
  sheet = 1
)
} # }
```
