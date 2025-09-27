from fastapi import APIRouter
from repositories.carteira_repository import CarteiraRepository

router = APIRouter(prefix="/clientes", tags=["Carteira"])
repo = CarteiraRepository()

@router.get("/{cpf}/carteira")
def consultar_carteira(cpf: str):
    return repo.get_by_cpf(cpf)

