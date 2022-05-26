packages = c("DT", "shinydashboard",
             "ggrepel", "plotly", "jsonlite", "purrr", "dplyr")

## Now load or install&load all
package.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  }
)

