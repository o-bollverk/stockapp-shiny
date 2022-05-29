import json
import nltk
from nltk.sentiment import SentimentIntensityAnalyzer
import SentimentAnalyser
from SentimentAnalyser import update_tweets_with_sentiment
from SentimentAnalyser import update_news_with_sentiment

data_dir = "/home/revilo/shinyapp-data/"
list_of_files = ["bitcointweet.json"]
list_of_files = [data_dir + x for x in list_of_files]

for filename in list_of_files:
    print(filename)
    update_tweets_with_sentiment(filename)

list_of_files = ["Bitcoin.json", "Apple.json", "Tesla.json"]
list_of_files = [data_dir + x for x in list_of_files]

for filename in list_of_files:
    print(filename)
    update_news_with_sentiment(filename)
