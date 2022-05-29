import boto3

data_dir = "/home/revilo/shinyapp-data/"
s3_client = boto3.client('s3')
fname = data_dir + 'tweets_trends_prices_combined.csv'
s3_client.upload_file(fname, 'ccbda-final-proj', 'tweets_trends_prices_combined.csv')

