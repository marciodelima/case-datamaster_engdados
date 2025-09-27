from models.acao import Acao

class CarteiraRepository:
    def get_by_cpf(self, cpf: str) -> list[Acao]:
        return [
            Acao(codigo="PETR4", nome="Petrobras", quantidade=100, recomendacao="Manter"),
            Acao(codigo="VALE3", nome="Vale", quantidade=50, recomendacao="Comprar")
        ]

