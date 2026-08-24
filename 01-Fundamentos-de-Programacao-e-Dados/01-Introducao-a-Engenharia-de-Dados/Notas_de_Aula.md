# Introdução à Engenharia de Dados

**Sumário:**


---

O **curso Introdução à Engenharia de Dados** foi criado para quem deseja compreender, de forma prática e didática, como funciona o universo dos dados e o papel do engenheiro de dados nesse ecossistema. Ao longo das aulas, você vai aprender desde os conceitos fundamentais, como o ciclo de vida dos dados e os tipos de processamento, até estruturas modernas, como Data Lakes, Data Warehouses e a arquitetura em camadas (Bronze, Silver, Gold). O curso também apresenta as principais ferramentas utilizadas no mercado, caminhos de carreira e um mini projeto guiado para aplicar o que foi aprendido.

## 1. O Que é a Engenharia de Dados?

A Engenharia de Dados projeta, constrói e mantém a infraestrutura que transforma dados brutos em ativos confiáveis, seguros e de alta qualidade. Ela sustenta as camadas downstream (Analytics, BI, Data Science e Machine Learning), eliminando o gargalo operacional em que cientistas de dados perdem a maior parte do tempo limpando dados em vez de gerar inteligência de negócio.

### Papel e Responsabilidade do Engenheiro

- Assume a infraestrutura de Coleta, Armazenamento e Transformação de dados.
- Garante a resiliência (tolerância a falhas), escalabilidade, governança/segurança e eficiência de custos.
- Cientistas de dados focam em modelagem estatística e preditiva, enquanto engenheiros de dados focam na estabilidade do fluxo de produção.

### As 5 Etapas do Ciclo de Vida da Engenharia de Dados

1. **Geração (Origem Externa):** Criação dos dados em fontes transacionais (OLTP, IoT, APIs de terceiros).
    - Ex: PostgreSQL, Salesforce API.
2. **Ingestão (Movimentação):** Transporte do ponto de origem para a infraestrutura de dados (modos Push/Pull, em Batch ou Streaming). 
    - Ex: Airbyte, Fivetran.
3. **Armazenamento (Persistência):** Local onde os dados residem e persistem durante todo o ciclo.
    - Ex: AWS S3, Snowflake, Google BigQuery.
4. **Transformação (Modelagem):** Processamento que converte o dado bruto em formato limpo, estruturado e aderente às regras de negócio.
    - Ex: dbt.
5. **Disponibilização (Consumo):** Entrega do dado tratado para o ecossistema final: Dashboards de BI, Feature Stores para ML ou ferramentas operacionais via Reverse ETL.
    - Ex: Power BI, Hightouch.

Sem uma engenharia sólia nas etapas 1 a 4, as pontas analíticas operam sobre dados inconsistentes ou enfrentam quebras constantes de pipeline.

---

## 2. Arquitetura de Pipelines de Dados

Um Pipeline de Dados é o conjunto de arquitetura, sistemas e processos projetados para movimentar, tratar e disponibilizar dados ao longo de seu ciclo de vida. A transição de **ETL** (legado/on-premise) para **ELT** (moderno/cloud) foi impulsionada pela redução de custos de armazenamento e pelo desacoplamento entre poder computacional e disco.

### ETL vs. ELT

| ATRIBUTO | ETL (Extract, Transform, Load) | ELT (Extract, Load, Transform) |
| :--- | :--- | :--- |
| Paradigma | Legado (anos 1980-2000; on-premise) | Moderno (Cloud-native; elástico) |
| Gargalo Histórico | Armazenamento e computação analítica caros. | Nenhum; Infraestrutura em nuvem barata e elástica |
| Onde Ocorre a Transformação | Servidor/motor intermediário externo (Spark, MapReduce) | Dentro do próprio Data Warehouse/Lakehouse (Big Query, SnowFlake) |
| Preservação de Dados Brutos | NÃO. Dados não selecionados/transformados são descartados | SIM. Dados brutos persistem intactos no Staging/Object Storage. |
| Reprocessamento Histórico | Difícil/Impossível sem re-extrair da fonte de origem. | Simples: Reprocessa a partir do dado bruto já armazenado. |
| Stack Típica | Servidores dedicados de processamento + Data Marts | Ferramentas de ingestão (Airbyte/Fivetran) + S3/DW + SQL/dbt |

