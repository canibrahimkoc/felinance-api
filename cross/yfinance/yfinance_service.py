import sys
import json
import yfinance as yf
from datetime import datetime

def get_stock_data(symbol):
    ticker = yf.Ticker(symbol)
    info = json.dumps(ticker.info)
     
    return info

if __name__ == "__main__":
    path = sys.argv[1]
    print(get_stock_data(path))
    