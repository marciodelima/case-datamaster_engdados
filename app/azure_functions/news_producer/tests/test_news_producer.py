import sys
import os
import pytest
from unittest.mock import patch, MagicMock

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))

from news_producer.function_app import main

@patch("azure_functions.news_producer.function_app.DefaultAzureCredential")
@patch("azure_functions.news_producer.function_app.get_openai_client")
@patch("azure_functions.news_producer.function_app.EventHubProducerClient")
@patch("azure_functions.news_producer.function_app.fetch_moneytimes")
@patch("azure_functions.news_producer.function_app.fetch_infomoney_rss")
@patch("azure_functions.news_producer.function_app.fetch_valor_investe")
@patch("azure_functions.news_producer.function_app.fetch_dados_mercado")
@patch("azure_functions.news_producer.function_app.fetch_full_text")
@patch("azure_functions.news_producer.function_app.summarize_text")
def test_news_producer_function(
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
    mock_eventhub_client.return_value = mock_eventhub

    # Executa a função
    main(MagicMock())

    # Verifica se pelo menos um evento foi adicionado
    assert mock_batch.add.call_count > 0
    assert mock_eventhub.send_batch.called