#### Detalhamento dos Fluxos

**Fluxo ETL:**

1. **Extract:** Extração de snapshots ou logs transacionais (OLTP);
2. **Transform:** Limpeza, joins, tipagem e agregações em nó intermediário para reduzir volume antes do destino;
3. **Load:** Carga do dado final já modelado (ex: Kimball) no Data Warehouse;

#### Relações e Dependências Críticas

- A nuvem viabiliza o ETL porque permite guardar volumes massivos a custo irrisório e alocar CPU/memória sob demanda apenas na execução das queries de transformação.
- No ELT, o armazenamento do dado bruto desacopla o pipeline da volatilidade das regras analíticas. Alterações de regra de negócio demandam apenas uma nova query sobre o Staging, sem onerar as bases transacionais de produção.

---

## 3. Arquitetura de Armazenamento e Processamento

A escolha entre **Batch** e **Streaming** define a latência de entrega, a complexidade operacional e o custo da infraestrutura. Enquanto o Batch impõe fronteiras temporais artificiais sobre fluxos contínuos, o Streaming processa eventos em seu estado natural em tempo real.

| ATRIBUTO | PROCESSAMENTO EM LOTE (Batch) | PROCESSAMENTO EM FLUXO (Streaming) |
| --- | --- | --- |
Natureza dos Dados | Limitados (_Bounded_ por tempo/tamanho) | Ilimitados (_Unbounded_, orientados a eventos) 
Latência | Média a alta (minutos, horas, dias) | Sub-segundo a poucos segundos
Custo & Complexidade | Baixo custo relativo; manutenção simples | Alto custo computacional; alta complexidade
Gatilho de Execução | Agendamentos fixos (_schedules_) | Chegada contínua de eventos (_event-driven_)
Casos de Uso Típicos | Relatórios diários, fechamento contábil, BI | Fraude em tempo real, telemetria/IoT crítica
Stack Típica | Airflow, dbt, SnowFlake, Spark Batch | Apache Kafka, AWS Kenisis, Spark Streaming, Flink

O processamento em lote permanece como padrão da indústria por atender à cadência de tomada de decisão da maioria das empresas sem inflacionar custos de infraestrutura. O streaming é reservado estritamente para cenários onde a latência sub-segundo dita o valor do negócio.

### Fundamentos de Streaming e Janelas Temporais

Para aplicar agregações analíticas (médias, constantes) sobre fluxos contínuos, delimita-se o dado por meio de janelas de tempo:

- **Dimensões Temporais:**
    - Tempo do Evento (_Event Time_): Momento exato em que o fato ocorreu na origem;
    - Tempo de Ingestão (_Ingestion Time_): Momento em que o evento atingiu o broker/pipeline;
    - Tempo de Processamento (_Processing Time_): Momento em que o motor executa a transformação;
- **Tipos de Janelas:**
    - Tumbling (Fixas): Intervalos contíguos e não sobrepostos (ex: a cada 5 min).
    - Sliding (Deslizantes): Intervalos de duração fixa com sobreposição (ex: média da última hora recalculada a cada 10 min).
    - Sessão (Session): Agrupamento baseado em períodos de atividade, fechando após um limite (gap) de inatividade.
- **Tolerância a Atrasos:** Uso de marcas d'água (_watermarks_) para definir limites de tolerância para eventos atrasados no tempo do evento.

### Segurança e Governança de PII (Personally Identifiable Information)

A anonimização e a proteção de dados sensíveis (CPFs, e-mails) são obrigatórias antes da chegada aos consumidores analíticos:

