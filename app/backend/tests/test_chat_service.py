from services.chat_service import ChatService
from models.client import Cliente

def test_valid_question():
    cliente = Cliente(cpf="123", nome="João", perfil="moderado")
    chat = ChatService(cliente, "Quais ações devo comprar?")
    assert chat.is_valid_question() is True

def test_invalid_question():
    cliente = Cliente(cpf="123", nome="João", perfil="moderado")
    chat = ChatService(cliente, "Qual é a capital da França?")
    assert chat.is_valid_question() is False

