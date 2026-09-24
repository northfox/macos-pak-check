# Usage: Rscript probe.R <mode>   mode = both | ppm-only | cran-only
mode <- commandArgs(TRUE)[1]
ppm <- "https://packagemanager.posit.co/cran/latest"
cran <- "https://cran.rstudio.com"
options(repos = switch(mode,
  "both" = c(RSPM = ppm, CRAN = cran),
  "ppm-only" = c(CRAN = ppm),
  "cran-only" = c(CRAN = cran)))
print(getOption("repos"))
magic <- function(f) if (file.exists(f)) paste(readBin(f, "raw", 4), collapse = "") else "missing"
fmt <- function(m) if (startsWith(m, "1f8b")) "gzip" else if (m == "28b52ffd") "zstd" else paste0("BROKEN(", m, ")")
pak::cache_clean()
d <- as.data.frame(pak::pkg_download(c("sf", "knitr", "terra"), dest_dir = tempfile()))
d$src <- vapply(d$sources, `[`, "", 1)
d$magic <- vapply(d$fulltarget, function(f) fmt(magic(f)), "")
print(d[, c("package", "platform", "src", "fulltarget", "magic")], right = FALSE)
cat("duplicated fulltarget:", sum(duplicated(d$fulltarget)), "\n")
cat("RESULT", mode, if (all(d$magic %in% c("gzip"))) "OK" else "BROKEN", "\n")
