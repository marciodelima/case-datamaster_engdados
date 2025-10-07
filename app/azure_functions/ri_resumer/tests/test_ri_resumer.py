def test_ri_resumer(monkeypatch):
    import app.azure_functions.ri_resumer as func

    monkeypatch.setenv("STORAGE_URL", "https://fake.blob.core.windows.net")
    monkeypatch.setenv("KEYVAULT_URI", "https://fake.vault.azure.net")
    monkeypatch.setenv("DELTA_PATH", "/tmp/delta")

    monkeypatch.setattr(func, "extract_text", lambda b: "Texto do relatório")
    monkeypatch.setattr(func, "get_openai_client", lambda: DummyLLM())
    monkeypatch.setattr(func.BlobServiceClient, "from_connection_string", lambda *_: DummyBlob())

    func.main(None)

