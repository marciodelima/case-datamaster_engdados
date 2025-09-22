# DataMaster de Engenharia de Dados - F1rst - 2025

# Plataforma de Dados Financeiros Híbrida — Fabric + Databricks

## 🧠 Objetivo

Criar uma plataforma de dados moderna e escalável para ingestão, processamento, análise e monitoramento de grandes volumes de dados financeiros públicos e privados, com foco em investimentos, ativos e indicadores econômicos. A solução permite análises preditivas, insights via LLM, dashboards interativos e governança robusta.

---

## 🏗️ Arquitetura Técnica

- **Ingestão**: Microsoft Fabric Pipelines Gen2
- **Processamento**: Databricks com Spark e Delta Lake
- **Armazenamento**: Delta Lake com camadas Bronze, Silver, Gold
- **Governança**: Azure Purview + Unity Catalog
- **Observabilidade**: Azure Monitor, Log Analytics, Power BI
- **Segurança**: Key Vault, RBAC, mascaramento dinâmico
- **LLM**: Azure OpenAI + Semantic Link

---

## 📦 Componentes Provisionados

- Microsoft Fabric Workspace
- Azure Databricks Workspace
- ADLS Gen2 com containers bronze/silver/gold
- Azure Event Hubs
- Azure Purview
- Azure Key Vault
- Azure Log Analytics

---

## ⚙️ Execução

1. Configure os secrets no GitHub:
   - `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`
2. Faça push para o branch `main`
3. O GitHub Actions executará `terraform init`, `plan`, `apply`
4. Recursos serão provisionados automaticamente

---

## 📈 Observabilidade

- Infra: Azure Monitor + Log Analytics
- Jobs: Fabric Monitoring + Databricks REST API
- Negócio: Dashboards Power BI com KPIs de investimentos

---

## 🔐 Segurança e Governança

- Criptografia em trânsito e repouso
- Mascaramento dinâmico via Purview
- Unity Catalog com controle por tabela e coluna
- Key Vault para segredos e tokens

---

## 🧠 LLM e Insights

- Azure OpenAI para sumarização de eventos
- Semantic Link para explicações automáticas em dashboards

