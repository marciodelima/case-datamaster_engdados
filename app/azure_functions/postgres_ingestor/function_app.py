import os
import logging
import psycopg2
import pandas as pd
from urllib.parse import unquote
from datetime import datetime

from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from azure.storage.blob import BlobServiceClient
import azure.functions as func

TABLES = ["clientes", "acoes", "carteiras", "renda_financeira"]

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

app = func.FunctionApp()

@app.function_name(name="postgres_ingestor")
@app.schedule(
    schedule="0 0 6 * * 1-5",
    arg_name="mytimerpostgre",
    run_on_startup=True,
    use_monitor=True
)
def main(mytimerpostgre: func.TimerRequest) -> None:
    logging.info("Iniciando execução da função postgres_ingestor")

    try:
        credential = DefaultAzureCredential()
        blob = BlobServiceClient(account_url=os.environ["STORAGE_URL"], credential=credential)
        container = blob.get_container_client("dados")
        secret_client = get_secret_client()

        conn_str = get_postgres_connection_string(secret_client)
        conn = psycopg2.connect(conn_str)

        for table in TABLES:
            try:
                df = pd.read_sql(f"SELECT * FROM {table}", conn)
                path = f"raw/postgres/{table}/{table}.parquet"
                container.get_blob_client(path).upload_blob(df.to_parquet(index=False), overwrite=True)
                logging.info(f"Tabela exportada: {path}")
            except Exception as e:
                logging.error(f"Erro ao exportar tabela {table}: {e}")

        conn.close()
    except Exception as e:
        logging.error(f"Erro geral na função: {e}")

    logging.info("Final da execução da função postgres_ingestor")


