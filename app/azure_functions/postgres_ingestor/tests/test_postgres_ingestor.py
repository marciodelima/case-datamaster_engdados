import pytest
import sys
import os
from unittest.mock import patch, MagicMock
from datetime import datetime

# Ajusta o caminho para importar a função
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))

import postgres_ingestor as func

@pytest.fixture
def mock_env(monkeypatch):
    monkeypatch.setenv("KEYVAULT_URL", "https://fake.vault.azure.net")
    monkeypatch.setenv("STORAGE_URL", "https://fake.blob.core.windows.net")

def test_main_function(mock_env):
    with patch("postgres_ingestor.DefaultAzureCredential") as mock_cred, \
         patch("postgres_ingestor.SecretClient") as mock_secret, \
         patch("postgres_ingestor.psycopg2.connect") as mock_pg, \
         patch("postgres_ingestor.BlobServiceClient") as mock_blob, \
         patch("postgres_ingestor.pd.read_sql") as mock_read_sql:

        mock_cred.return_value = MagicMock()

        # Simula Key Vault
        mock_secret_instance = MagicMock()
        mock_secret.return_value = mock_secret_instance
        mock_secret_instance.get_secret.return_value.value = "postgres://user:pass@localhost/db"

        # Simula PostgreSQL
        mock_conn = MagicMock()
        mock_pg.return_value = mock_conn

        # Simula pandas.read_sql
        mock_df = MagicMock()
        mock_df.to_parquet.return_value = b"parquet-bytes"
        mock_read_sql.return_value = mock_df

        # Simula Blob Storage
        mock_blob_instance = MagicMock()
        mock_blob.return_value = mock_blob_instance
        mock_container = MagicMock()
        mock_blob_instance.get_container_client.return_value = mock_container
        mock_container.get_blob_client.return_value.upload_blob.return_value = None

        func.main(None)

