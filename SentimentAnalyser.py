import json

import nltk
from nltk.sentiment import SentimentIntensityAnalyzer
import argparse

nltk.download('vader_lexicon')
sia = SentimentIntensityAnalyzer()
# if you encounter a "year is out of range" error the timestamp
# may be in milliseconds, try `ts /= 1000` in that case

def update_news_with_sentiment(filename="bitcointweet.json"):
    news_with_sentiment = []
    with open(filename, 'r+') as f:
        news = json.load(f)
        for news_item in news:
            sentiment = analyse_sentiment(news_item['desc'])
            news_item.update({"sentiment": sentiment})
            news_item = dict((k, news_item[k]) for k in ('datetime', 'sentiment')) # only needed fields

            news_with_sentiment.append(news_item)

            print(news_item)
            print("------------------------------------")

    save_tweets_to_file(filename[:-5] + "_new.json", news_with_sentiment)

def update_tweets_with_sentiment(filename="bitcointweet.json"):
    tweets_with_sentiment = []
    with open(filename, 'r+') as f:
        tweets = json.load(f)
        for tweet in tweets:
            sentiment = analyse_sentiment(tweet['text'])
            tweet.update({"sentiment": sentiment})
            tweet = dict((k, tweet[k]) for k in ('timestamp', 'sentiment'))
            tweets_with_sentiment.append(tweet)

            print(tweet)
            print("------------------------------------")

    save_tweets_to_file(filename[:-5] + "_new.json", tweets_with_sentiment)


def save_tweets_to_file(filename, tweets_with_sentiment):
    with open(filename, 'w') as file:
        json.dump(tweets_with_sentiment, file)


def analyse_sentiment(text):
    return sia.polarity_scores(text)["compound"]


if __name__ == "__main__":
    update_tweets_with_sentiment()
