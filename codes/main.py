from GoogleNews import GoogleNews
import pandas as pd
from newspaper import Article
from newspaper import Config
import nltk

nltk.download('punkt')
user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'
config = Config()
config.browser_user_agent = user_agent


NAME = 'Bitcoin'
googlenews=GoogleNews(
  # start='01/01/2020',
  # end='01/31/2020',
  period='150d',
  lang='en',
)
googlenews.set_encode('utf-8')

data = []
googlenews.search(NAME)
result=googlenews.result()
for i in range(2, 30):
  googlenews.getpage(i)
  result=googlenews.result()
  df=pd.DataFrame(result)
  buffer = df.to_dict('records')
  for j in buffer:
    data.append(j)

results = pd.DataFrame(data)
results.to_csv(f'{NAME}.csv')
results.to_excel(f'{NAME}.xlsx')
results.to_json(f'{NAME}.json', orient='records')