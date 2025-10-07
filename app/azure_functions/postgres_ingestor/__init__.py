import os
import logging
import psycopg2
import pandas as pd
from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from datetime import datetime
import azure.functions as func

TABLES = ["clientes", "acoes", "carteiras", "renda_financeira"]

def get_pg_connection_string():
    try:
        credential = DefaultAzureCredential()
        kv_url = os.environ["KEYVAULT_URL"]
        client = SecretClient(vault_url=kv_url, credential=credential)
        return client.get_secret("Postgres-Conn").value
    except Exception as e:
        logging.error(f"Erro ao acessar Key Vault: {e}")
        raise

def main(mytimer: func.TimerRequest) -> None:
    try:
        # Conexão com PostgreSQL via AKV
        conn_str = get_pg_connection_string()
        conn = psycopg2.connect(conn_str)

        # Conexão com Blob Storage
        blob = BlobServiceClient(account_url=os.environ["STORAGE_URL"], credential=DefaultAzureCredential())
        container = blob.get_container_client("dados")

        # Exportação das tabelas
        for table in TABLES:
            try:
                df = pd.read_sql(f"SELECT * FROM {table}", conn)
                path = f"raw/postgres/{table}/{datetime.utcnow().isoformat()}.parquet"
                container.get_blob_client(path).upload_blob(df.to_parquet(index=False), overwrite=True)
                logging.info(f"Tabela exportada: {path}")
            except Exception as e:
                logging.error(f"Erro ao exportar tabela {table}: {e}")

        conn.close()
    except Exception as e:
        logging.error(f"Erro geral na função: {e}")
