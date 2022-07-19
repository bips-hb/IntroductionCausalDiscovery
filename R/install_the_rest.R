#' Installs pcalg and bnlearn
#' 
#' @importFrom utils install.packages
#' @importFrom BiocManager install
#'
#' @export
#'
#' @examples
#' #install_the_rest()
install_the_rest <- function(){
  
  Sys.setenv(DOWNLOAD_STATIC_LIBV8 = 1)
  utils::install.packages("V8")
  utils::install.packages("dagitty")

  if (!requireNamespace("BiocManager", quietly = TRUE))
    utils::install.packages("BiocManager")

  BiocManager::install("RBGL")
  BiocManager::install("graph")
  BiocManager::install("Rgraphviz")

  install.packages(c("pcalg", "bnlearn", "kpcalg", "gRbase"))
}
