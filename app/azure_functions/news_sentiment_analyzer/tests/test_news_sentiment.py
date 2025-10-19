import os
import sys
import json
import pandas as pd
from unittest.mock import patch, MagicMock, call

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))

from news_sentiment_analyzer.function_app import main

@patch("news_sentiment_analyzer.function_app.AzureOpenAI")
@patch("news_sentiment_analyzer.function_app.BlobServiceClient")
@patch("news_sentiment_analyzer.function_app.DefaultAzureCredential")
@patch("news_sentiment_analyzer.function_app.SecretClient")
def test_streaming_sentiment_analysis_success(
    mock_secret_client_class,
    mock_default_cred,
    mock_blob_service_class,
    mock_openai_class
):
    os.environ["DELTA_PATH"] = "bronze"

    class FakeEvent:
        def __init__(self, body):
            self.body = body
        def get_body(self):
            return self.body.encode("utf-8")

    events = [
        FakeEvent(json.dumps({"titulo": "Petrobras sobe", "conteudo": "Alta no petróleo"})),
        FakeEvent(json.dumps({"titulo": "Vale cai", "conteudo": "Queda no minério"}))
    ]

    mock_secret_client = MagicMock()
    mock_secret_client.get_secret.side_effect = [
        MagicMock(value="fake-openai-key"),
        MagicMock(value="https://fake-endpoint.openai.azure.com")
    ]
    mock_secret_client_class.return_value = mock_secret_client

    mock_openai = MagicMock()
    mock_openai.chat.completions.create.side_effect = [
        MagicMock(message=MagicMock(content=json.dumps({
            "acoes": ["PETR4"],
            "sentimento": "positivo",
            "resumo": "Petrobras em alta"
        }))),
        MagicMock(message=MagicMock(content=json.dumps({
            "acoes": ["VALE3"],
            "sentimento": "negativo",
            "resumo": "Vale em queda"
        })))
    ]
    mock_openai_class.return_value = mock_openai

    # Lista para rastrear todos os mocks retornados por get_blob_client
    blob_client_mocks = []

    def get_blob_client_side_effect(path):
        mock_blob = MagicMock()
        blob_client_mocks.append((path, mock_blob))
        return mock_blob

    mock_container = MagicMock()
    mock_container.get_blob_client.side_effect = get_blob_client_side_effect
    mock_blob_service = MagicMock()
    mock_blob_service.get_container_client.return_value = mock_container
    mock_blob_service_class.return_value = mock_blob_service

    main(events)

    # Verifica se pelo menos um dos mocks teve upload_blob chamado
    assert any(mock.upload_blob.called for _, mock in blob_client_mocks), "Nenhum upload_blob foi chamado"

    # Verifica se os caminhos incluem PETR4 e VALE3
    paths = [path for path, _ in blob_client_mocks]
    assert any("PETR4" in path for path in paths), "PETR4 não encontrado nos caminhos"
    assert any("VALE3" in path for path in paths), "VALE3 não encontrado nos caminhos"

