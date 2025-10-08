import os
import logging
import fitz
import json
from datetime import datetime
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from azure.storage.blob import BlobServiceClient
from openai import AzureOpenAI
from pyspark.sql import SparkSession
import azure.functions as func


def extract_text(pdf_bytes):
    doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    return "\n".join([page.get_text() for page in doc])


def get_openai_client():
    credential = DefaultAzureCredential()
    vault_url = os.environ["KEYVAULT_URI"]
    secret_client = SecretClient(vault_url=vault_url, credential=credential)

    return AzureOpenAI(
        api_key=secret_client.get_secret("OpenAI-Key").value,
        azure_endpoint=secret_client.get_secret("OpenAI-Endpoint").value,
        api_version="2024-07-18"
    )


def analyze_ri_report(empresa, texto, client):
    prompt = f"""
    Você é um analista financeiro especializado em ações brasileiras com foco em dividendos. Avalie o relatório de RI da empresa {empresa} com base nos seguintes critérios:

    1. Demonstrações financeiras: receita líquida, Ebitda, lucro líquido, margens.
    2. Desempenho das receitas e lucros: crescimento comparado ao período anterior.
    3. Grau de endividamento: nível de dívida e impacto no fluxo de caixa.
    4. Atividade e projeções: novos projetos, estratégias e previsões futuras.
    5. Governança e riscos: estrutura de governança e principais riscos.

    Para cada item, classifique como "bom", "regular" ou "ruim" e justifique brevemente. Ao final, atribua uma nota de desempenho geral de 0 a 10.

    Texto do relatório:
    {texto}

    Responda em JSON com os campos: "empresa", "trimestre", "avaliacoes", "nota_final"
    """

    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3
        )
        return json.loads(response.choices[0].message.content)
    except Exception as e:
        logging.warning(f"Erro ao interpretar resposta do LLM: {e}")
        return {
            "empresa": empresa,
            "trimestre": "desconhecido",
            "avaliacoes": {},
            "nota_final": 0
        }


def main(mytimer: func.TimerRequest) -> None:
    try:
        credential = DefaultAzureCredential()
        blob_service = BlobServiceClient(account_url=os.environ["STORAGE_URL"], credential=credential)
        container = blob_service.get_container_client("dados")
        blobs = container.list_blobs(name_starts_with="raw/ri/")

        spark = SparkSession.builder.getOrCreate()
        client = get_openai_client()
        resultados = []

        for blob in blobs:
            if not blob.name.endswith(".pdf"):
                continue

            blob_client = container.get_blob_client(blob.name)
            empresa = blob.name.split("/")[2]
            pdf_bytes = blob_client.download_blob().readall()
            texto = extract_text(pdf_bytes)
            resultado = analyze_ri_report(empresa, texto, client)

            resultados.append((
                resultado["empresa"],
                resultado.get("trimestre", "2T25"),
                json.dumps(resultado.get("avaliacoes", {})),
                resultado.get("nota_final", 5),
                datetime.utcnow().isoformat()
            ))

            # Após processamento bem-sucedido, deletar o arquivo PDF
            try:
                blob_client.delete_blob()
                logging.info(f"PDF deletado: {blob.name}")
            except Exception as e:
                logging.warning(f"Erro ao deletar {blob.name}: {e}")

        if resultados:
            df = spark.createDataFrame(resultados, ["empresa", "trimestre", "avaliacoes", "nota_final", "timestamp"])
            df.write.format("delta").mode("append").save(os.environ["DELTA_PATH"])
            logging.info(f"{len(resultados)} relatórios de RI analisados.")
        else:
            logging.info("Nenhum relatório de RI processado.")

    except Exception as e:
        logging.error(f"Erro na função ri_resumer: {e}")

