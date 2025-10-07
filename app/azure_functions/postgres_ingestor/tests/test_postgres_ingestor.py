def test_postgres_ingestor(monkeypatch):
    import app.azure_functions.postgres_ingestor as func

    # Simula leitura de arquivo/parquet
    monkeypatch.setattr(func.pd, "read_parquet", lambda path: func.pd.DataFrame({"cpf": ["12345678909"], "renda": [12000]}))

    # Simula conexão com PostgreSQL
    class DummyCursor:
        def execute(self, q, v=None): pass
        def close(self): pass

    class DummyConn:
        def cursor(self): return DummyCursor()
        def commit(self): pass
        def close(self): pass

    monkeypatch.setenv("KEYVAULT_URL", "https://fake.vault.azure.net")
    monkeypatch.setattr(func, "get_pg_connection_string", lambda: "postgres://user:pass@localhost/db")
    monkeypatch.setattr(func.psycopg2, "connect", lambda _: DummyConn())

    func.main(None)

