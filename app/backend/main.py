from fastapi import FastAPI
from routers import clientes, carteira, chat

app = FastAPI(title="Investimentos API")

app.include_router(clientes.router)
app.include_router(carteira.router)
app.include_router(chat.router)

