import os
import logging
import requests
import pandas as pd
from datetime import datetime
from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential
import azure.functions as func
import psycopg2
from yahoofinance import HistoricalPrices, DataEvent, DataFrequency, Locale

def download_and_upload(url, path, container):
    try:
        r = requests.get(url, verify=False)
        if r.status_code == 200:
            container.get_blob_client(path).upload_blob(r.content, overwrite=True)
            logging.info(f"Arquivo salvo: {path}")
        else:
            logging.warning(f"Falha ao baixar: {url}")
    except Exception as e:
        logging.error(f"Erro ao processar {url}: {e}")

def get_pg_tickers():
    try:
        credential = DefaultAzureCredential()
        kv_url = os.environ["KEYVAULT_URL"]
        from azure.keyvault.secrets import SecretClient
        client = SecretClient(vault_url=kv_url, credential=credential)

        conn_str = client.get_secret("pg-connection-string").value
        conn = psycopg2.connect(conn_str)
        cur = conn.cursor()
        cur.execute("SELECT ticker FROM acoes")
        tickers = [row[0] + ".SA" for row in cur.fetchall()]
        cur.close()
        conn.close()
        return tickers
    except Exception as e:
        logging.error(f"Erro ao acessar PostgreSQL: {e}")
        return []

def fetch_yahoo_data(ticker, container):
    try:
        req = HistoricalPrices(
            instrument=ticker,
            start_date=datetime.now().replace(year=datetime.now().year - 1),
            end_date=datetime.now(),
            event=DataEvent.HISTORICAL_PRICES,
            frequency=DataFrequency.DAILY,
            locale=Locale.BRAZIL
        )
        df = pd.DataFrame(req.as_dict())
        csv_bytes = df.to_csv(index=False).encode("utf-8")
        path = f"raw/financeiro/b3/historico/{ticker}/historico.csv"
        container.get_blob_client(path).upload_blob(csv_bytes, overwrite=True)
        logging.info(f"Dados históricos salvos: {path}")
    except Exception as e:
        logging.error(f"Erro ao baixar dados de {ticker}: {e}")

def main(mytimer: func.TimerRequest) -> None:
    try:
        credential = DefaultAzureCredential()
        blob = BlobServiceClient(account_url=os.environ["STORAGE_URL"], credential=credential)
        container = blob.get_container_client("dados")

        # BACEN - Indicadores econômicos
        download_and_upload(
            "https://api.bcb.gov.br/dados/serie/bcdata.sgs.4189/dados/ultimos/1?formato=csv",
            "raw/financeiro/bacen/selic.csv",
            container
        )

        # B3 - Empresas listadas
        download_and_upload(
            "https://raw.githubusercontent.com/marciodelima/case-datamaster_engdados/main/app/data/acoes-listadas-b3.csv",
            "raw/financeiro/b3/acoes-listadas-b3.csv",
            container
        )

        # PostgreSQL → lista de ações
        tickers = get_pg_tickers()
        for ticker in tickers:
            fetch_yahoo_data(ticker, container)

    except Exception as e:
        logging.error(f"Erro na ingestão financeira: {e}")

