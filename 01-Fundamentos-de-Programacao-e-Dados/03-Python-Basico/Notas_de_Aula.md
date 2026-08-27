# Lógica de Programação: Python Básico

**Sumário:**


---

## 1. Introdução à Programação em Python e Mentalidade de Desenvolvimento em Dados

O desenvolvimento em Python para Engenharia de Dados transcende a escrita de scripts funcionais locais e exige aplicação de princípios de engenharia de software, automação não interativa, resiliência operacional e governança estrita de segurança e privacidade.

### Progressão Lógica e Decomposição Funcional

#### Decomposição Estruturada de Problemas
* **Abstração:** Capacidade de fragmentar fluxos complexos de dados (ex.: integração de múltiplas fontes heterogêneas) em tarefas isoladas, testáveis e modulares.
* **Prevenção de Falhas Críticas (*Datastrophes*):** Mapeamento antecipado de fluxos alternativos, tratamento de casos de borda (*edge cases*) e prevenção contra anomalias de entrada que possam corromper *Data Lakes*, derrubar bancos analíticos ou vazar informações.
* **Isolamento de Responsabilidades:** Separação clara entre a lógica de negócios e os detalhes da infraestrutura física subjacente.

### A Estrutura do Programa Analítico: Entrada, Processamento e Saída (IPO)

#### Entrada (*Input*) Programática e Automatizada
* **Abandono de Interfaces Interativas:** Em produção, dispensa-se a entrada manual via teclado (`input()`).
* **Ingestão Automatizada:** O script consome dados programaticamente via leitura de arquivos colunares ou semiestruturados (Parquet, CSV, JSON), queries SQL em bancos transacionais (OLTP) ou extrações via endpoints de APIs REST.

#### Processamento (*Processing*) e Governança de PII (LGPD/GDPR)
* **Transformação em Memória:** Aplicação de regras de negócio, validação de esquemas, tratamento de nulos e coerção de tipos utilizando estruturas como DataFrames (Pandas/PySpark).
* **Descarte Preventivo de PII:** Identificadores pessoais desnecessários para modelos de ML ou relatórios downstream devem ser eliminados na entrada do fluxo.
* **Anonimização *In-Flight*:** Quando a retenção de identificadores for mandatória para integridade referencial, aplica-se mascaramento ou criptografia de mão única (hashing irreversível com SHA-256) em memória antes da persistência em disco.

#### Saída (*Output*) e Observabilidade
* **Persistência de Qualidade:** Gravação de dados refinados em *Object Storage* (AWS S3, GCS, ADLS) ou carregamento direto em *Data Warehouses* analíticos (Snowflake, BigQuery).
* **Emissão de Metadados:** Geração de logs estruturados e métricas de status para alimentar plataformas de observabilidade e monitoramento de integridade.

### Mentalidade de Desenvolvimento: Automação, Nuvem e Boas Práticas

#### Execução Autônoma e Não Interativa
* **Scripts *Headless*:** Softwares de dados operam de forma isolada dentro de contêineres Docker ou instâncias em nuvem, orquestrados autonomamente por plataformas como Apache Airflow.
* **Desacoplamento de Credenciais:** Configurações, parâmetros de execução e segredos nunca devem residir *hardcoded* no código-fonte; devem ser injetados dinamicamente via variáveis de ambiente.

#### Padrões de Código e Manutenibilidade
* **Guia de Estilo PEP 8:** Adoção de convenções formais de nomenclatura (`snake_case` para variáveis e funções), indentação e espaçamento, garantindo uniformidade e manutenibilidade em times multidisciplinares.
* **Tratamento Defensivo de Exceções (`try/except`):** Encapsulamento de chamadas instáveis (APIs de terceiros, conexões de rede, alterações de esquema) para interceptar falhas e disparar alertas ou retentativas controladas sem quebra abrupta do processo.
* **Desacoplamento e Responsabilidade Única (*Clean Code*):** Criação de módulos e funções especializadas com escopo único, impedindo que alterações estruturais nas fontes de origem propaguem refatorações destrutivas por todo o pipeline.

---

## 2. Logs, Observabilidade e Padronização de Monitoramento em Python

Em pipelines de dados executados em nuvem e contêineres, a saída padrão (*stdout*) serve como o canal primário de telemetria. A função `print()` atua como a interface direta para esse fluxo, exigindo estruturação rigorosa de dados (JSON/f-strings) para ingestão em agregadores de logs e conformidade estrita com normas de privacidade (LGPD/GDPR) para evitar vazamento de dados sensíveis.

### Mecanismo da Função print() e Direcionamento do Fluxo

#### Interface com o Standard Output (*stdout*)
* **Funcionamento Interno:** A função `print()` converte argumentos para texto via `str()`, insere delimitadores entre os itens, anexa uma quebra de linha (`\n`) e despacha o conteúdo para `sys.stdout.write()`.
* **Coerção Implícita:** Diferente de chamadas diretas a `sys.stdout.write()`, que exigem strings estritas, `print()` lida nativamente com a conversão de diferentes tipos de objetos.

