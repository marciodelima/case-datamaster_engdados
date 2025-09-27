from pydantic import BaseModel

class Cliente(BaseModel):
    cpf: str
    nome: str
    perfil: str

