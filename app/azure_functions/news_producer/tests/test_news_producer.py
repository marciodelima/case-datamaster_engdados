def test_news_producer(monkeypatch):
    import app.azure_functions.news_producer as func

    class DummyCursor:
        def execute(self, q): pass
        def fetchall(self): return [("Petrobras anuncia dividendos", "Texto da notícia", "2025-10-01", "09:30:00")]
        def close(self): pass

    class DummyConn:
        def cursor(self): return DummyCursor()
        def close(self): pass

    monkeypatch.setenv("KEYVAULT_URL", "https://fake.vault.azure.net")
    monkeypatch.setattr(func, "get_pg_connection_string", lambda: "postgres://user:pass@localhost/db")
    monkeypatch.setattr(func.psycopg2, "connect", lambda _: DummyConn())
    monkeypatch.setattr(func, "send_to_eventhub", lambda x: True)  # Simula envio

    func.main(None)

