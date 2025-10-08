import os
import logging
import requests
import psycopg2
from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import azure.functions as func

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
        cursor = conn.cursor()
        cursor.execute("SELECT empresa, link_relatorio FROM acoes WHERE link_relatorio IS NOT NULL")
        rows = cursor.fetchall()
        cursor.close()
        conn.close()

        # Conexão com Blob Storage
        blob = BlobServiceClient(account_url=os.environ["STORAGE_URL"], credential=DefaultAzureCredential())
        container = blob.get_container_client("dados")

        # Download e upload dos PDFs
        for empresa, url in rows:
            try:
                r = requests.get(url, timeout=10, verify=False)
                if r.status_code == 200 and r.headers.get("Content-Type", "").lower().startswith("application/pdf"):
                    path = f"raw/ri/{empresa}/{empresa}-ri.pdf"
                    container.get_blob_client(path).upload_blob(r.content, overwrite=True)
                    logging.info(f"PDF salvo: {path}")
                else:
                    logging.warning(f"Falha ao baixar PDF de {empresa}: {url}")
            except Exception as e:
                logging.error(f"Erro ao processar {empresa}: {e}")

    except Exception as e:
        logging.error(f"Erro geral na função: {e}")

