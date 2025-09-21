# DataMaster de Engenharia de Dados - F1rst - 2025

# Plataforma de Dados Financeiros com Microsoft Fabric

## I. Objetivo do Case

Desenvolver uma plataforma de dados moderna e escalável para ingestão, processamento, análise e monitoramento de grandes volumes de dados financeiros públicos e privados, com foco em investimentos, ativos e indicadores econômicos. A solução permite análises preditivas, sumarização de eventos e insights automáticos via LLM, garantindo segurança, observabilidade, compliance e dashboards de negócio.

---

## II. Arquitetura de Solução

### Componentes

- **Ingestão de Dados**: Dataflows Gen2 (batch), Eventstreams (streaming)
- **Processamento**: Lakehouse com Spark runtime, Notebooks, Pipelines
- **Armazenamento**: OneLake com camadas bronze/silver/gold
- **Análise com LLM**: Azure OpenAI + Semantic Link
- **Visualização**: Power BI nativo no Fabric
- **Observabilidade**: Fabric Monitoring + Purview
- **Segurança**: RBAC, mascaramento dinâmico, criptografia, LGPD compliance

### 📊 Diagrama de Arquitetura

[Fontes de Dados] ↓ [Ingestão] ↓ [Lakehouse] ↓ [Processamento] ↓ [LLM + Dashboards] ↓ [Observabilidade + Segurança]


---

## III. Execução do Projeto

### Requisitos

- Azure CLI
- Terraform ≥ 1.5
- GitHub Actions configurado com secrets:
  - `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_TENANT_ID`
  - `AZURE_SUBSCRIPTION_ID`, `AZURE_RESOURCE_GROUP`

### Provisionamento via GitHub Actions - IAC

1. Clone o repositório
2. Configure os secrets no GitHub
3. Execute o workflow `deploy.yml`

---

## IV. Escalabilidade

- Serverless Spark com auto-scale
- Eventstreams com múltiplos consumidores
- Pipelines paralelos e particionamento por ativo/data

---

## V. Segurança e Mascaramento

- Criptografia em repouso e em trânsito
- RBAC por workspace e item
- Mascaramento via Purview
- Auditoria e rastreabilidade nativas

---

## VI. Reprodutibilidade

- Infraestrutura como código via Terraform
- Notebooks versionados
- README com instruções claras
- Workspace templates para replicação

---

## VII. Melhorias Futuras

- Integração com Azure ML para modelos preditivos
- API REST para servir insights em tempo real
- Expansão para múltiplos países e moedas


