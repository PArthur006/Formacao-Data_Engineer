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
