import os, logging, requests, psycopg2
from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential
import azure.functions as func

def main(mytimer: func.TimerRequest) -> None:
    try:
        conn = psycopg2.connect(os.environ["POSTGRES_CONN"])
        cursor = conn.cursor()
        cursor.execute("SELECT empresa, url_pdf FROM relatorios_ri WHERE ativo = true")
        rows = cursor.fetchall()
        cursor.close()
        conn.close()

        blob = BlobServiceClient(account_url=os.environ["STORAGE_URL"], credential=DefaultAzureCredential())
        container = blob.get_container_client("dados")

        for empresa, url in rows:
            r = requests.get(url)
            if r.status_code == 200:
                path = f"raw/ri/{empresa}/ri-trimestre.pdf"
                container.get_blob_client(path).upload_blob(r.content, overwrite=True)
                logging.info(f"PDF salvo: {path}")
            else:
                logging.warning(f"Erro ao baixar {empresa}: {url}")
    except Exception as e:
        logging.error(f"Erro: {e}")

