import pyspark
from pyspark.sql import SparkSession
import pyspark.sql.functions as F
import boto3
import pandas as pd

spark = SparkSession.builder \
    .master('local[4, 2]') \
    .config('spark.driver.memory', '4g') \
    .config('spark.worker.cleanup.enabled', 'true') \
    .config('spark.driver.maxResultSize', '4g') \
    .appName('PySpark').getOrCreate()

s3_client = boto3.client('s3')

s3_client.download_file('ccbda-final-proj', 'tweets_trends_prices_combined.csv', 'tweets_trends_prices_combined.csv')

spark.read.csv("tweets_trends_prices_combined.csv").head()

pd.read_csv("tweets_trends_prices_combined.csv").tail()

# Data processing

combined_df = spark.read.csv("tweets_trends_prices_combined.csv", header=True)
combined_df.head(5)

## Aggregating to calculate price averages

combined_df.dtypes

from pyspark.sql.window import Window

combined_df.select("symbol").distinct().collect()

from pyspark.sql import DataFrame
from functools import reduce

# Mean of price

full_df = []
for window_size in [3, 7, 14]:
    combined_df = combined_df \
        .withColumn("timestamp", F.from_utc_timestamp("time", "GMT").astype('Timestamp').cast("long"))

    days = lambda i: i * 86400

    list_of_stocks = [ "Apple", "Bitcoin", "Tesla"] #"Tesla",
    list_of_dfs = []

    for stock in list_of_stocks:
        selected_df = combined_df \
            .filter(F.col("symbol") == stock) \
            .filter(F.col("value_type") == "stock")

        w = (Window.partitionBy("symbol").orderBy(F.col("Timestamp")).rangeBetween(-days(window_size), 0))

        with_mean = selected_df \
            .withColumn("mean", F.avg(F.col("value")).over(w)) \
            .withColumn("window_size", F.lit(window_size))
        list_of_dfs.append(with_mean)

    current_window_size_df = reduce(DataFrame.unionAll, list_of_dfs).withColumn("window_size", F.lit(window_size))
    full_df.append(current_window_size_df)


window_sizes = [3, 7, 14]

counter = -1
for i in range(3):
    for j in range(3):
        counter = counter + 1
    list_of_dfs[counter].toPandas().to_csv("data_cache/aggregated_price" + "_stock_" + list_of_stocks[j] + "_window_" + str(window_sizes[i]) + ".csv", index = None)

full_df = []
for window_size in [3, 7, 14]:
    combined_df = combined_df \
        .withColumn("timestamp", F.from_utc_timestamp("time", "GMT").astype('Timestamp').cast("long"))

    days = lambda i: i * 86400

    list_of_stocks = [ "Apple", "Bitcoin", "Tesla"] #"Tesla",
    list_of_dfs = []

    for stock in list_of_stocks:
        selected_df = combined_df \
            .filter(F.col("symbol") == stock) \
            .filter(F.col("value_type") == "sentiment")

        w = (Window.partitionBy("symbol").orderBy(F.col("Timestamp")).rangeBetween(-days(window_size), 0))

        with_mean = selected_df \
            .withColumn("mean", F.avg(F.col("value")).over(w)) \
            .withColumn("window_size", F.lit(window_size))
        list_of_dfs.append(with_mean)

    current_window_size_df = reduce(DataFrame.unionAll, list_of_dfs).withColumn("window_size", F.lit(window_size))
    full_df.append(current_window_size_df)

counter = -1

for i in range(3):
    for j in range(3):
        counter = counter + 1
    list_of_dfs[counter].toPandas().to_csv("data_cache/aggregated_sentiment" + "_stock_" + list_of_stocks[j] + "_window_" + str(window_sizes[i]) + ".csv", index = None)



# Pack the files together with pandas and write to current instance

import pandas as pd
import glob

df = pd.concat(map(pd.read_csv, glob.glob("data_cache/aggregated_*.csv")))
df.head()

df.to_csv("data_cache/result_aggregated.csv", index = None)

## Write to current instance, then upload to S3 with boto3

s3_client.upload_file(f"data_cache/result_aggregated.csv",'ccbda-final-proj',
                      f"result_aggregated.csv")