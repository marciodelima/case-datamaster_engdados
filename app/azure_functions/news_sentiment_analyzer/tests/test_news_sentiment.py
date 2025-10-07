import pytest
import sys
import os
from unittest.mock import patch, MagicMock
from io import BytesIO

# Ajusta o caminho para importar a função
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))

import news_sentiment_analyzer as func

@pytest.fixture
def mock_env(monkeypatch):
    monkeypatch.setenv("STORAGE_URL", "https://fake.blob.core.windows.net")
    monkeypatch.setenv("EVENTHUB_NAMESPACE", "hub")
    monkeypatch.setenv("EVENTHUB_NAME", "noticias")
    monkeypatch.setenv("KEYVAULT_URI", "https://fake.vault.azure.net")
    monkeypatch.setenv("BRONZE_PATH", "/tmp/bronze")

def test_news_sentiment(mock_env):
    with patch("news_sentiment_analyzer.DefaultAzureCredential") as mock_cred, \
         patch("news_sentiment_analyzer.BlobServiceClient") as mock_blob, \
         patch("news_sentiment_analyzer.get_openai_client") as mock_llm, \
         patch("news_sentiment_analyzer.reader") as mock_reader, \
         patch("news_sentiment_analyzer.SparkSession") as mock_spark:

        mock_cred.return_value = MagicMock()

        mock_blob_instance = MagicMock()
        mock_blob.return_value = mock_blob_instance
        mock_container = MagicMock()
        mock_blob_instance.get_container_client.return_value = mock_container

        mock_blob_list = [MagicMock(name="blob.avro")]
        mock_blob_list[0].name = "raw/noticias/hub/noticias/blob.avro"
        mock_container.list_blobs.return_value = mock_blob_list

        mock_blob_client = MagicMock()
        mock_blob_client.download_blob.return_value.readall.return_value = b"fake_avro_bytes"
        mock_container.get_blob_client.return_value = mock_blob_client

        mock_reader.return_value = iter([{"titulo": "Petrobras", "conteudo": "Dividendos"}])

        mock_llm.return_value.chat.completions.create.return_value.choices = [
            MagicMock(message=MagicMock(content='{"acoes": ["PETR4"], "sentimento": "positivo", "resumo": "Petrobras distribui dividendos"}'))
        ]

        mock_df = MagicMock()
        mock_spark.builder.getOrCreate.return_value.createDataFrame.return_value = mock_df
        mock_df.select.return_value.rdd.flatMap.return_value.collect.return_value = ["PETR4"]
        mock_df.filter.return_value.write.mode.return_value.parquet.return_value = None

        func.main(None)

