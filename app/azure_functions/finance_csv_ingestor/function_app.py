import os
import logging
import requests
import pandas as pd
from datetime import datetime
from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import azure.functions as func
import psycopg2
import yfinance as yf

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
        kv_url = os.environ["KEYVAULT_URI"]
        client = SecretClient(vault_url=kv_url, credential=credential)

        conn_str = client.get_secret("Postgres-Conn").value
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
        stock = yf.Ticker(ticker)
        df = stock.history(period="1y", interval="1d")
        if df.empty:
            logging.warning(f"Sem dados para {ticker}")
            return
        df.reset_index(inplace=True)
        csv_bytes = df.to_csv(index=False).encode("utf-8")
        path = f"raw/financeiro/b3/historico/{ticker}/historico.csv"
        container.get_blob_client(path).upload_blob(csv_bytes, overwrite=True)
        logging.info(f"Dados históricos salvos: {path}")
    except Exception as e:
        logging.error(f"Erro ao baixar dados de {ticker}: {e}")

app = func.FunctionApp()

@app.function_name(name="finance_csv_ingestor")
@app.schedule(schedule="0 */5 * * * *", arg_name="mytimer", run_on_startup=True, use_monitor=True)
def main(mytimer: func.TimerRequest) -> None:
    logging.info("Iniciando execução da função finance_csv_ingestor")
    try:
        credential = DefaultAzureCredential()
        blob = BlobServiceClient(account_url=os.environ["STORAGE_URL"], credential=credential)
        container = blob.get_container_client("dados")
    except Exception as e:
        logging.error(f"Erro ao configurar acesso ao Blob Storage: {e}")
        return

    try:
        download_and_upload(
            "https://api.bcb.gov.br/dados/serie/bcdata.sgs.4189/dados/ultimos/1?formato=csv",
            "raw/financeiro/bacen/selic.csv",
            container
        )

        download_and_upload(
            "https://raw.githubusercontent.com/marciodelima/case-datamaster_engdados/main/app/data/acoes-listadas-b3.csv",
            "raw/financeiro/b3/acoes-listadas-b3.csv",
            container
        )
    except Exception as e:
        logging.error(f"Erro ao baixar CSVs: {e}")

    try:
        tickers = get_pg_tickers()
        for ticker in tickers:
            fetch_yahoo_data(ticker, container)
    
    except Exception as e:
        logging.error(f"Erro na ingestão financeira: {e}")
    
    logging.info("Final da execução da função finance_csv_ingestor")