- **Em Batch:** Mascaramento e hashing unidirecional (ex: **SHA-256**) aplicados diretamente no momento da ingestão ou na _Staging Area_ (camada Raw/Bronze).
- **Em Streaming:** Tratamento _in-flight_ (em trânsito) via processadores de stream ou funções serveless (AWS Lambda, Cloud Functions, Spark Streaming) antes da persistência em disco no armazenamento final.

Em ambos os paradigmas, a regra de ouro de governança é a mesma: dados sensíveis nuncan devem ser persistidos desprotegidos nas camadas intermediárias ou finais de consumo.

### Abstrações de Armazenamento: Data Warehouse, Lake e LakeHouse

A arquitetura de armazenamento analítico evoluiu em três gerações para equilibrar desempenho, flexibilidade de tipos de dados, custo e governança:

1. **Data Warehouse:** Estruturado, transações ACID e consultas SQL ultra-rápidas, mas rígido e caro.
2. **Data Lake:** Barato, elástico e aberto a qualquer formato bruto, mas sem governança nativa e sem suporte direto a mutações ACID.
3. **Data Lakehouse:** Combina o baixo custo do _Object Storage_ do Data Lake com o controle transacional ACID, governança e desempenho do Data Warehouse.

DIMENSÃO | DATA WAREHOUSE (DWH) | DATA LAKE | DATA LAKEHOUSE
| --- | --- | --- | --- |
Tipos de Dados | Apenas Estruturados | Todos: Estruturados, Semi e Não Estruturados | Todos: Estruturados, Semi e Não Estruturados
Abordagem de Esquema | Schema-on-Write (rígido na gravação) | Schema-on-Read (Flexível na Leitura) | Híbrido: Schema-on-Write em tabelas + Schema-on-Read no Raw
Transações ACID | Nativas e Completas | Inexistentes ou manuais/complexas | Nativas e completas via camada de metadados
Custo de Storage | Médio a Alto | Muito Baixo (Object Storage / S3 / GCS) | Muito Baixo (Object Storage + computação elástica)
Padrão da Mutação | `UPDATE`, `DELETE`, `MERGE` nativos | Imutável / WORM (recriação de arquivos em lote) | `UPDATE`, `DELETE`, `MERGE` via ponteiros de metadados
Consumidores Típicos | Analistas de BI e SQL | Cientistas de Dados e Engenheiros de ML | Unificado: BI, SQL, ML, Data Sciente e Apps
Stack de Referência | Snowflake, BigQuery, Redshift | Hadoop (HDFS), AWS S3, Google Cloud Storage | Delta Lake, Apache Iceberg, Apache Hudi

#### Data Warehouse (DWH)

- Objetivo: Isolar a carga analítica (OLAP) do banco transacional operacional (OLTP);
- Modelagem: Estruturas dimensionais clássicas (esquema estrela de Kimball: Fatos e Dimensões) e Data Marts.
- Governança: Controle de acesso granular via DCL (`GRANT`/`REVOKE` em tabelas, colunas e linhas).
- Limitação: Custo elevado para armazenar mídias/logs brutos e incapacidade de lidar diretamente com arquivos não estruturados.

#### Data Lake

- Objetivo: Repositório centralizado de dados brutos e massivos em seus formatos originais (JSON, Parquet, imagens, áudio).
- Mecanismo: Desacoplamento total entre armazenamento (S3/GCS) e computação (Spark).
- Gatgalos Críticos:
    - **Data Swamp:** Degradação em um "pântano de dados" por ausência de catálogos e controle de qualidade.
    - **Incompatibilidade LGPD/GDPR:** Por seguir o modelo WORM (_Write Once, Read Many_), atender ao "direito ao esquecimento" exige reprocessar e reescrever partições inteiras de arquivos Parquet manualmente.

#### Data Lakehouse

- Estrutura em Camadas:
    1. **Consumo:** SQL, BI, Modelos de Machine Learning e Python;
    2. **Metadados & ACID:** Motores de tabela aberta (Delta Lake, Apache Iceberg, Apache Hudi);
    3. **Armazenamento:** Object Storage imutável e de baixo custo (S3, GCS, ADLS);
