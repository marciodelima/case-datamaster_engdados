import os
import sys
import json
import pandas as pd
from unittest.mock import patch, MagicMock, call

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))

from news_sentiment_analyzer.function_app import main

@patch("news_sentiment_analyzer.function_app.get_openai_client")
@patch("news_sentiment_analyzer.function_app.BlobServiceClient")
@patch("news_sentiment_analyzer.function_app.DefaultAzureCredential")
@patch("news_sentiment_analyzer.function_app.SecretClient")
def test_streaming_sentiment_analysis_flow(
    mock_secret_client_class,
    mock_default_cred,
    mock_blob_service_class,
    mock_get_openai_client
):
    # Define variáveis de ambiente mínimas
    os.environ["DELTA_PATH"] = "bronze"
    os.environ["STORAGE_URL"] = "https://fake.blob.core.windows.net"
    os.environ["KEYVAULT_URI"] = "https://fake.vault.azure.net"

    # Simula eventos do Event Hub
    class FakeEvent:
        def __init__(self, body):
            self.body = body
        def get_body(self):
            return self.body.encode("utf-8")

    events = [
        FakeEvent(json.dumps({"titulo": "Petrobras sobe", "conteudo": "Alta no petróleo"})),
        FakeEvent(json.dumps({"titulo": "Vale cai", "conteudo": "Queda no minério"}))
    ]

    # Simula retorno do SecretClient
    mock_secret_client = MagicMock()
    mock_secret_client.get_secret.side_effect = [
        MagicMock(value="fake-key"),
        MagicMock(value="https://fake-endpoint.openai.azure.com")
    ]
    mock_secret_client_class.return_value = mock_secret_client

    # ✅ Cria mock do cliente OpenAI com método create configurado
    mock_create = MagicMock()
    mock_create.side_effect = [
        MagicMock(message=MagicMock(content=json.dumps({
            "acoes": ["PETR4"],
            "sentimento": "positivo",
            "resumo": "Alta da Petrobras"
        }))),
        MagicMock(message=MagicMock(content=json.dumps({
            "acoes": ["VALE3"],
            "sentimento": "negativo",
            "resumo": "Queda da Vale"
        })))
    ]

    mock_client = MagicMock()
    mock_client.chat.completions.create = mock_create
    mock_get_openai_client.return_value = mock_client

    # Simula BlobServiceClient sem verificar chamadas
    mock_blob_service = MagicMock()
    mock_blob_service.get_container_client.return_value = MagicMock()
    mock_blob_service_class.return_value = mock_blob_service

    # Executa a função
    main(events)

    # Verifica se o modelo foi chamado duas vezes
    assert mock_create.call_count == 2

