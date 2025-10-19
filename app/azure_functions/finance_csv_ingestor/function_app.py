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
from urllib.parse import unquote

requests.Session.verify = False

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

def get_secret_client():
    credential = DefaultAzureCredential()
    vault_url = os.environ["KEYVAULT_URI"]
    return SecretClient(vault_url=vault_url, credential=credential)

def get_postgres_connection_string(secret_client, secret_name="Postgres-Conn") -> str:
    raw_dsn = secret_client.get_secret(secret_name).value
    raw_dsn = unquote(raw_dsn)
    dsn_parts = {
        "Host": "host",
        "Port": "port",
        "Database": "dbname",
        "User Id": "user",
        "Password": "password",
        "Ssl Mode": "sslmode"
    }

    for old, new in dsn_parts.items():
        raw_dsn = raw_dsn.replace(f"{old}=", f"{new}=")

    raw_dsn = raw_dsn.replace("sslmode=Require", "sslmode=require")
    conn_str = raw_dsn.replace(";", " ")
    return conn_str

def get_pg_tickers(secret_client):
    try:
        conn_str = get_postgres_connection_string(secret_client)
        conn = psycopg2.connect(conn_str)
        cur = conn.cursor()
        cur.execute("SELECT ticker FROM acoes")
        tickers = [row[0] for row in cur.fetchall()]
        cur.close()
        conn.close()
        return tickers
    except Exception as e:
        logging.error(f"Erro ao acessar PostgreSQL: {e}")
        return []

def fetch_brapi_data(ticker, container, secret_client):
    try:
        api_key = secret_client.get_secret("brapi-dev-apikey").value
        url = f"https://brapi.dev/api/quote/{ticker}?interval=1d&range=1mo"
        headers = {"Authorization": f"Bearer {api_key}"}

        response = requests.get(url, headers=headers, timeout=10, verify=False)
        if response.status_code != 200:
            logging.warning(f"Falha ao buscar {ticker}: {response.status_code}")
            return

        data = response.json()
        candles = data.get("results", [{}])[0].get("historicalDataPrice", [])
        if not candles:
            logging.warning(f"Sem dados históricos para {ticker}")
            return

        df = pd.DataFrame(candles)
        df = df[["date", "open", "close", "high", "low", "volume"]]
        csv_bytes = df.to_csv(index=False).encode("utf-8")

        path = f"raw/financeiro/b3/historico/{ticker}/historico.csv"
        container.get_blob_client(path).upload_blob(csv_bytes, overwrite=True)
        logging.info(f"Dados históricos salvos: {path}")
    except Exception as e:
        logging.error(f"Erro ao baixar dados de {ticker}: {e}")

app = func.FunctionApp()

@app.function_name(name="finance_csv_ingestor")
@app.schedule(schedule="0 0 8 * * 1-5", arg_name="mytimer", run_on_startup=True, use_monitor=True)
def main(mytimer: func.TimerRequest) -> None:
    logging.info("Iniciando execução da função finance_csv_ingestor")

    try:
        credential = DefaultAzureCredential()
        blob = BlobServiceClient(account_url=os.environ["STORAGE_URL"], credential=credential)
        container = blob.get_container_client("dados")
        secret_client = get_secret_client()
    except Exception as e:
        logging.error(f"Erro ao configurar acesso ao Blob Storage ou Key Vault: {e}")
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
        tickers = get_pg_tickers(secret_client)
        for ticker in tickers:
            fetch_brapi_data(ticker, container, secret_client)
    except Exception as e:
        logging.error(f"Erro na ingestão financeira: {e}")

    logging.info("Final da execução da função finance_csv_ingestor")

