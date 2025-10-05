import psycopg2
import numpy as np
from vault import get_pg_credentials
from sentence_transformers import SentenceTransformer

model = SentenceTransformer("all-MiniLM-L6-v2")

def query_pgvector(prompt, top_k=3):
    embedding = model.encode(prompt).tolist()
    creds = get_pg_credentials()

    conn = psycopg2.connect(**creds)
    cur = conn.cursor()

    cur.execute("""
        SELECT texto, embedding <-> %s AS distance
        FROM relatorios_ri
        ORDER BY distance ASC
        LIMIT %s
    """, (embedding, top_k))

    results = cur.fetchall()
    cur.close()
    conn.close()
    return [r[0] for r in results]

