def test_news_sentiment(monkeypatch):
    import app.azure_functions.news_sentiment_analyzer as func

    monkeypatch.setenv("STORAGE_URL", "https://fake.blob.core.windows.net")
    monkeypatch.setenv("EVENTHUB_NAMESPACE", "hub")
    monkeypatch.setenv("EVENTHUB_NAME", "noticias")
    monkeypatch.setenv("KEYVAULT_URI", "https://fake.vault.azure.net")
    monkeypatch.setenv("BRONZE_PATH", "/tmp/bronze")

    monkeypatch.setattr(func.reader, "read", lambda b: [{"titulo": "Petrobras", "conteudo": "Dividendos"}])
    monkeypatch.setattr(func, "get_openai_client", lambda: DummyLLM())
    monkeypatch.setattr(func.BlobServiceClient, "from_connection_string", lambda *_: DummyBlob())

    func.main(None)

