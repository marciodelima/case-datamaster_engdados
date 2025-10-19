import os
import logging
import fitz
import json
from datetime import datetime
from io import BytesIO

import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq

from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from azure.storage.blob import BlobServiceClient
from openai import AzureOpenAI
import azure.functions as func

def extract_text(pdf_bytes):
    doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    return "\n".join([page.get_text() for page in doc])

def get_openai_client():
    credential = DefaultAzureCredential()
    vault_url = os.environ["KEYVAULT_URI"]
    secret_client = SecretClient(vault_url=vault_url, credential=credential)

    api_key = secret_client.get_secret("OpenAI-Key").value
    endpoint = secret_client.get_secret("OpenAI-Endpoint").value

    return AzureOpenAI(
        api_key=api_key,
        azure_endpoint=endpoint,
        api_version="2023-07-01-preview"
    )

def analyze_ri_report(empresa, texto, client):
    prompt = f"""
    Você é um analista financeiro especializado em ações brasileiras com foco em dividendos. Avalie o relatório de RI da empresa {empresa} com base nos seguintes critérios:

    1. Demonstrações financeiras: receita líquida, Ebitda, lucro líquido, margens.
    2. Desempenho das receitas e lucros do trimestre: crescimento comparado ao período anterior.
    3. Grau de endividamento: nível de dívida e impacto no fluxo de caixa.
    4. Atividade e projeções: novos projetos, estratégias e previsões futuras.
    5. Governança e riscos: estrutura de governança e principais riscos.

    Para cada item, classifique como "bom", "regular" ou "ruim" e justifique brevemente. Ao final, atribua uma nota de desempenho geral de 0 a 10.

    Texto do relatório:
    {texto}

    Responda em português no formato JSON com os campos: "empresa", "trimestre", "avaliacoes", "nota_final"
    """
    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3
        )
        return json.loads(response.choices[0].message.content)
    except Exception as e:
        logging.error(f"Erro ao interpretar resposta do LLM: {e}")
        return {
            "empresa": empresa,
            "trimestre": "desconhecido",
            "avaliacoes": "regular",
            "nota_final": 0
        }

app = func.FunctionApp()

@app.function_name(name="ri_resumer")
@app.schedule(
    schedule="0 30 21 * * 1-5",  # Executa às 21:30 de segunda a sexta
    arg_name="mytimer",
    run_on_startup=False,
    use_monitor=True
)
def main(mytimer: func.TimerRequest) -> None:
    logging.info("Iniciando execução da função ri_resumer")

    try:
        credential = DefaultAzureCredential()
        blob_service = BlobServiceClient(account_url=os.environ["STORAGE_URL"], credential=credential)
        container = blob_service.get_container_client("dados")
        client = get_openai_client()

        blobs = container.list_blobs(name_starts_with="raw/ri/")
        for blob in blobs:
            if not blob.name.endswith(".pdf"):
                continue

            blob_client = container.get_blob_client(blob.name)
            empresa = blob.name.split("/")[2]
            pdf_bytes = blob_client.download_blob().readall()
            texto = extract_text(pdf_bytes)
            resultado = analyze_ri_report(empresa, texto, client)

            trimestre = resultado.get("trimestre", "desconhecido")
            parquet_data = pd.DataFrame([{
                "empresa": resultado["empresa"],
                "trimestre": trimestre,
                "avaliacoes": json.dumps(resultado.get("avaliacoes", {})),
                "nota_final": resultado.get("nota_final", 0),
                "timestamp": datetime.utcnow().isoformat()
            }])

            table = pa.Table.from_pandas(parquet_data)
            buffer = BytesIO()
            pq.write_table(table, buffer)
            buffer.seek(0)

            parquet_path = f"bronze/ri/resultados/{empresa}/ri-{empresa}-{trimestre}.parquet"
            container.get_blob_client(parquet_path).upload_blob(buffer.read(), overwrite=True)
            logging.info(f"Resultado salvo: {parquet_path}")

            # Move o PDF para raw/ri-deleted/
            deleted_path = blob.name.replace("raw/ri/", "raw/ri-deleted/")
            container.get_blob_client(deleted_path).upload_blob(pdf_bytes, overwrite=True)
            blob_client.delete_blob()
            logging.info(f"PDF movido para: {deleted_path}")

    except Exception as e:
        logging.error(f"Erro na função ri_resumer: {e}")

    logging.info("Final da execução da função ri_resumer")

