import os
import logging
import requests
import psycopg2
from urllib.parse import unquote

from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from azure.storage.blob import BlobServiceClient
import azure.functions as func

requests.Session.verify = False

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

@app.function_name(name="ri_collector")
@app.schedule(
    schedule="0 30 21 * * 1-5",
    arg_name="mytimerricollector",
    run_on_startup=True,
    use_monitor=True
)
def main(mytimerricollector: func.TimerRequest) -> None:
    logging.info("Iniciando execução da função ri_collector")

    try:
        credential = DefaultAzureCredential()
        blob = BlobServiceClient(account_url=os.environ["STORAGE_URL"], credential=credential)
        container = blob.get_container_client("dados")
        secret_client = get_secret_client()
    except Exception as e:
        logging.error(f"Erro ao configurar acesso ao Blob Storage ou Key Vault: {e}")
        return

    try:
        conn_str = get_postgres_connection_string(secret_client)
        conn = psycopg2.connect(conn_str)
        cursor = conn.cursor()
        cursor.execute("SELECT empresa, link_relatorio FROM acoes WHERE link_relatorio IS NOT NULL")
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
    except Exception as e:
        logging.error(f"Erro ao acessar PostgreSQL: {e}")
        return

    for empresa, url in rows:
        try:
            r = requests.get(url, verify=False)
            if r.status_code == 200:
                path = f"raw/ri/{empresa}/{empresa}-ri.pdf"
                container.get_blob_client(path).upload_blob(r.content, overwrite=True)
                logging.info(f"PDF salvo: {path}")
            else:
                logging.warning(f"Falha ao baixar PDF de {empresa}: {url}")
        except Exception as e:
            logging.error(f"Erro ao processar {empresa}: {e}")

    logging.info("Final da execução da função ri_collector")