#### Parâmetros de Controle
* **`sep`:** Define a string separadora entre múltiplos argumentos (padrão: espaço `' '`).
* **`end`:** Define o caractere final impresso após os argumentos (padrão: quebra de linha `'\n'`).
* **`file`:** Redireciona o fluxo de saída. O padrão é `sys.stdout`, mas pode receber descritores de arquivos abertos em disco para persistência local de logs.

### Comportamento do print() com Diferentes Tipos de Dados

#### Coerção e Renderização
* **Tipos Primitivos:** Inteiros, floats e booleanos são convertidos diretamente para suas representações textuais. Em números de ponto flutuante, `print()` oculta artefatos de precisão comuns na representação binária bruta do console interativo.
* **Coleções:** Listas, tuplas e dicionários são convertidos recursivamente para formatos legíveis.
* **Diferença entre `str()` e `repr()`:** `str()` foca na legibilidade para o usuário final (usada pelo `print()`), enquanto `repr()` foca na representação inequívoca para depuração. Objetos customizados sem os métodos mágicos `__str__` ou `__repr__` são impressos como endereços brutos de memória (`<... at 0x...>`).

### Observabilidade na Nuvem e Logs Estruturados

#### Canalização para Agregadores (CloudWatch, Datadog)
* **Ambiente *Headless*:** Em contêineres (Docker/Kubernetes) e funções *Serverless*, o *daemon* do ambiente captura tudo o que é enviado para o *stdout* e encaminha para serviços como AWS CloudWatch, Datadog ou Elasticsearch.
* **Necessidade de Estruturação:** Logs em texto livre dificultam a análise automatizada. O padrão de produção exige a emissão de strings estruturadas (preferencialmente JSON serializado) contendo metadados de execução.

#### Construção com f-strings e Serialização JSON
* **Vantagem das f-strings:** Avaliadas em tempo de execução com performance computacional superior e maior legibilidade em relação ao operador `+` ou `.format()`.
* **Indexação Automática:** A serialização de dicionários com `json.dumps()` permite que agregadores analisem chaves (`level`, `pipeline`, `metrics`) como dimensões de busca, viabilizando métricas de volumetria, alertas e dashboards operacionais em tempo real.

### Governança e Segurança: Prevenção contra Vazamento de PII (LGPD)

#### Risco de Exposição em Plataformas de Monitoramento
* **Vulnerabilidade:** Imprimir objetos brutos contendo PII (*Personally Identifiable Information* como CPF, e-mail, nomes ou dados bancários) expõe dados regulados em ferramentas de observabilidade de terceiros e para administradores de infraestrutura sem autorização de acesso.
* **Diretriz de Segurança:** PII nunca deve ser impresso em texto claro em nenhum nível de log.

#### Anonimização *In-Memory* com SHA-256
* **Aplicação em Trânsito:** Identificadores pessoais estritamente necessários para correlação de eventos devem ser convertidos em hash criptográfico unidirecional via biblioteca `hashlib` (SHA-256) antes da montagem do payload de log.
* **Rastreabilidade Segura:** A conversão garante que eventos possam ser correlacionados por suas chaves anonimizadas (`email_hash`, `cpf_hash`), preservando a privacidade dos titulares e garantindo conformidade com a LGPD e a GDPR.

### Exemplo Prático de Compliance LGPD ao registrar Logs

```python
import hashlib
import json
from datetime import datetime, timezone

# Dados brutos de exemplo
email_cliente = "gustavo.guanabara@provedor.com"
cpf_cliente = "12345678901"
faturamento_pedido = 350.00

# Aplicação de Hashing SHA-256 in-memory 
email_hash = hashlib.sha256(email_cliente.encode('utf-8')).hexdigest()
cpf_hash = hashlib.sha256(cpf_cliente.encode('utf-8')).hexdigest()

# O log registra apenas a transação com os dados sensíveis mascarados
log_seguro = {
    "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S"),
    "level": "INFO",
    "action": "pedido_processado",
    "email_hash": email_hash,
    "cpf_hash": cpf_hash,
    "valor_pedido": faturamento_pedido
}

# Impressão segura do log em formato JSON
print(json.dumps(log_seguro))
```

---

## 3. Variáveis, Tipos de Dados e Governança de Esquemas em Python

O domínio de tipos de dados em Python é a base para garantir a integridade estrutural entre scripts de extração/transformação e tabelas físicas em bancos analíticos. A tipagem correta previne *Schema Drift*, garante precisão em métricas financeiras e assegura conformidade com leis de privacidade (LGPD/GDPR).

### Modelo de Memória e Tipagem do Python

#### Referências de Memória e Dinâmica do Heap
* **Ponteiros de Memória:** Variáveis em Python funcionam como referências que apontam para objetos alocados dinamicamente no *heap*.
* **Tipagem Dinâmica:** O interpretador infere o tipo do dado em tempo de execução com base no valor atribuído, dispensando declarações estáticas prévias.
* **Tipagem Forte:** Operações implícitas entre tipos incompatíveis (ex.: somar `str` com `int`) são bloqueadas, exigindo coerção explícita de tipos no código do pipeline para evitar quebras em produção.

