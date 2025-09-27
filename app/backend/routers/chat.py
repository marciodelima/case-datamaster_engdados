from fastapi import APIRouter
from models.chat import ChatRequest
from repositories.client_repository import ClientRepository
from services.chat_service import ChatService

router = APIRouter(prefix="/clientes", tags=["Chat"])
repo = ClientRepository()

@router.post("/{cpf}/chat")
def chat(cpf: str, req: ChatRequest):
    cliente = repo.get_by_cpf(cpf)
    chat = ChatService(cliente, req.pergunta)
    return chat.generate_answer()

