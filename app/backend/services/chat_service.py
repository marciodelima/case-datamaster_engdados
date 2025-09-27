from openai import OpenAI
from utils.rag import retrieve_context
from utils.cleaner import clean_question

class ChatService:
    def __init__(self, client_data, question):
        self.client_data = client_data
        self.question = clean_question(question)

    def is_valid_question(self) -> bool:
        return "ação" in self.question.lower()

    def generate_answer(self) -> str:
        if not self.is_valid_question():
            return "Desculpe, só posso responder perguntas sobre ações."

        context = retrieve_context(self.client_data.cpf, self.question)
        prompt = f"Cliente: {self.client_data.nome}, Perfil: {self.client_data.perfil}\nPergunta: {self.question}\nContexto: {context}\nResponda de forma clara e objetiva em português sobre ações brasileiras."

        return OpenAI().chat(prompt)

