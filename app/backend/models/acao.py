from pydantic import BaseModel

class Acao(BaseModel):
    codigo: str
    nome: str
    quantidade: int
    recomendacao: str

