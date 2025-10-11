import pytest
import sys
import os
from datetime import datetime
from unittest.mock import patch, MagicMock

# Ajusta o caminho para importar a função
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))

# Importa o módulo correto
from finance_csv_ingestor import function_app

@pytest.fixture
def mock_env(monkeypatch):
    monkeypatch.setenv("KEYVAULT_URL", "https://fake.vault.azure.net")
    monkeypatch.setenv("STORAGE_URL", "https://fake.blob.core.windows.net")

def test_main_function(mock_env):
    with patch("finance_csv_ingestor.function_app.DefaultAzureCredential") as mock_cred, \
         patch("finance_csv_ingestor.function_app.BlobServiceClient") as mock_blob, \
         patch("finance_csv_ingestor.function_app.requests.get") as mock_requests, \
         patch("finance_csv_ingestor.function_app.psycopg2.connect") as mock_pg, \
         patch("finance_csv_ingestor.function_app.yf.Ticker") as mock_yf:

        # Simula credencial
        mock_cred.return_value = MagicMock()

        # Simula blob
        mock_blob_instance = MagicMock()
        mock_blob.return_value = mock_blob_instance
        mock_blob_instance.get_container_client.return_value.get_blob_client.return_value.upload_blob.return_value = None

        # Simula requests
        mock_requests.return_value.status_code = 200
        mock_requests.return_value.content = b"csv,data"

        # Simula PostgreSQL
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = [("PETR4",), ("VALE3",)]
        mock_pg.return_value.cursor.return_value = mock_cursor

        # Simula yfinance
        mock_stock = MagicMock()
        mock_stock.history.return_value = function_app.pd.DataFrame({"Date": [datetime.now()], "Close": [28.5]})
        mock_yf.return_value = mock_stock

        # Executa função principal
        function_app.main(None)

