def test_finance_csv_ingestor(monkeypatch):
    import app.azure_functions.finance_csv_ingestor as func

    class DummyConn:
        def cursor(self): return self
        def execute(self, q): pass
        def fetchall(self): return [('clientes',), ('acoes',)]
        def close(self): pass

    monkeypatch.setenv("KEYVAULT_URL", "https://fake.vault.azure.net")
    monkeypatch.setenv("STORAGE_URL", "https://fake.blob.core.windows.net")

    monkeypatch.setattr(func, "get_pg_connection_string", lambda: "postgres://user:pass@localhost/db")
    monkeypatch.setattr(func.psycopg2, "connect", lambda _: DummyConn())
    monkeypatch.setattr(func.pd, "read_sql", lambda q, conn: func.pd.DataFrame({"id": [1], "nome": ["teste"]}))
    monkeypatch.setattr(func.BlobServiceClient, "from_connection_string", lambda *_: DummyBlob())

    func.main(None)

