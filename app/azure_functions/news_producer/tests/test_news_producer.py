import sys
import os
import pytest
from unittest.mock import patch, MagicMock

# Garante que o pacote raiz seja reconhecido
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))

from news_producer.function_app import main

@patch("news_producer.function_app.DefaultAzureCredential")
@patch("news_producer.function_app.get_openai_client")
@patch("news_producer.function_app.EventHubProducerClient")
@patch("news_producer.function_app.fetch_moneytimes")
@patch("news_producer.function_app.fetch_infomoney_rss")
@patch("news_producer.function_app.fetch_valor_investe")
@patch("news_producer.function_app.fetch_dados_mercado")
@patch("news_producer.function_app.fetch_full_text")
@patch("news_producer.function_app.summarize_text")
@patch("news_producer.function_app.logging")
@patch("news_producer.function_app.EventData")
def test_news_producer_function(
    mock_event_data,
    mock_logging,
    mock_summarize_text,
    mock_fetch_full_text,
    mock_fetch_dados_mercado,
    mock_fetch_valor_investe,
    mock_fetch_infomoney_rss,
    mock_fetch_moneytimes,
    mock_eventhub_client,
    mock_openai_client,
    mock_credential
):
    # Simula fontes de notícias
    mock_fetch_moneytimes.return_value = [{"origem": "MoneyTimes", "titulo": "Notícia MT", "url": "http://mt"}]
    mock_fetch_infomoney_rss.return_value = [{"origem": "InfoMoney", "titulo": "Notícia IM", "url": "http://im"}]
    mock_fetch_valor_investe.return_value = [{"origem": "Valor Investe", "titulo": "Notícia VI", "url": "http://vi"}]
    mock_fetch_dados_mercado.return_value = [{"origem": "Dados de Mercado", "titulo": "Notícia DM", "url": "http://dm"}]

    # Simula texto completo e resumo
    mock_fetch_full_text.return_value = "Texto completo da notícia"
    mock_summarize_text.return_value = "Resumo da notícia"

    # Simula Event Hub
    mock_batch = MagicMock()
    mock_eventhub = MagicMock()
    mock_eventhub.create_batch.return_value = mock_batch
    mock_eventhub.send_batch = MagicMock()
    mock_eventhub_client.return_value = mock_eventhub
    mock_event_data.side_effect = lambda x: x

    # Executa a função
    main(MagicMock())

    # Verifica se pelo menos um evento foi adicionado
    assert mock_batch.add.call_count == 4  # 4 fontes simuladas
    mock_eventhub.send_batch.assert_called_once()
    mock_logging.info.assert_any_call("Iniciando execução da função news_producer")

