import os
import logging
import json
import time
from datetime import datetime
from io import BytesIO

import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq

from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from azure.storage.blob import BlobServiceClient
from openai import AzureOpenAI
from typing import List
import azure.functions as func
import azurefunctions.extensions.bindings.eventhub as eh
import re

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

def get_openai_client():
    credential = DefaultAzureCredential()
    vault_url = os.environ["KEYVAULT_URI"]
    secret_client = SecretClient(vault_url=vault_url, credential=credential)

    api_key = secret_client.get_secret("OpenAI-Key").value
    endpoint = secret_client.get_secret("OpenAI-Endpoint").value

    return AzureOpenAI(
        api_key=api_key,
        azure_endpoint=endpoint,
        api_version="2024-12-01-preview"
    )

def analyze_news(title, full_text, client):
    prompt = f"""
    A seguir está uma notícia sobre o mercado financeiro brasileiro:
    Título: {title:1000}
    Texto: {full_text:3000}

    1. Quais ações da B3 estão relacionadas a essa notícia? (Ex: PETR4, VALE3, ITUB4)
    2. Classifique o sentimento da notícia como Positivo, Neutro ou Negativo.
    3. Gere um resumo curto da notícia para ser usado como título.
    4. Caso a notícia não seja de uma ação brasileira ou caso não seja classificado a ação ou empresa, responda sentimento neutro e a acoes com o valor NA.
    5. Caso a notícia tenha conteúdo de racismo, sexual, intolerância responda sentimento neuto e a acoes com o valor NA. 

    Responda em português no formato JSON com os campos e valores: "acoes", "sentimento", "resumo"
    """
    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            max_tokens=1024,
            top_p=1.0
        )
        raw_content = response.choices[0].message.content.strip()
        if raw_content.startswith("```json"):
            raw_content = re.sub(r"^```json\s*", "", raw_content)
            raw_content = re.sub(r"\s*```$", "", raw_content)            
        
        return json.loads(raw_content)
    except Exception as e:
        logging.error(f"Erro ao interpretar resposta do LLM: {e}")
        return {"acoes": ["NA"], "sentimento": "neutro", "resumo": "Sem resumo"}

@app.function_name(name="eventhub_trigger")
@app.event_hub_message_trigger(
    arg_name="events",
    event_hub_name="noticias_investimentos",
    connection="EVENTHUB_CONNECTION",
    cardinality="many"
)
def eventhub_trigger(events: List[eh.EventData]):
    logging.info(f"Iniciando processamento de {len(events)} eventos")

    try:
        credential = DefaultAzureCredential()
        blob_service = BlobServiceClient(account_url=os.environ["STORAGE_URL"], credential=credential)
        container = blob_service.get_container_client("dados")
        client = get_openai_client()

        resultados = []
        for event in events[:10]:  # micro-batch de até 10 mensagens
            try:
                body = event.get_body().decode("utf-8")
                record = json.loads(body)
                title = record.get("titulo", "")
                full_text = f"{title} {record.get('conteudo', '')}"
                resultado = analyze_news(title, full_text, client)

                for acao in resultado["acoes"]:
                    resultados.append({
                        "acao": acao,
                        "resumo": resultado["resumo"],
                        "sentimento": resultado["sentimento"],
                        "timestamp": datetime.utcnow().isoformat()
                    })
                time.sleep(10)
            except Exception as e:
                logging.error(f"Erro ao processar evento: {e}")

        if resultados:
            df = pd.DataFrame(resultados)
            bronze_path = os.environ["DELTA_PATH"]

            for acao in df["acao"].unique():
                df_acao = df[df["acao"] == acao]
                table = pa.Table.from_pandas(df_acao)
                buffer = BytesIO()
                pq.write_table(table, buffer)
                buffer.seek(0)

                blob_path = f"{bronze_path}/{acao}/sentimento_{acao}.parquet"
                container.get_blob_client(blob_path).upload_blob(buffer.read(), overwrite=True)
                logging.info(f"Arquivo salvo: {blob_path}")

            logging.info(f"{len(resultados)} análises de sentimento gravadas.")
        else:
            logging.info("Nenhuma notícia processada.")

    except Exception as e:
        logging.error(f"Erro na função de streaming: {e}")

