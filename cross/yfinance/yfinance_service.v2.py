import sys
import json
import yfinance as yf
from datetime import datetime

def get_stock_data(symbol):
    ticker = yf.Ticker(symbol)
    info = ticker.info
    
    # Tarihsel veriyi çek (son 1 yıllık)
    history = ticker.history(period="1y")
    
    # Tarihsel veriden gerekli bilgileri al
    info['52WeekChange'] = (history['Close'][-1] / history['Close'][0]) - 1
    info['SandP52WeekChange'] = yf.Ticker('^GSPC').history(period="1y")['Close'].pct_change().sum()
    
    return info

def calculate_advanced_indicators(data):
    indicators = {
        "Şirket Bilgileri": {
            "Kısa_Ad": data.get('shortName'),
            "Uzun_Ad": data.get('longName'),
            "Sembol": data.get('symbol'),
            "Sektör": data.get('sector'),
            "Endüstri": data.get('industry'),
            "Tam_Zamanlı_Çalışan_Sayısı": data.get('fullTimeEmployees'),
            "Ülke": data.get('country'),
            "Şehir": data.get('city'),
            "Website": data.get('website'),
            "İş_Özeti": data.get('longBusinessSummary')
        },
        "Fiyat Göstergeleri": {
            "Güncel_Fiyat": data.get('currentPrice'),
            "Önceki_Kapanış": data.get('previousClose'),
            "Açılış": data.get('open'),
            "Günlük_Düşük": data.get('dayLow'),
            "Günlük_Yüksek": data.get('dayHigh'),
            "52_Haftalık_Düşük": data.get('fiftyTwoWeekLow'),
            "52_Haftalık_Yüksek": data.get('fiftyTwoWeekHigh'),
            "50_Günlük_Ortalama": data.get('fiftyDayAverage'),
            "200_Günlük_Ortalama": data.get('twoHundredDayAverage'),
            "52_Haftalık_Değişim": data.get('52WeekChange'),
            "S&P_500_52_Haftalık_Değişim": data.get('SandP52WeekChange')
        },
        "Hacim ve Piyasa Değeri": {
            "Hacim": data.get('volume'),
            "Ortalama_Hacim": data.get('averageVolume'),
            "10_Günlük_Ortalama_Hacim": data.get('averageVolume10days'),
            "Piyasa_Değeri": data.get('marketCap'),
            "Kurumsal_Değer": data.get('enterpriseValue'),
            "Dolaşımdaki_Hisse_Sayısı": data.get('sharesOutstanding'),
            "Halka_Açık_Hisse_Sayısı": data.get('floatShares')
        },
        "Finansal Oranlar": {
            "Fiyat_Kazanç_Oranı": data.get('trailingPE'),
            "İleriye_Dönük_Fiyat_Kazanç_Oranı": data.get('forwardPE'),
            "Fiyat_Satış_Oranı": data.get('priceToSalesTrailing12Months'),
            "Fiyat_Defter_Değeri_Oranı": data.get('priceToBook'),
            "Kurumsal_Değer_Gelir_Oranı": data.get('enterpriseToRevenue'),
            "Kurumsal_Değer_EBITDA_Oranı": data.get('enterpriseToEbitda'),
            "Borç_Özsermaye_Oranı": data.get('debtToEquity'),
            "Cari_Oran": data.get('currentRatio'),
            "Hızlı_Oran": data.get('quickRatio')
        },
        "Karlılık Göstergeleri": {
            "Brüt_Kar_Marjı": data.get('grossMargins'),
            "EBITDA_Marjı": data.get('ebitdaMargins'),
            "Faaliyet_Marjı": data.get('operatingMargins'),
            "Kar_Marjı": data.get('profitMargins'),
            "Özsermaye_Karlılığı_ROE": data.get('returnOnEquity'),
            "Aktif_Karlılığı_ROA": data.get('returnOnAssets')
        },
        "Büyüme ve Nakit Akışı": {
            "Gelir_Büyümesi": data.get('revenueGrowth'),
            "Hisse_Başına_Kazanç_EPS": data.get('trailingEps'),
            "İleriye_Dönük_EPS": data.get('forwardEps'),
            "Serbest_Nakit_Akışı": data.get('freeCashflow'),
            "Faaliyet_Nakit_Akışı": data.get('operatingCashflow'),
            "Toplam_Gelir": data.get('totalRevenue'),
            "Net_Gelir": data.get('netIncomeToCommon')
        },
        "Hisse Senedi Bilgileri": {
            "Hisse_Başına_Defter_Değeri": data.get('bookValue'),
            "Hisse_Başına_Nakit": data.get('totalCashPerShare'),
            "Hisse_Başına_Gelir": data.get('revenuePerShare'),
            "İçeriden_Alınan_Hisse_Yüzdesi": data.get('heldPercentInsiders'),
            "Beta": data.get('beta')
        },
        "Borç ve Nakit Durumu": {
            "Toplam_Nakit": data.get('totalCash'),
            "Toplam_Borç": data.get('totalDebt'),
            "EBITDA": data.get('ebitda')
        },
        "Diğer Göstergeler": {
            "Son_Temettü_Tarihi": data.get('lastDividendDate'),
            "Son_Bölünme_Faktörü": data.get('lastSplitFactor'),
            "Son_Bölünme_Tarihi": data.get('lastSplitDate'),
            "Tavsiye": data.get('recommendationKey'),
            "Borsa": data.get('exchange'),
            "Para_Birimi": data.get('currency')
        }
    }
    
    # Özel indikatörler
    indicators["Özel İndikatörler"] = {
        "Nakit_Borç_Oranı": data['totalCash'] / data['totalDebt'] if data.get('totalDebt') and data['totalDebt'] != 0 else None,
        "Fiyat_Nakit_Akışı_Oranı": data['marketCap'] / data['operatingCashflow'] if data.get('operatingCashflow') and data['operatingCashflow'] != 0 else None,
        "Hisse_Başına_Serbest_Nakit_Akışı": data['freeCashflow'] / data['sharesOutstanding'] if data.get('freeCashflow') and data.get('sharesOutstanding') and data['sharesOutstanding'] != 0 else None,
        "Borç_EBITDA_Oranı": data['totalDebt'] / abs(data['ebitda']) if data.get('ebitda') and data['ebitda'] != 0 else None,
        "Kurumsal_Değer_Serbest_Nakit_Akışı_Oranı": data['enterpriseValue'] / abs(data['freeCashflow']) if data.get('freeCashflow') and data['freeCashflow'] != 0 else None,
        "Fiyat_Satış_Nakit_Akışı_Oranı": (data['marketCap'] / data['totalRevenue']) / (data['operatingCashflow'] / data['totalRevenue']) if data.get('totalRevenue') and data.get('operatingCashflow') and data['totalRevenue'] != 0 and data['operatingCashflow'] != 0 else None,
        "Piotroski_F_Score": calculate_piotroski_f_score(data),
        "Altman_Z_Score": calculate_altman_z_score(data)
    }
    
    return json.dumps(indicators, indent=2, ensure_ascii=False, default=str)

