import os
import sys
import pandas as pd
from unittest.mock import patch, MagicMock

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))

from finance_csv_ingestor.function_app import fetch_brapi_data

@patch("finance_csv_ingestor.function_app.requests.get")
@patch("finance_csv_ingestor.function_app.SecretClient")
def test_fetch_brapi_data_success(mock_secret_client_class, mock_requests_get):
    # Mock da chave da API
    mock_secret_client = MagicMock()
    mock_secret_client.get_secret.return_value.value = "fake-api-key"
    mock_secret_client_class.return_value = mock_secret_client

    # Mock da resposta da API brapi.dev
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.json.return_value = {
        "results": [{
            "historicalDataPrice": [
                {
                    "date": "2023-01-01",
                    "open": 10.0,
                    "close": 12.0,
                    "high": 12.5,
                    "low": 9.8,
                    "volume": 1000
                }
            ]
        }]
    }
    mock_requests_get.return_value = mock_response

    # Mock do Blob Storage
    mock_blob_client = MagicMock()
    mock_container = MagicMock()
    mock_container.get_blob_client.return_value = mock_blob_client

    # Executa a função
    fetch_brapi_data("PETR4", mock_container, mock_secret_client)

    # Verifica se upload_blob foi chamado
    mock_blob_client.upload_blob.assert_called_once()
    args, kwargs = mock_blob_client.upload_blob.call_args
    assert kwargs["overwrite"] is True
    assert b"date,open,close,high,low,volume" in args[0]

@patch("finance_csv_ingestor.function_app.requests.get")
@patch("finance_csv_ingestor.function_app.SecretClient")
def test_fetch_brapi_data_unauthorized(mock_secret_client_class, mock_requests_get):
    mock_secret_client = MagicMock()
    mock_secret_client.get_secret.return_value.value = "invalid-key"
    mock_secret_client_class.return_value = mock_secret_client

    mock_response = MagicMock()
    mock_response.status_code = 401
    mock_requests_get.return_value = mock_response

    mock_container = MagicMock()
    fetch_brapi_data("PETR4.SA", mock_container, mock_secret_client)

    mock_container.get_blob_client().upload_blob.assert_not_called()

@patch("finance_csv_ingestor.function_app.requests.get")
@patch("finance_csv_ingestor.function_app.SecretClient")
def test_fetch_brapi_data_empty_data(mock_secret_client_class, mock_requests_get):
    mock_secret_client = MagicMock()
    mock_secret_client.get_secret.return_value.value = "fake-key"
    mock_secret_client_class.return_value = mock_secret_client

    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.json.return_value = {
        "results": [{
            "historicalDataPrice": []
        }]
    }
    mock_requests_get.return_value = mock_response

    mock_container = MagicMock()
    fetch_brapi_data("VALE3", mock_container, mock_secret_client)

    mock_container.get_blob_client().upload_blob.assert_not_called()

