from fastapi import APIRouter
from repositories.client_repository import ClientRepository

router = APIRouter(prefix="/clientes", tags=["Clientes"])
repo = ClientRepository()

@router.get("")
def listar_clientes():
    return repo.get_all()