def calculate_piotroski_f_score(data):
    score = 0
    if data.get('netIncomeToCommon', 0) > 0:
        score += 1
    if data.get('operatingCashflow', 0) > 0:
        score += 1
    if data.get('returnOnAssets', 0) > 0:
        score += 1
    if data.get('operatingCashflow', 0) > data.get('netIncomeToCommon', 0):
        score += 1
    if data.get('longTermDebt', 0) < data.get('totalAssets', float('inf')):
        score += 1
    if data.get('currentRatio', 0) > 1:
        score += 1
    if data.get('grossMargins', 0) > 0:
        score += 1
    if data.get('assetTurnover', 0) > data.get('totalAssets', 0):
        score += 1
    return score

def calculate_altman_z_score(data):
    if not data.get('totalAssets') or data['totalAssets'] == 0:
        return None
    
    working_capital = data.get('totalCurrentAssets', 0) - data.get('totalCurrentLiabilities', 0)
    retained_earnings = data.get('retainedEarnings', 0)
    ebit = data.get('ebit', data.get('ebitda', 0))
    market_value_equity = data.get('marketCap', 0)
    book_value_total_liabilities = data.get('totalLiab', 0)
    sales = data.get('totalRevenue', 0)

    z_score = (
        1.2 * (working_capital / data['totalAssets']) +
        1.4 * (retained_earnings / data['totalAssets']) +
        3.3 * (ebit / data['totalAssets']) +
        0.6 * (market_value_equity / book_value_total_liabilities) +
        0.999 * (sales / data['totalAssets'])
    )
    
    return z_score

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(json.dumps({"error": "Lütfen bir hisse senedi sembolü sağlayın"}))
    else:
        symbol = sys.argv[1]
        stock_data = get_stock_data(symbol)
        advanced_indicators = calculate_advanced_indicators(stock_data)
        print(advanced_indicators)