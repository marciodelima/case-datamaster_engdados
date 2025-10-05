from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

def get_pg_credentials():
    kv_url = "https://<your-keyvault-name>.vault.azure.net"
    credential = DefaultAzureCredential()
    client = SecretClient(vault_url=kv_url, credential=credential)

    return {
        "host": client.get_secret("pg-host").value,
        "port": client.get_secret("pg-port").value,
        "user": client.get_secret("pg-user").value,
        "password": client.get_secret("pg-password").value,
        "database": client.get_secret("pg-db").value
    }