- Operações Avançadas:
    - Suporte nativo a `MERGE`, `UPSERT` e `DELETE`;
    - **Versionamento & Rollback:** _Time Travel_ através do histórico de logs e metadados;
    - **Privacidade e LGPD:** A deleção ou anonimização de registros altera os ponteiros e metadados lógicos sem demandar a recriação manual destrutiva do storage subjacente;
- **Eliminação de Silos:** O Lakehouse elimina a necessidade de duplicar dados do Lake para um DWH separado, unificando a fonte de verdade para ciência de dados e inteligência de negócios em uma única camada de governança.

---

## 4. Arquitetura Medallion

A Arquitetura Medallion (Bronze, Silver e Gold) é um padrão de design incremental de armazenamento e refinamento de dados para Data Lakehouses (popularizado pela Databricks). Seu objetivo primário é estruturar a governança e o fluxo de dados em estágios lógicos, impedindo que o Data Lake degenere em um **Data Swamp**.

### Fundamentos de Infraestrutura Física

- Desacoplamento Computação vs. Armazenamento:
    - **Armazenamento (Storage):** Persistência física em _Object Storage_ de nuvem elástico e de baixo custo (AWS S3, Google Cloud Storage, Azure ADLS).
    - **Computação (Compute):** Instanciação sob demanda de clusters temporários de processamento (ex: Apache Spark via Databricks ou AWS EMR) que são destruídos imediatamente após a execução da carga, eliminando custos ociosos de máquinas 24/7.
- Formato de Arquivos: Armazenamento colunar compactado e imutável (predominantemente **Apache Parquet**).
- Camada de Metadados Abertos: Uso de Delta Lake ou Apache Iceberg sobre os arquivos Parquet para viabilizar:
    - Transações ACID completas em ambiente distribuído.
    - Operações de mutação analítica (`UPSERT`, `MERGE` e `DELETE`).
    - Consistência entre leituras e escritas concorrentes.
- O isolamento das camadas físicas de dados somado a motores de metadados abertos permite processar grandes volumes com custo computacional estritamente proporcional ao tempo de execução das transformações, mantendo rastreabilidade e integridade total dos dados.

### Camada Bronze (Raw/Staging)

A Camada Bronze é o ponto de entrada da arquitetura analítica. Sua função primária é a preservação histórica e imutável dos dados brutos, retendo a estrutura e o esquema originais exatamente como fornecidos pelas fontes de origem (OLTP, APIs, SaaS).

Ela funciona como o backup analítico imutável. Qualquer falha posterior em regras de negócio na Silver ou Gold pode ser corrigida reprocessando a partir do dado bruto persistido na Bronze, sem necessidade de reonear os bancos de produção.

#### Papel das Ferramentas no Ecossistema

- **Ingestão Gerenciada (Airbyte / Fivetran):** Conectam-se às fontes e descarregam os registros brutos no _Object Storage_. Realizam extrações via:
    - Snapshots periódicos: Capturas pontuais de estado.
    - Change Data Capture (CDC): Leitura de logs binários transacionais em tempo real, eliminando sobrecarga no banco de produção.
- **Orquestração (Apache Airflow):** Agenda, engatilha e monitora a execução das tarefas de ingestão, validando a integridade da entrega dos arquivos no storage.
- **Linhagem e Rastreabilidade (dbt):** Mapeia a camada bronze por meio de arquivos declarativos de configuração (`sources.yml`), estabelecendo a raiz da linhagem dos dados sem apicar transformações de negócio nesta etapa.

#### Segurança e Governança LGPD na Borda

A camada Bronze atua como a primeira linha de defesa para proteção de PII (Personally Identifiable Information):
    - Descarte Preventivo: Atributos sensíveis desnecessários para casos analíticos/ML devem ser eliminados antes da gravação no Object Storage.
    - Anonimização Irreversível: Quando o identificador for indispensável para junções e integridade referencial downstream, aplica-se hashing unidirecional com SHA-256 ou mascaramento diretamente na ingestão.
    - Mitigação de Riscos: Impede que dados em texto claro fiquem expostos no Data Lake em cenários de vazamento ou acesso indevido ao storage.

