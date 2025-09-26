from openai import AzureOpenAI
from azure.identity import DefaultAzureCredential
import json

llm = AzureOpenAI(
    api_version="2023-07-01-preview",
    azure_endpoint="https://<your-openai-resource>.openai.azure.com/",
    azure_deployment="gpt-4",
    credential=DefaultAzureCredential()
)

def avaliar_relatorio_ri(texto, empresa):
    prompt = f"""
    Você é um analista financeiro especializado em ações brasileiras. Avalie o relatório de RI da empresa {empresa} com base nos seguintes critérios:
    ...
    """
    response = llm.chat.completions.create(
        messages=[{"role": "user", "content": prompt}],
        model="gpt-4",
        temperature=0.3
    )
    return json.loads(response.choices[0].message.content)

