import os
import sys
import pandas as pd
from unittest.mock import patch, MagicMock

# Garante que o módulo postgres_ingestor pode ser importado corretamente
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))

from postgres_ingestor.function_app import main, get_postgres_connection_string

@patch.dict(os.environ, {
    "KEYVAULT_URI": "https://fake-vault.vault.azure.net/",
    "STORAGE_URL": "https://fake.blob.core.windows.net/"
})
@patch("postgres_ingestor.function_app.pd.read_sql")
@patch("postgres_ingestor.function_app.get_secret_client")
@patch("postgres_ingestor.function_app.psycopg2.connect")
@patch("postgres_ingestor.function_app.BlobServiceClient")
@patch("postgres_ingestor.function_app.DefaultAzureCredential")
def test_postgres_ingestor_flow(
    mock_credential,
    mock_blob_service,
    mock_connect,
    mock_get_secret_client,
    mock_read_sql
):
    # Simula retorno do SecretClient
    mock_secret_client = MagicMock()
    mock_secret_client.get_secret.return_value.value = (
        "Host=host;Port=5432;Database=db;User Id=user;Password=pass;Ssl Mode=Require"
    )
    mock_get_secret_client.return_value = mock_secret_client

    # Simula conexão PostgreSQL
    mock_conn = MagicMock()
    mock_connect.return_value = mock_conn

    # Simula leitura de tabelas
    sample_df = pd.DataFrame({"id": [1], "nome": ["teste"]})
    mock_read_sql.return_value = sample_df

    # Simula Blob Storage
    mock_blob_client = MagicMock()
    mock_container = MagicMock()
    mock_container.get_blob_client.return_value = mock_blob_client
    mock_blob_service.return_value.get_container_client.return_value = mock_container

    # Executa a função com mock de TimerRequest
    mock_timer = MagicMock()
    main(mock_timer)


def test_get_postgres_connection_string_formatting():
    mock_secret_client = MagicMock()
    mock_secret_client.get_secret.return_value.value = (
        "Host=host;Port=5432;Database=db;User Id=user;Password=pass;Ssl Mode=Require"
    )
    conn_str = get_postgres_connection_string(mock_secret_client)
    assert "host=" in conn_str
    assert "port=" in conn_str
    assert "dbname=" in conn_str
    assert "user=" in conn_str
    assert "password=" in conn_str
    assert "sslmode=require" in conn_str

