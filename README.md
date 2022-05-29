# stockapp-shiny

Course project in Cloud Computing and Big Data Analysis
Authors: Oliver Bollverk, Monika Dziedzic, Marjan Haghighat, Esther Mahuza, Carles Torres Garzo

The app is hosted at: http://3.8.186.33:3838/shinyapp/

## Overview

![dataflow](https://user-images.githubusercontent.com/65232333/170896480-6832e312-75e2-41d3-8980-cd842761fd8d.png)

The Shiny app is located at /shinyapp

It consists of 3 files: server.R, ui.R and global.R. Further explanations on the basic structure of Shiny apps: https://shiny.rstudio.com/articles/basics.html

collect_data.R collects scraped data end exports a single csv. <br>
upload_to_S3.py uploads a file to S3 given that aws credentials are setup and boto3 is installed

Scraping is done with:
scrapetweets.py <br>
scrapeprice.py <br>
gather_google_trends_data.R <br>

For sentiment analysis:
SentimentAnalyser.py <br>
use_SentimentAnalyser.py <br>

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