### Camada Silver (Cleaned/Enriched)

A Camada Silver é o estágio de higienização, tipagem, deduplicação e estruturação dos dados brutos da Bronze. Ela cria uma visão empresarial padronizada e enriquecida, servindo de fundação técnica antes da modelagem dimensional final voltada para as áreas de negócio.

#### Processamento e Ferramentas

- **Apache Spark (PySpark):** Empregado para processamento distribuído de Big Data em mória sobre arquivos Parquet/Delta.
    - Utiliza _Broadcast Joins_ para lookup com tabelas pequenas e _Shuffle Hash Joins_ para cruzamento de grandes volumes entre nós do cluster.
- **dbt (Data Build Tool):** Framework declarativo para gerenciar a lógica de transformação SQL. Não possui motor computacional próprio e não armazena dados. Atua como compilador (SQL + Jinja), resolvendo dependências hierárquicas e linhagem via função `ref()` para gerar um "Grafo Acíclico Dirigido (DAG)". É dividido estruturalmente em dois níveis:
    - Staging Models(`stg_`): Camada de saneamento inicial. Executa limpeza leve, renomeação padronizada de coluans e coerção de tipos (ex: `STRING` para `TIMESTAMP`).
    - Intermediate Models (`int_`): Camada de junção e enriquecimento. Executa regras estruturais, joins pesados entre entidades, deduplicações e agregações intermediárias.
    
A camada Silver padroniza as entidades do negócio sem acoplar a ferramenta de modelagem (dbt) ao armazenamento físico, garantindo modularidade e governança de código versioando (CI/CD) antes da entrega na Gold.

---

### Camada Gold (Business-Ready)

A Camada Gold é o estágio final de entrega analítica da arquitetura Medallion. Nela, os dados tratados e higienizados da camada Silver são agregados, contextualizados e estruturados segundo a semântica e os objetivos estratégicos do negócio para consumo direto por BI, Analytics e Machine Learning.

É a camada responsável por isolar os usuários finais das complexidades técnicas das camadas Bronze e Sivler. Qualquer modificação de regra semântica é resolvida no código SQL versionado do dbt, mantendo as tabeals analíticas físicas sempre íntegras e com alta performance.

#### Estratégias de Modelagem na Camada Gold

O engenheiro de dados adota prioritariamente duas abordagens de modelagem analítica na camada Gold:

**Modelagem Dimensional de Ralph Kimball (Star Schema)**

- Tabelas Fato: Armazenam eventos numéricos e métricas quantificáveis de negócio (Ex: vendas, transações, logins).
- Tabelas Dimensão: Armazenam o contexto descritivo dos fatos (ex: clientes, lojas, categorias, calendário).
- Vantagem: Reduz a complexidade de joins lógicos e oferece uma estrutura intuitiva para analistas e usuários de negócio.

**One Big Table (OBT - Tabela Única Desnormalizada)

- Estrutura: Consolidação de fatos e todas as suas dmensões em uma única tabela ampla e totalmente desnormalizada.
- Viabilidade e Ganho: Aproveita o baixo custo de storage em nuvem e a eficiência de bancos colunares MPP, eliminnado completamente a necessidade de joins em tempo de consulta nos dashboards.

#### Estruturação da Camada Gold no dbt

- **Mart Layer:** Organização final no dbt contendo os modelos de negócio (`fct_` e `dim_` ou `obt`).
- **Materialização:** Frequentemente materializados como tabelas físicas no Data Warehouse/Lakehouse para garantir tempos de resposta mínimos em consultas analíticas repetitivas.
- **Consumo Seguro:** Camada exposta diretamente para ferramentas de visualização (Power BI, Looker, Tableau), Feature Stores e modelos preditivos de ML.

