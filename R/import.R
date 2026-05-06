#' Import Data from a Google Drive URL
#'
#' Downloads an Excel file from a URL and reads a specified sheet.
#'
#' @param url Character. The download URL for the Excel file.
#' @param sheet Character or integer. The sheet name or index to read.
#'
#' @return A data frame with the contents of the specified sheet.
#'
#' @examples
#' \dontrun{
#' df <- import_from_google_drive(
#'   "https://drive.google.com/uc?export=download&id=FILE_ID",
#'   sheet = 1
#' )
#' }
#'
#' @export
import_from_google_drive <- function(url, sheet) {
  destfile <- tempfile(fileext = ".xlsx")
  on.exit(unlink(destfile), add = TRUE)

  utils::download.file(url, destfile, mode = "wb", cacheOK = FALSE)
  rio::import(destfile, which = sheet)
}
