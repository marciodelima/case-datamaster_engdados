import os
import logging
import json
from io import BytesIO
from datetime import datetime

from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from azure.storage.blob import BlobServiceClient
from openai import AzureOpenAI
from fastavro import reader
from pyspark.sql import SparkSession
import azure.functions as func


def get_openai_client():
    credential = DefaultAzureCredential()
    vault_url = os.environ["KEYVAULT_URI"]
    secret_client = SecretClient(vault_url=vault_url, credential=credential)

    return AzureOpenAI(
        api_key=secret_client.get_secret("OpenAI-Key").value,
        azure_endpoint=secret_client.get_secret("OpenAI-Endpoint").value,
        api_version="2024-07-18"
    )


def analyze_news(title, full_text, client):
    prompt = f"""
    A seguir está uma notícia sobre o mercado financeiro brasileiro:
    Título: {title}
    Texto: {full_text}

    1. Quais ações da B3 estão relacionadas a essa notícia? (Ex: PETR4, VALE3, ITUB4)
    2. Classifique o sentimento da notícia como Positivo, Neutro ou Negativo.
    3. Gere um resumo curto da notícia para ser usado como título.

    Responda em JSON com os campos: "acoes", "sentimento", "resumo"
    """

    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.2
        )
        return json.loads(response.choices[0].message.content)
    except Exception as e:
        logging.warning(f"Erro ao interpretar resposta do LLM: {e}")
        return {"acoes": [], "sentimento": "neutro", "resumo": "Sem resumo"}


def main(mytimer: func.TimerRequest) -> None:
    try:
        credential = DefaultAzureCredential()
        blob_service = BlobServiceClient(account_url=os.environ["STORAGE_URL"], credential=credential)
        container = blob_service.get_container_client("dados")
        namespace = os.environ["EVENTHUB_NAME"]
        blobs = container.list_blobs(name_starts_with=f"raw/noticias/{namespace}/")

        spark = SparkSession.builder.getOrCreate()
        client = get_openai_client()
        resultados = []

        for blob in blobs:
            if not blob.name.endswith(".avro"):
                continue

            blob_client = container.get_blob_client(blob.name)
            avro_bytes = blob_client.download_blob().readall()
            records = list(reader(BytesIO(avro_bytes)))

            for record in records:
                title = record.get("titulo", "")
                full_text = f"{title} {record.get('conteudo', '')}"
                resultado = analyze_news(title, full_text, client)

                for acao in resultado["acoes"]:
                    resultados.append((acao, resultado["resumo"], resultado["sentimento"], datetime.utcnow().isoformat()))

            try:
                blob_client.delete_blob()
                logging.info(f"Arquivo deletado: {blob.name}")
            except Exception as e:
                logging.warning(f"Erro ao deletar {blob.name}: {e}")

        if resultados:
            df = spark.createDataFrame(resultados, ["acao", "resumo", "sentimento", "timestamp"])
            bronze_path = os.environ["BRONZE_PATH"]

            for acao in df.select("acao").distinct().rdd.flatMap(lambda x: x).collect():
                df.filter(df.acao == acao).write.mode("append").parquet(f"{bronze_path}/{acao}/sentimento.parquet")

            logging.info(f"{len(resultados)} análises de sentimento gravadas.")
        else:
            logging.info("Nenhuma notícia processada.")

    except Exception as e:
        logging.error(f"Erro na função de análise de sentimento: {e}")

