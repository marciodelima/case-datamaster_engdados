# DataMaster de Engenharia de Dados – F1rst – 2025

## Plataforma de Dados Financeiros Híbrida — Azure Functions + Databricks + IA

---

## Objetivo

Desenvolver uma plataforma moderna, escalável e inteligente para ingestão, processamento, análise e monitoramento de grandes volumes de dados financeiros públicos e privados, com foco em investimentos em ações brasileiras de perfil dividend yield. A solução combina arquitetura híbrida na Azure com componentes de IA, governança, observabilidade e FinOps, permitindo:

- Análises preditivas e comparativas
- Avaliação de qualidade de dados (data quality)
- Geração de insights via LLMs e embeddings
- Dashboards interativos e relatórios analíticos
- Governança robusta com lineage e catálogo
- Monitoramento técnico e de negócio
- Segurança de credenciais e controle de acesso
- Otimização de custo com uso eficiente de recursos

---

## Sumário

- [Arquitetura](arquitetura.md)
- [Ferramentas e Tecnologias](ferramentas.md)
- [Instalação e Execução](instalacao.md)
- [Infra como Código (IaC)](iac.md)
- [Governança e Segurança](governanca.md)
- [Observabilidade](observabilidade.md)
- [Limitações do Azure Free](limites-azure-free.md)

---

## Visão Geral da Arquitetura

A plataforma é composta por múltiplos módulos integrados e distribuídos na Azure:

- **Ingestão de dados estruturados** via Azure Functions
- **Ingestão de dados não estruturados e streaming** via Azure Event Hub (notícias, comunicados, mídias)
- **Armazenamento analítico** em Delta Lake com arquitetura Medallion (Bronze, Silver, Gold)
- **Processamento vetorial** com PostgreSQL + pgvector
- **Tratamento semântico e enriquecimento** com OpenAI (embedding, resumo, classificação)
- **Governança de dados** com Unity Catalog e Azure Purview
- **Segurança de credenciais** via Azure Key Vault
- **Interface interativa** com App Databricks (front-end em widgets, backend em Python)
- **Deploy automatizado** via GitHub Actions
- **Observabilidade** com logs, métricas e alertas integrados

---

## Justificativas Técnicas

### Escolha da Azure como plataforma

- Integração nativa entre Databricks, Key Vault, Purview, PostgreSQL, Event Hub e Functions
- Suporte completo à arquitetura Lakehouse com Delta Lake
- Ferramentas de governança e segurança corporativas
- Modelo de cobrança granular que favorece FinOps

### Azure Event Hub para ingestão de notícias

- Suporte nativo a ingestão em tempo real
- Escalabilidade horizontal para múltiplas fontes simultâneas
- Integração direta com Databricks Structured Streaming
- Permite enriquecer relatórios com contexto de mercado e eventos externos

### Arquitetura Híbrida

- **Functions** para ingestão sob demanda e escalável
- **Event Hub** para ingestão contínua e streaming de notícias
- **Databricks** para processamento analítico e visualização
- **PostgreSQL** para armazenamento vetorial e recuperação semântica
- **OpenAI** para enriquecimento de dados e geração de insights
- **Purview + Unity Catalog** para rastreabilidade, lineage e controle de acesso

---

## FinOps e Otimização de Custo

- Clusters **single node** com VMs leves (ex: Standard_DS2_v2)
- Armazenamento em Delta Lake com compactação e Z-Ordering
- PostgreSQL com pgvector em instância mínima
- Functions e Event Hub com escalabilidade sob demanda
- Uso de serviços gratuitos ou em camada básica sempre que possível

---

## Arquitetura Medallion

- **Bronze**: ingestão bruta de dados financeiros, relatórios e notícias
- **Silver**: limpeza, normalização e enriquecimento semântico
- **Gold**: agregações analíticas, indicadores e dashboards

---

## Arquitetura de Software

- Modularização em componentes: ingestão, processamento, IA, interface
- Separação clara entre front-end (widgets) e backend (consultas e gráficos)
- Deploy automatizado via GitHub Actions com empacotamento e upload para workspace
- Conexão segura com PostgreSQL via Azure Key Vault

---

## Arquitetura de IA

- Embeddings gerados com **OpenAI** e armazenados em pgvector
- Recuperação semântica com distância vetorial
- Geração de relatórios com base em prompt + dados estruturados + contexto de notícias
- Visualização com matplotlib inline no App

---

## Observabilidade

- Logs de execução no Databricks, Azure Functions e Event Hub
- Monitoramento de quota via Azure Monitor
- Alertas configuráveis para uso de núcleos, armazenamento e falhas de ingestão

---

## Governança e Segurança

- Credenciais armazenadas no **Azure Key Vault**
- Permissões via **Managed Identity** e **Access Connector**
- Governança de dados via **Unity Catalog** e **Azure Purview**
- Controle de acesso por **Cluster Policies** e RBAC

---

## Deploy Automatizado

Todo o projeto é integrado com GitHub Actions para deploy contínuo. A cada push na branch `main`, os seguintes componentes são empacotados e implantados automaticamente:

- Notebooks e scripts Python no workspace Databricks
- Aplicação interativa (App)
- Configurações de ingestão e processamento
- Componentes auxiliares de visualização e IA

**Importante**: o módulo `iac/first` (infraestrutura base via Terraform) deve ser executado manualmente por questões de segurança e controle de provisionamento.

---

## Limitações do Azure Free Tier

O plano gratuito da Azure impõe restrições que impactam diretamente a arquitetura:

- Quota de núcleos limitada (ex: 4 vCPUs por região)
- Limite de Key Vaults, segredos e PostgreSQL gerenciado
- Sem suporte a Unity Catalog completo e Purview corporativo
- Sem Databricks Premium features (ex: Jobs, Apps avançados)
- Limitações de rede, escalabilidade e armazenamento
- Event Hub com throughput limitado e sem retenção estendida

Essas limitações exigem uso de clusters single node, VMs leves, e armazenamento otimizado.

---

