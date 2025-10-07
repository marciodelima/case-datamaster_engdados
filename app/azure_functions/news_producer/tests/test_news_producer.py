import pytest
import sys
import os
from unittest.mock import patch, MagicMock

# Ajusta o caminho para importar a função
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))

import news_producer as func

@pytest.fixture
def mock_env(monkeypatch):
    monkeypatch.setenv("KEYVAULT_URI", "https://fake.vault.azure.net")
    monkeypatch.setenv("EVENTHUB_NAMESPACE", "fake-namespace.servicebus.windows.net")
    monkeypatch.setenv("EVENTHUB_NAME", "noticias")

def test_main_function(mock_env):
    with patch("news_producer.DefaultAzureCredential") as mock_cred, \
         patch("news_producer.SecretClient") as mock_secret, \
         patch("news_producer.AzureOpenAI") as mock_llm, \
         patch("news_producer.EventHubProducerClient") as mock_eventhub, \
         patch("news_producer.requests.get") as mock_requests, \
         patch("news_producer.feedparser.parse") as mock_feed:

        mock_cred.return_value = MagicMock()

        # Simula Key Vault
        mock_secret_instance = MagicMock()
        mock_secret.return_value = mock_secret_instance
        mock_secret_instance.get_secret.side_effect = lambda k: MagicMock(value=f"fake-{k}")

        # Simula OpenAI
        mock_llm_instance = MagicMock()
        mock_llm.return_value = mock_llm_instance
        mock_llm_instance.chat.completions.create.return_value.choices = [
            MagicMock(message=MagicMock(content="Resumo gerado pela IA"))
        ]

        # Simula Event Hub
        mock_batch = MagicMock()
        mock_eventhub_instance = MagicMock()
        mock_eventhub_instance.create_batch.return_value = mock_batch
        mock_eventhub.return_value = mock_eventhub_instance

        # Simula HTML das fontes
        mock_requests.return_value.text = """
        <html>
            <article><h2>Notícia A</h2><a href="https://site.com/a">link</a></article>
            <div class="feed-post-body"><a href="https://site.com/b">Notícia B</a></div>
            <div class="card-body"><h5>Notícia C</h5><a href="https://site.com/c">link</a></div>
            <p>Texto completo da notícia com mais de 40 caracteres.</p>
        </html>
        """

        # Simula RSS
        mock_feed.return_value.entries = [
            MagicMock(title="Notícia RSS", link="https://site.com/rss")
        ]

        func.main(None)