### Tipos Primitivos e Mapeamento para Data Warehouses (OLAP)

#### Tabela de Correspondência Estrutural
| Tipo Python | Classe | Equivalente no DW / OLAP | Caso de Uso em Dados |
| :--- | :--- | :--- | :--- |
| `int` | `int` | `INTEGER` / `BIGINT` | Chaves substitutas (*surrogate keys*), IDs, contagens. |
| `float` | `float` | `FLOAT` / `DOUBLE PRECISION` | Coordenadas geográficas, taxas percentuais, sensores. |
| `str` | `str` | `VARCHAR` / `TEXT` | Nomes, descrições, chaves textuais, URLs. |
| `bool` | `bool` | `BOOLEAN` | Flags de estado (`is_active`, `is_deleted`). |
| `None` | `NoneType` | `NULL` | Valores ausentes, campos opcionais, nulos relacionais. |

#### Prevenção de Desalinhamento de Esquema (*Schema Drift*)
* **Falhas de Transação:** A presença de strings residuais (`'N/A'`, `'R$ 100,00'`) em colunas mapeadas como numéricas provoca rejeição imediata da carga em lote no Data Warehouse.
* **Proibição de `float` em Cálculos Financeiros:** Devido à representação binária fracionária do padrão IEEE 754, `float` gera imprecisões decimais acumuladas. Em relatórios financeiros, é obrigatório o uso do módulo nativo `decimal.Decimal` (ponto fixo).

#### Tratamento de Ausência de Dados (`None` vs. Strings Vazias)
* **Distinção Crítica:** O objeto `None` deve ser mapeado explicitamente para o `NULL` do SQL.
* **Impacto Analítico:** Persistir dados ausentes como strings vazias (`""`) compromete *outer joins*, distorce agregações estatísticas (como `AVG` e `STDDEV`) e mascara a contagem real de registros ausentes.

### Operações Aritméticas e Manipulação de Chaves

#### Operadores Críticos em Processamento de Dados
* **Divisão Real (`/`):** Sempre converte o resultado para `float` no Python 3 (ex.: `4 / 2` resulta em `2.0`), exigindo atenção para não mutar esquemas de colunas inteiras.
* **Divisão de Piso (`//`):** Trunca o resultado decimal e retorna apenas a porção inteira.
* **Módulo (`%`):** Retorna o resto da divisão. Amplamente utilizado em pipelines para balanceamento de carga e partição lógica de dados entre múltiplos *threads* ou processos distribuídos (`id % total_threads`).

#### Interpolação Dinâmica e Surrogate Keys
* **Uso de f-strings:** Abordagem padrão para concatenação de strings; avalia expressões em tempo de execução com performance superior e coerção de tipos automática.
* **Geração de Chaves Compostas:** Concatenação de atributos textuais (ex.: `f"{loja_id}_{cliente_id}"`) para criação de chaves unificadas e alimentação de chaves substitutas (*Surrogate Keys*) em modelagens dimensionais de Kimball.

### Segurança e Compliance LGPD: Mascaramento com hashlib e SHA-256

#### Anonimização Irreversível de PII
* **Proteção na Borda:** Dados pessoais identificáveis (CPFs, e-mails, telefones) não devem transitar ou persistir em texto claro. Quando necessários para integridade analítica e cruzamentos, devem ser submetidos a *hashing* unidirecional (SHA-256) em memória.

#### Regra de Ouro da Normalização Pré-Hash
* **Efeito Avalanche:** Qualquer divergência em espaços residuais ou letras maiúsculas/minúsculas altera completamente a saída do hash.
* **Protocolo de Higienização Obrigatório:**
  1. `strip()`: Elimina espaços em branco no início e no final da string.
  2. `lower()`: Padroniza os caracteres para caixa baixa.
  3. Limpeza de caracteres não numéricos em documentos (ex.: remoção de `.` e `-` de CPFs).
  4. `.encode("utf-8")`: Converte a string tratada para o formato de bytes exigido pela biblioteca `hashlib`.

```python
import hashlib

# Dados brutos de exemplo
email_bruto = "  Carlos.Souza@provedor.com  "
cpf_bruto = "123.456.789-01"

# 2. Normalização dos dados
"""
    strip() - Remove espaços em branco no início e no fim da string
    lower() - Converte todos os caracteres para minúsculas
"""
email_normalizado = email_bruto.strip().lower()

# Removendo caracteres não numéricos do CPF
cpf_normalizado = cpf_bruto.replace(".", "").replace("-", "").strip()

# 3. Geração de Hashing SHA-256 via hashlib
"""
    O hashlib exige que a string vire bytes para gerar o hash. Isso é feito com o método encode('utf-8').
"""
email_bytes = email_normalizado.encode('utf-8')
email_hash = hashlib.sha256(email_bytes).hexdigest()

cpf_bytes = cpf_normalizado.encode('utf-8')
cpf_hash = hashlib.sha256(cpf_bytes).hexdigest()

# 4. Saída segura dos resultados
print(f"Email normalizado e hasheado: {email_hash}")
print(f"CPF normalizado e hasheado: {cpf_hash}")

```

---

