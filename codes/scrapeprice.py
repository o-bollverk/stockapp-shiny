import yfinance as yf
import matplotlib.pyplot as plt
import pandas as pd

NAME = 'TSLA'
data = yf.download(
		tickers=[f'{NAME}'],
		# use "period" instead of start/end
		# valid periods: 1d,5d,1mo,3mo,6mo,1y,2y,5y,10y,ytd,max
		# (optional, default is '1mo')
		period="2mo",
		# fetch data by interval (including intraday if period < 60 days)
		# valid intervals: 1m,2m,5m,15m,30m,60m,90m,1h,1d,5d,1wk,1mo,3mo
       	# (optional, default is '1d')
		interval="1h")
# Plot the close prices
dataserie = data.Close
dataframe = pd.DataFrame({'timestamp': dataserie.index, 'price': dataserie.values})
dataframe['timestamp'] = dataframe['timestamp'].dt.strftime("%d-%m-%Y, %H:%M:%S")
dataframe.to_json(f'{NAME}.json', orient='records')
dataframe.to_csv(f'{NAME}.csv', index=False)
data.Close.plot()
plt.show()