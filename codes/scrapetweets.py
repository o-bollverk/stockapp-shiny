import os
import tweepy
from tweepy import OAuthHandler
import json
from nltk.tokenize import word_tokenize
import re
import csv

# open the file in the write mode
file = open('data.csv', 'w')

# create the csv writer
writer = csv.DictWriter(file, ['id', 'text','tag', 'timestamp'])
writer.writeheader()

data_to_json = []


# write a row to the csv file
def generate_csv(data):
    try:
        with open('data.csv', 'w') as csv_file:
            w = csv.DictWriter(csv_file)
            w.writerow(data)
    except:
        print(f"Cannot generate csv file!")


# task 2.2.1 Accessing your twitter account information

consumer_key = os.environ['CONSUMER_KEY']
consumer_secret = os.environ['CONSUMER_SECRET']
access_token = os.environ['ACCESS_TOKEN']
access_secret = os.environ['ACCESS_SECRET']

auth = OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_secret)

api = tweepy.API(auth)

user = api.verify_credentials()#.me()


print('Name: ' + user.name)
print('Location: ' + user.location)
print('Followers: ' + str(user.followers_count))
print('Created: ' + str(user.created_at))
print('Description: ' + str(user.description))


# task 2.2.2 Accessing Tweets

for status in tweepy.Cursor(api.home_timeline).items(1):
    pass
    #print(status.text)

for status in tweepy.Cursor(api.home_timeline).items(1):
    print(json.dumps(status._json, indent=2))

for follower in tweepy.Cursor(api.get_followers).items(10):
  print(dict(follower._json)["name"])

for tweet in tweepy.Cursor(api.user_timeline).items(1):
    print(json.dumps(tweet._json, indent=2))


# 2.2.3 Tweet pre-processing

tweet = 'RT @JordiTorresBCN: just an example! :D http://JordiTorres.Barcelona #masterMEI'

print(word_tokenize(tweet))

emoticons_str = r"""
    (?:
        [:=;] # Eyes
        [oO\-]? # Nose (optional)
        [D\)\]\(\]/\\OpP] # Mouth
    )"""

regex_str = [
    emoticons_str,
    r'<[^>]+>', # HTML tags
    r'(?:@[\w_]+)', # @-mentions
    r"(?:\#+[\w_]+[\w\'_\-]*[\w_]+)", # hash-tags
    r'http[s]?://(?:[a-z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-f][0-9a-f]))+', # URLs

    r'(?:(?:\d+,?)+(?:\.?\d+)?)', # numbers
    r"(?:[a-z][a-z'\-_]+[a-z])", # words with - and '
    r'(?:[\w_]+)', # other words
    r'(?:\S)' # anything else
]

tokens_re = re.compile(r'('+'|'.join(regex_str)+')', re.VERBOSE | re.IGNORECASE)
emoticon_re = re.compile(r'^'+emoticons_str+'$', re.VERBOSE | re.IGNORECASE)

def tokenize(s):
    return tokens_re.findall(s)

def preprocess(s, lowercase=False):
    tokens = tokenize(s)
    if lowercase:
        tokens = [token if emoticon_re.search(token) else token.lower() for token in tokens]
    return tokens

tweet = 'RT @JordiTorresBCN: just an example! :D http://JordiTorres.Barcelona #masterMEI'
print(preprocess(tweet))

BEARER_TOKEN = os.environ['BEARER_TOKEN']
VERBOSE_OUTPUT = True
TRACK = "apple"



class MyListener(tweepy.Stream):
    def on_data(self, data):
        try:
            with open(TRACK + '.data', 'a') as f:
                if VERBOSE_OUTPUT: print(json.loads(data)['text'])

                f.write(data.decode("utf-8") + '\n')
                return True
        except BaseException as e:
                print("Error on_data: %s" % str(e))
        return True



    def on_error(self, status):
        print(status)
        return True

# twitter_listener = MyListener(CONSUMER_KEY, CONSUMER_KEY_SECRET, ACCESS_TOKEN, ACCESS_TOKEN_SECRET)
# twitter_listener.filter(track=[TRACK])

# API v2
class MyStreamingClient(tweepy.StreamingClient):
    def on_data(self, data):
        try:
            global writer
            global api
            if VERBOSE_OUTPUT:
                data_ = json.loads(data).get('data')
                data_['text'].replace('\n', ' ')
                status_ = api.get_status(data_['id'])
                data_['timestamp'] = status_.created_at.strftime("%d/%m/%Y, %H:%M:%S")
                print(data_)
                writer.writerow(data_)
                global data_to_json
                data_to_json.append(data_)
                with open('data.json', 'w') as file_json:
                    json.dump(data_to_json, file_json)
            with open(TRACK + '.data', 'a') as f:
                if VERBOSE_OUTPUT:
                    print(json.loads(data).get('data'))
                f.write(data.decode("utf-8") + '\n')
                return True
        except BaseException as e:
            print("Error on_data: %s" % str(e))
        return True

    def on_error(self, status):
        print(status)
        return True


printer = MyStreamingClient(BEARER_TOKEN)
#import pdb; pdb.set_trace()
#printer.delete_rules([rule.id for rule in printer.get_rules().data])
printer.add_rules(tweepy.StreamRule(TRACK + " lang:en"))
printer.filter()



# Alternatively, but still using API v2
def override_on_tweet(tweet):
        print(tweet.text + '\n\n')
        try:
            with open(TRACK + '.data', 'a') as f:
                if VERBOSE_OUTPUT: print(tweet.text + '\n\n')
                f.write(tweet.text + '\n')
                return True
        except BaseException as e:
            print("Error on_tweet: %s" % str(e))
        return True
# streaming_client = tweepy.StreamingClient(BEARER_TOKEN)
# streaming_client.delete_rules([rule.id for rule in streaming_client.get_rules().data])
# streaming_client.add_rules(tweepy.StreamRule(TRACK + " lang:en"))
# streaming_client.on_tweet = override_on_tweet

# streaming_client.filter()


# close the file