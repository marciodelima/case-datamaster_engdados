import pytest
import sys
import os
from unittest.mock import patch, MagicMock

# Ajusta o caminho para importar a função
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))

import ri_collector as func

@pytest.fixture
def mock_env(monkeypatch):
    monkeypatch.setenv("KEYVAULT_URL", "https://fake.vault.azure.net")
    monkeypatch.setenv("STORAGE_URL", "https://fake.blob.core.windows.net")

def test_main_function(mock_env):
    with patch("ri_collector.DefaultAzureCredential") as mock_cred, \
         patch("ri_collector.SecretClient") as mock_secret, \
         patch("ri_collector.psycopg2.connect") as mock_pg, \
         patch("ri_collector.BlobServiceClient") as mock_blob, \
         patch("ri_collector.requests.get") as mock_requests:

        mock_cred.return_value = MagicMock()

        # Simula Key Vault
        mock_secret_instance = MagicMock()
        mock_secret.return_value = mock_secret_instance
        mock_secret_instance.get_secret.return_value.value = "postgres://user:pass@localhost/db"

        # Simula PostgreSQL
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = [("PETR4", "https://site.com/petr4.pdf")]
        mock_conn = MagicMock()
        mock_conn.cursor.return_value = mock_cursor
        mock_pg.return_value = mock_conn

        # Simula Blob Storage
        mock_blob_instance = MagicMock()
        mock_blob.return_value = mock_blob_instance
        mock_container = MagicMock()
        mock_blob_instance.get_container_client.return_value = mock_container
        mock_container.get_blob_client.return_value.upload_blob.return_value = None

        # Simula requests.get
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.headers = {"Content-Type": "application/pdf"}
        mock_response.content = b"%PDF"
        mock_requests.return_value = mock_response

        func.main(None)

