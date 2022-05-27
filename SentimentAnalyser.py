import json


def read_file(filename="bitcointweet.json"):
    with open(filename, 'r') as f:
        tweets = json.load(f)
        for tweet in tweets:
            print(tweet['text'])
            analyse_sentiment(tweet['text'])
            print("------------------------------------")


def analyse_sentiment(text):
    pass


if __name__ == "__main__":
    read_file()
