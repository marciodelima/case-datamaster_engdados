import pytest
import sys
import os
from unittest.mock import patch, MagicMock

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))
from ri_collector.function_app import main

@patch("ri_collector.function_app.requests.get")
@patch("ri_collector.function_app.psycopg2.connect")
@patch("ri_collector.function_app.BlobServiceClient")
@patch("ri_collector.function_app.DefaultAzureCredential")
@patch("ri_collector.function_app.get_secret_client")
def test_ri_collector_success(
    mock_get_secret_client,
    mock_default_cred,
    mock_blob_service,
    mock_connect,
    mock_requests_get
):
    # Simula retorno do SecretClient
    mock_secret_client = MagicMock()
    mock_secret_client.get_secret.return_value.value = (
        "Host=host;Port=5432;Database=db;User Id=user;Password=pass;Ssl Mode=Require"
    )
    mock_get_secret_client.return_value = mock_secret_client

    # Simula conexão PostgreSQL
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = [
        ("PETROBRAS", "https://example.com/petrobras.pdf"),
        ("VALE", "https://example.com/vale.pdf")
    ]
    mock_conn = MagicMock()
    mock_conn.cursor.return_value = mock_cursor
    mock_connect.return_value = mock_conn

    # Simula resposta de download dos PDFs
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.headers = {"Content-Type": "application/pdf"}
    mock_response.content = b"%PDF-1.4 fake content"
    mock_requests_get.return_value = mock_response

    # Simula Blob Storage
    mock_blob_client = MagicMock()
    mock_container = MagicMock()
    mock_container.get_blob_client.return_value = mock_blob_client
    mock_blob_service.return_value.get_container_client.return_value = mock_container

    # Executa a função
    main(None)

