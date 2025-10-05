from pyspark.sql import SparkSession

spark = SparkSession.builder.getOrCreate()

def get_financial_summary(ticker="PETR4"):
    df = spark.sql(f"SELECT * FROM financeiro.{ticker.lower()}_indicadores WHERE ano = 2024")
    resumo = df.groupBy().agg({
        "receita_liquida": "sum",
        "lucro_liquido": "sum",
        "ebitda": "sum"
    }).collect()[0]

    return {
        "receita": resumo[0],
        "lucro": resumo[1],
        "ebitda": resumo[2]
    }
