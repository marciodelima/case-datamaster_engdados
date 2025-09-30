import os, logging, psycopg2
import pandas as pd
from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential
from datetime import datetime
import azure.functions as func

TABLES = ["clientes", "acoes", "empresas"]

def main(mytimer: func.TimerRequest) -> None:
    try:
        conn = psycopg2.connect(os.environ["POSTGRES_CONN"])
        blob = BlobServiceClient(account_url=os.environ["STORAGE_URL"], credential=DefaultAzureCredential())
        container = blob.get_container_client("dados")

        for table in TABLES:
            df = pd.read_sql(f"SELECT * FROM {table}", conn)
            path = f"raw/postgres/{table}/{datetime.utcnow().isoformat()}.parquet"
            container.get_blob_client(path).upload_blob(df.to_parquet(index=False), overwrite=True)
            logging.info(f"Tabela exportada: {path}")

        conn.close()
    except Exception as e:
        logging.error(f"Erro: {e}")

