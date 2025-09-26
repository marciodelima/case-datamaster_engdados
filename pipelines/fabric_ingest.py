import requests
import psycopg2
import os
from azure.identity import DefaultAzureCredential

# Autenticação via Managed Identity
credential = DefaultAzureCredential()
access_token = credential.get_token("https://ossrdbms-aad.database.windows.net").token

conn = psycopg2.connect(
    host=os.getenv("PG_HOST"),
    dbname="ri_core",
    user=os.getenv("PG_USER"),
    password=access_token,
    sslmode="require"
)

cur = conn.cursor()
cur.execute("SELECT ticker, link_relatorio FROM acoes")
acoes = cur.fetchall()

for ticker, url in acoes:
    response = requests.get(url)
    if response.status_code == 200:
        with open(f"/lakehouse/raw/{ticker}.pdf", "wb") as f:
            f.write(response.content)
        print(f"{ticker} salvo na camada raw.")
    else:
        print(f"Erro ao baixar {ticker}: {response.status_code}")

