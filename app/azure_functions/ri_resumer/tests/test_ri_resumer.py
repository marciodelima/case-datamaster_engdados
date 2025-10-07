import pytest
import sys
import os
from unittest.mock import patch, MagicMock

# Ajusta o caminho para importar a função
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))

import ri_resumer as func

@pytest.fixture
def mock_env(monkeypatch):
    monkeypatch.setenv("STORAGE_URL", "https://fake.blob.core.windows.net")
    monkeypatch.setenv("KEYVAULT_URI", "https://fake.vault.azure.net")
    monkeypatch.setenv("DELTA_PATH", "/tmp/delta")

def test_main_function(mock_env):
    with patch("ri_resumer.DefaultAzureCredential") as mock_cred, \
         patch("ri_resumer.BlobServiceClient") as mock_blob, \
         patch("ri_resumer.SecretClient") as mock_secret, \
         patch("ri_resumer.AzureOpenAI") as mock_llm, \
         patch("ri_resumer.SparkSession") as mock_spark, \
         patch("ri_resumer.extract_text") as mock_extract:

        mock_cred.return_value = MagicMock()

        # Simula Key Vault
        mock_secret_instance = MagicMock()
        mock_secret.return_value = mock_secret_instance
        mock_secret_instance.get_secret.side_effect = lambda k: MagicMock(value=f"fake-{k}")

        # Simula Blob Storage
        mock_blob_instance = MagicMock()
        mock_blob.return_value = mock_blob_instance
        mock_container = MagicMock()
        mock_blob_instance.get_container_client.return_value = mock_container

        mock_blob_list = [MagicMock(name="raw/ri/PETR4/ri.pdf")]
        mock_blob_list[0].name = "raw/ri/PETR4/ri.pdf"
        mock_container.list_blobs.return_value = mock_blob_list

        mock_blob_client = MagicMock()
        mock_blob_client.download_blob.return_value.readall.return_value = b"%PDF"
        mock_container.get_blob_client.return_value = mock_blob_client

        # Simula extração de texto
        mock_extract.return_value = "Texto do relatório"

        # Simula LLM
        mock_llm_instance = MagicMock()
        mock_llm.return_value = mock_llm_instance
        mock_llm_instance.chat.completions.create.return_value.choices = [
            MagicMock(message=MagicMock(content='{"empresa": "PETR4", "trimestre": "2T25", "avaliacoes": {"lucro": "bom"}, "nota_final": 8.5}'))
        ]

        # Simula Spark
        mock_df = MagicMock()
        mock_spark.builder.getOrCreate.return_value.createDataFrame.return_value = mock_df
        mock_df.write.format.return_value.mode.return_value.save.return_value = None

        func.main(None)

