import os
import logging
import azure.functions as func

def main(mytimer: func.TimerRequest) -> None:
    logging.info("Iniciando execução da função finance_csv_ingestor")
    #try:
    #    credential = DefaultAzureCredential()
    #    blob = BlobServiceClient(account_url=os.environ["STORAGE_URL"], credential=credential)
    #    container = blob.get_container_client("dados")
    #except Exception as e:
    #    logging.error(f"Erro ao configurar acesso ao Blob Storage: {e}")
    #    return

    #try:
    #    download_and_upload(
    #        "https://api.bcb.gov.br/dados/serie/bcdata.sgs.4189/dados/ultimos/1?formato=csv",
    #        "raw/financeiro/bacen/selic.csv",
    #        container
    #    )

    #    download_and_upload(
    #        "https://raw.githubusercontent.com/marciodelima/case-datamaster_engdados/main/app/data/acoes-listadas-b3.csv",
    #        "raw/financeiro/b3/acoes-listadas-b3.csv",
    #        container
    #    )
    #except Exception as e:
    #    logging.error(f"Erro ao baixar CSVs: {e}")

    #try:
    #    tickers = get_pg_tickers()
    #    for ticker in tickers:
    #        fetch_yahoo_data(ticker, container)
    #
    #except Exception as e:
    #    logging.error(f"Erro na ingestão financeira: {e}")
    
    logging.info("Final da execução da função finance_csv_ingestor")


