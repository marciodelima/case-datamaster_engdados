def test_ri_downloader(monkeypatch):
    import app.azure_functions.ri_collector as func

    monkeypatch.setenv("KEYVAULT_URL", "https://fake.vault.azure.net")
    monkeypatch.setenv("STORAGE_URL", "https://fake.blob.core.windows.net")

    monkeypatch.setattr(func, "get_pg_connection_string", lambda: "postgres://user:pass@localhost/db")
    monkeypatch.setattr(func.psycopg2, "connect", lambda _: DummyConnRI())
    monkeypatch.setattr(func.requests, "get", lambda url: DummyResponse(200, b"%PDF"))

    func.main(None)

