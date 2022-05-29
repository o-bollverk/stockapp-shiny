# stockapp-shiny

Course project in Cloud Computing and Big Data Analysis
Authors: Oliver Bollverk, Monika Dziedzic, Marjan Haghighat, Esther Mahuza, Carles Torres Garzo

The app is hosted at: http://3.8.186.33:3838/shinyapp/

## Overview

The Shiny app is located at /shinyapp

It consists of 3 files: server.R, ui.R and global.R. Further explanations on the basic structure of Shiny apps: https://shiny.rstudio.com/articles/basics.html

collect_data.R collects scraped data end exports a single csv.
upload_to_S3.py uploads a file to S3 given that aws credentials are setup and boto3 is installed

Scraping is done with:
scrapetweets.py
scrapeprice.py
gather_google_trends_data.R

For sentiment analysis:
SentimentAnalyser.py
use_SentimentAnalyser.py

### Notes on arrow setup

In global.R S3 connection is established using the arrow package. Dependencies can be installed via:
```{R}
source("install_packages.R")
```

For debian systems, arrow with S3 funcionality may be set as:
```{bash}
sudo apt install libssl-dev
sudo apt install libcurl4-openssl-dev 
sudo apt install clang
```

And
```{R}
source("https://raw.githubusercontent.com/apache/arrow/master/r/R/install-arrow.R")
install_arrow()
```

Setup follows the instructions from: https://arrow.apache.org/docs/r/articles/install.html#installation-using-install_arrow

