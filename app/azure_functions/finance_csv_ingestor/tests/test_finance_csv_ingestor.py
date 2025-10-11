import pytest
import sys
import os
from unittest.mock import patch
from io import StringIO

# Ajusta o caminho para importar a função
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))

# Importa o módulo principal (__init__.py)
from finance_csv_ingestor import __init__ as function_app

def test_main_logs_execution(monkeypatch, caplog):
    # Simula ambiente mínimo
    monkeypatch.setenv("STORAGE_URL", "https://fake.blob.core.windows.net")

    # Executa a função
    function_app.main(None)

    # Verifica se os logs esperados foram emitidos
    logs = [record.message for record in caplog.records]
    assert "Iniciando execução da função finance_csv_ingestor" in logs
    assert "Final da execução da função finance_csv_ingestor" in logs

