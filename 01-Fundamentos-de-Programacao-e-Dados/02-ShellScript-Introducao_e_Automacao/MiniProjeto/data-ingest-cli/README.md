# Data Ingest CLI

Mini Projeto desenvolvido em Shell Script (Bash) para automação da triagem, validação e organização de dados brutos na primeira milha de uma esteira de Engenharia de Dados.

---

## 🎯 Objetivo

Atuar como um *gatekeeper* de dados na borda: validar a integridade de arquivos `.csv` recebidos antes de liberar o processamento para ferramentas mais pesadas (como Python, PySpark ou bancos de dados), isolando arquivos corrompidos e particionando os válidos por data.

---

## ⚙️ Utilidade & Benefícios

* **Economia de Computação:** Evita rodar jobs pesados em arquivos vazios ou sem dados reais.
* **Organização em Camadas:** Move dados íntegros para a camada `raw/` com particionamento temporal (`YYYY-MM-DD`).
* **Quarentena Automática:** Isola arquivos corrompidos/vazios na pasta `quarantine/` para posterior auditoria.
* **Auditoria Contínua:** Registra execuções, contagem de registros e status em arquivo de log estruturado.

---

## 📁 Estrutura de Pastas

```text
data-ingest-cli/
├── data/
│   ├── landing/       # Diretório de entrada dos arquivos novos
│   ├── raw/           # Arquivos válidos organizados por data (ex: 2026-08-27/)
│   └── quarantine/    # Arquivos que falharam nas regras de qualidade
├── logs/
│   └── pipeline.log   # Histórico de execução com timestamps
└── pipeline.sh        # Script principal de ingestão