import os
import sys
import json
import pandas as pd
from unittest.mock import patch, MagicMock

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))

from news_sentiment_analyzer.function_app import main

@patch("news_sentiment_analyzer.function_app.AzureOpenAI")
@patch("news_sentiment_analyzer.function_app.BlobServiceClient")
@patch("news_sentiment_analyzer.function_app.DefaultAzureCredential")
@patch("news_sentiment_analyzer.function_app.SecretClient")
def test_news_sentiment_analyzer_success(
    mock_secret_client_class,
    mock_default_cred,
    mock_blob_service_class,
    mock_openai_class
):
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
        MagicMock(value="fake-openai-key"),
        MagicMock(value="https://fake-endpoint.openai.azure.com")
    ]
    mock_secret_client_class.return_value = mock_secret_client

    # Simula resposta do OpenAI
    mock_openai = MagicMock()
    mock_openai.chat.completions.create.return_value.choices = [
        MagicMock(message=MagicMock(content=json.dumps({
            "acoes": ["PETR4"],
            "sentimento": "positivo",
            "resumo": "Petrobras em alta"
        })))
    ]
    mock_openai_class.return_value = mock_openai

    # Simula Blob Storage
    mock_blob_client = MagicMock()
    mock_container = MagicMock()
    mock_container.get_blob_client.return_value = mock_blob_client
    mock_blob_service = MagicMock()
    mock_blob_service.get_container_client.return_value = mock_container
    mock_blob_service_class.return_value = mock_blob_service

    # Executa a função
    main(events)

    # Verifica se o upload foi chamado
    assert mock_blob_client.upload_blob.called
    assert mock_blob_client.upload_blob.call_count >= 1

