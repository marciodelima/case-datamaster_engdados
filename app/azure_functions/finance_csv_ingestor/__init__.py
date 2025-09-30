import os
import logging
import requests
import pandas as pd
from datetime import datetime
from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential
import azure.functions as func
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

def fetch_yahoo_data(ticker, container):
    try:
        df = yf.download(ticker, period="1y", interval="1d")
        csv_bytes = df.to_csv(index=True).encode("utf-8")
        path = f"raw/financeiro/historico/{ticker}/historico.csv"
        container.get_blob_client(path).upload_blob(csv_bytes, overwrite=True)
        logging.info(f"Dados Historicos salvos: {path}")
    except Exception as e:
        logging.error(f"Erro Yahoo Finance {ticker}: {e}")

def main(mytimer: func.TimerRequest) -> None:
    try:
        credential = DefaultAzureCredential()
        blob = BlobServiceClient(account_url=os.environ["STORAGE_URL"], credential=credential)
        container = blob.get_container_client("dados")

        # CVM - Fundos de investimento
        download_and_upload(
            "https://dados.cvm.gov.br/dados/FI/CAD/DADOS/cad_fi.csv",
            "raw/financeiro/cvm/fundos.csv",
            container
        )

        # BACEN - Indicadores econômicos
        download_and_upload(
            "https://api.bcb.gov.br/dados/serie/bcdata.sgs.11/dados?formato=csv",  # Selic
            "raw/financeiro/bacen/selic.csv",
            container
        )

        # B3 - Empresas listadas
        download_and_upload(
            "https://www.b3.com.br/pesquisapregao/download?file=listed_companies.csv",
            "raw/financeiro/b3/empresas.csv",
            container
        )

        # Yahoo Finance - Cotações históricas
        for ticker in ["PETR4.SA", "VALE3.SA", "ITUB4.SA"]:
            fetch_yahoo_data(ticker, container)


    except Exception as e:
        logging.error(f"Erro na ingestão financeira: {e}")

