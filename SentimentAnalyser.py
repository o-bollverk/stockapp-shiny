import json

import nltk
from nltk.sentiment import SentimentIntensityAnalyzer

nltk.download('vader_lexicon')
sia = SentimentIntensityAnalyzer()


def update_tweets_with_sentiment(filename="bitcointweet.json"):
    tweets_with_sentiment = []
    with open(filename, 'r+') as f:
        tweets = json.load(f)
        for tweet in tweets:
            sentiment = analyse_sentiment(tweet['text'])
            tweet.update({"sentiment": sentiment})
            tweets_with_sentiment.append(tweet)

            print(tweet)
            print("------------------------------------")

    save_tweets_to_file(filename, tweets_with_sentiment)


def save_tweets_to_file(filename, tweets_with_sentiment):
    with open(filename, 'w') as file:
        json.dump(tweets_with_sentiment, file)


def analyse_sentiment(text):
    return sia.polarity_scores(text)["compound"]


if __name__ == "__main__":
    update_tweets_with_sentiment()
