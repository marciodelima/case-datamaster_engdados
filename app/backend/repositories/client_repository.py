from models.client import Cliente

class ClientRepository:
    def get_all(self) -> list[Cliente]:
        # Simulação de dados
        return [
            Cliente(cpf="11111111111", nome="João Silva", perfil="moderado"),
            Cliente(cpf="22222222222", nome="Maria Souza", perfil="arrojado")
        ]

    def get_by_cpf(self, cpf: str) -> Cliente:
        return next(c for c in self.get_all() if c.cpf == cpf)
