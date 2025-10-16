import os
import sys
import pytest
from unittest.mock import patch, MagicMock

# Adiciona o diretório raiz ao path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))

from finance_csv_ingestor.function_app import (
    download_and_upload,
    get_pg_tickers,
    fetch_yahoo_data,
    get_postgres_connection_string
)

# Teste para download_and_upload com sucesso
@patch("finance_csv_ingestor.function_app.requests.get")
def test_download_and_upload_success(mock_get):
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.content = b"csv data"
    mock_get.return_value = mock_response

    mock_container = MagicMock()
    mock_blob_client = MagicMock()
    mock_container.get_blob_client.return_value = mock_blob_client

    download_and_upload("http://fake-url.com/data.csv", "path/to/blob.csv", mock_container)

    mock_blob_client.upload_blob.assert_called_once_with(b"csv data", overwrite=True)

# Teste para download_and_upload com falha
@patch("finance_csv_ingestor.function_app.requests.get")
def test_download_and_upload_failure(mock_get):
    mock_response = MagicMock()
    mock_response.status_code = 404
    mock_get.return_value = mock_response

    mock_container = MagicMock()
    download_and_upload("http://fake-url.com/data.csv", "path/to/blob.csv", mock_container)

    mock_container.get_blob_client().upload_blob.assert_not_called()

# Teste para get_postgres_connection_string
@patch("finance_csv_ingestor.function_app.DefaultAzureCredential")
@patch("finance_csv_ingestor.function_app.SecretClient")
def test_get_postgres_connection_string(mock_secret_client_class, mock_credential_class):
    raw_value = (
        "Host=host;Port=5432;Database=db;User Id=user;Password=pass;Ssl Mode=Require"
    )

    mock_secret_client = MagicMock()
    mock_secret_client.get_secret.return_value.value = raw_value
    mock_secret_client_class.return_value = mock_secret_client

    with patch.dict("os.environ", {"KEYVAULT_URI": "https://fake-vault.vault.azure.net"}):
        conn_str = get_postgres_connection_string()

    assert "host=host" in conn_str
    assert "port=5432" in conn_str
    assert "dbname=db" in conn_str
    assert "user=user" in conn_str
    assert "password=pass" in conn_str
    assert "sslmode=Require" in conn_str

# Teste para get_pg_tickers
@patch("finance_csv_ingestor.function_app.psycopg2.connect")
@patch("finance_csv_ingestor.function_app.DefaultAzureCredential")
@patch("finance_csv_ingestor.function_app.SecretClient")
def test_get_pg_tickers(mock_secret_client_class, mock_credential_class, mock_connect):
    mock_secret_client = MagicMock()
    mock_secret_client.get_secret.return_value.value = (
        "Host=host;Port=5432;Database=db;User Id=user;Password=pass;Ssl Mode=Require"
    )
    mock_secret_client_class.return_value = mock_secret_client

    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = [("PETR4",), ("VALE3",)]
    mock_conn = MagicMock()
    mock_conn.cursor.return_value = mock_cursor
    mock_connect.return_value = mock_conn

    with patch.dict("os.environ", {"KEYVAULT_URI": "https://fake-vault.vault.azure.net"}):
        tickers = get_pg_tickers()

    assert tickers == ["PETR4.SA", "VALE3.SA"]

# Teste para fetch_yahoo_data
@patch("finance_csv_ingestor.function_app.yf.Ticker")
def test_fetch_yahoo_data(mock_ticker_class):
    mock_df = MagicMock()
    mock_df.empty = False
    mock_df.to_csv.return_value = "date,open,close\n2023-01-01,10,12"
    mock_df.reset_index = MagicMock()

    mock_ticker = MagicMock()
    mock_ticker.history.return_value = mock_df
    mock_ticker_class.return_value = mock_ticker

    mock_container = MagicMock()
    mock_blob_client = MagicMock()
    mock_container.get_blob_client.return_value = mock_blob_client

    fetch_yahoo_data("PETR4.SA", mock_container)

    mock_blob_client.upload_blob.assert_called_once()

