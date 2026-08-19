# Introdução à Engenharia de Dados

**Sumário:**


---

O **curso Introdução à Engenharia de Dados** foi criado para quem deseja compreender, de forma prática e didática, como funciona o universo dos dados e o papel do engenheiro de dados nesse ecossistema. Ao longo das aulas, você vai aprender desde os conceitos fundamentais, como o ciclo de vida dos dados e os tipos de processamento, até estruturas modernas, como Data Lakes, Data Warehouses e a arquitetura em camadas (Bronze, Silver, Gold). O curso também apresenta as principais ferramentas utilizadas no mercado, caminhos de carreira e um mini projeto guiado para aplicar o que foi aprendido.

## 1. O Que é a Engenharia de Dados?

Engenharia de dados é o desenvolvimento, implementação e manutenção de sistemas e processos que recebem dados brutos e produzem informações consistentes e de alta qualidade para suportar casos de uso downstream, como análise de dados e machine learning.

No mercado corporativo, cerca de 70% a 80% do tempo de um Cientista de Dados é desperdiçado de forma desorganizada coletando, limpando e preparando dados. Cientistas não são treinados para construir sistemas tolerantes a falhas, escaláveis e em nível de produção
O Engenheiro de Dados entra em cena para assumir as três camadas da base dessa pirâmide: **Coleta, Armazenamento e Transformação**. Ele garante que i pipeline não quebre, que a arquitetura seja econômica e que o dado chegue limpo, seguro e pronto.

### O Ciclo de Vida dos Dados

O ciclo de vida geral dos dados abrange toda a vida útil do dado na terra, desde a criação até o descarte ou arquivamento final. É o processo que inclui a geração, coleta, processamento, armazenamento, análise, visualização e eventual eliminação ou arquivamento.

O ciclo de Vida da Engenharia de Dados é dividido em 5 etapas sequenciais

1. **Geração:** Sistemas de origem que criam o dado (OLTP, IoT, APIs de terceiros). Nós não os controlamos, mas precisamos entendê-los.
    - Exemplo de Stack: PostgreSQL de produção, APIs REST do Salesforce
2. **Ingestão:** O processo de mover o dado do ponto A para o ponto B (Push, Pull, Batch ou Streaming).
    - Exemplo de Stack: Airbyte ou Divetran puxando dados via API e jogando no Storage.
3. **Armazenamento:** Onde os dados persistem ao longo de todo o ciclo.
    - Exemplo de Stack: Amazon S3 (Object Storage), Snowflake ou Google BigQuery.
4. **Transformação:** Alterar o dado de sua forma bruta para um formato útil e modelado para o negócio.
    - Exemplo de Stack: dbt (Data Build Tool) executando transformações SQL no Warehouse.
5. **Disponibilização:** Entregar o dado de alta qualidade para consumo downstream (BI, Machine Learning e ETL Reverso).
    - Exemplo de Stack: PowerBI (BI), Feature Store (ML) ou Hightouch (ETL Reverso)

---

## 2. Arquitetura de Pipelines de Dados

No ecossistema moderno de dados, a eficiência na entrega de informações limpas e prontas para uso analítico reside na qualidade do design das suas tubulações de dados.

### Anatomia e Definição de um Pipeline de Dados

Para o mercado corporativo, um pipeline de dados é a combinação de arquitetura, sistemas e processos que movem os dados pelas etapas do ciclo de vida da engenharia de dados.

Embora o ciclo completo envolva a geração na origem, é na etapa de ingestão que o engenheiro de dados começa a projetar ativamente as regras de fluxo e controle do pipeline. Na arquitetura moderna, esses pipelines devem ser flexíveis o suficiente para conectar desde uma única fonte transacional local até centenas de APIs e plataformas SaaS distribuídas globalmente.

### ETL (Extract, Transform, Load)

O ETL foi desenhado entre os anos 1980 e 2000, uma era em que o poder de processamento e, principalmente, a capacidade de armazenamento de dados analíticos eram extremamente caros e severamente limitados. Os sisteams de destino (data Warehouses) não tinham CPU ou espaço em disco redundantes para processar transformações complexas. Portanto, era obrigatório processar, limpar e reduzir o tamanho do dado em um servidor externo antes de enviá-lo ao Warehouse, garantindo que apenas dados agregados e otimizados fossem salvos no destino final.

O ETL é o padrão legado de movimentação de dados. O fluxo de controle de um pipeline de ETL opera de forma sequencial e síncrona:

1. **Extract:** Recuperação de snapshots ou logs incrementais diretamente dos bancos de dados de produção (Sistemas OLTP).
2. **Transform:** Os dados brutos extraídos passam por uma máquina de processamento intermediária (um servidor de ETL dedicado ou motor como Apache Spark/Map Reduce). É nessa camada intermediária que ocorrem as etapas de limpeza de tipos, joins estruturais, filtragem de registros nulos e normalização.
3. **Load (Carga):** O dado, agora já limpo, transformado e modelado conforme as regras do negócio, é carregado na estrutura de destino (como o Data Warehouse ou um Data Mart sob modelagem de Kimball).

### ELT (Extract, Load, Transform)

Com a ascenção da computação em nuvem e a drástica redução dos custos de armazenamento e processamento elástico, o mercado migrou massivamente para o ETL:

1. **Extract:** O engenheiro extrai os dados diretamente do sistema de origem sem apicar transformações de negócio prévias.
2. **Load:** Os dados são despejados exatamente em seu formato bruto em uma área de preparação dedicada (Staging Area), localizada dentro do próprio Data Warehouse analítico (como SnowFlake, BigQuery ou Redshift) ou em sistemas de Object Storage (como Amazon S3).
3. **Transform:** As transformações de negócio, agregações e modelagens analíticas (esquemas estrela/Kimball, tabelas de fatos e dimensões) ocorrem diretamente dentro do Data Warehouse de destino, utilizando ferramentas declarativas baseadas em SQL.

Isso ocorreu porquê Bancos de Dados analíticos em nuvem (Snowflake e BigQuery) popularizaram a dissociação de processamento e disco. O armazenamento em S3 ou Google Cloud Storage é virtualmente infinito e baratíssimo. É possível ligar ou desligar nós de computação massiva sob demanda para rodar consultas pesadas apenas quando necessário.

Ao contrário do ETL legado, onde os atributos descartados no estágio de transformação eram perdidos para sempre, o ELT armazena o dado bruto original. Se uma regra de negócios for alterada no futuro, ou se o time descobrir dados ausentes, basta reprocessar todo o pipeline a partir dos dados brutos preservados no Staging, sem necessidade de re-extrair dados do sistema de origem original.


## 3. Arquitetura de Armazenamento e Processamento

Para projetar sistemas analíticos modernos e resilientes, o engenheiro de dados deve dominar a fundo a evolução das asbtrações de armazenamento e as dinâmicas de processamento.

### Paradigmas de Processamento de Dados: Batch vs. Streaming

No dia a dia do desenvolvimento de pipelines, a escolha entre processar dados em lotes ou de forma contínua dita não apenas as ferramentas utilizadas, mas a latência da informação entregue ao negócio.

| Tipo | Processamento |
| :---: | :---: |
| Batch | Dados Ilimitados - Fronteira de Tempo -> Lote Banhado -> Transformações OLAP |
| Streaming | Dados Ilimitados - Event-by-Event -> Motor em Tempo Real -> Baixa Latência |

#### Processamento em Lote (Batch Processing)

Embora os dados no mundo real sejam gerados de forma contínua e ilimitada, o processamento em lote consiste em isolar artificialmente esses fluxos em blocos delimitados por tempo ou tamanho (dados limitados). As tarefas de lote são agendadas para rodar em intervalos fixos (diários, horários ou a cada 15 minutos).

Ao extrair snapshots ou arquivos em lote (como CSVs ou dumps de bancos transacionais), o engenheiro de dados deve aplicar **mascaramento de dados e  hashing unidirecional (SHA-256)** diretamente no momento da ingestão ou na primeira camada de preparação (Staging Area). Dados confidenciais de PII (_Personally Identifiable Information_, como e-mails e CPFs) nunca devem transitar sem criptografia ou anonimização para as camadas analíticas de downstream.

O mercado corporativo adota o lote como padrão na esmagadora maioria dos casos por três motivos principais:

- Baixo custo computacional;
- Simplicidade de manutenção;
- Alinhamento com as tomadas de decisão empresariais;

Motores OLAP executam varreduras maciças e otimizadas sobre esses blocos estáticos de dados com alta eficiência de custos.

Ao extrair snapshots ou arquivos em lote (como CSVs ou dumps de bancos transacionais), o engenheiro de dados deve aplicar mascaramento de dados e hashing unidirecional (SHA-256) diretamente no momento da ingestão ou na primeira camada de preparação (Staging Area). Dados confidenciais de PII (Personally Identifiable information, como e-mails e CPFs) nunca devem transitar sem criptografia ou anonimização para as camadas analíticas de downstream.

#### Processamento em Fluxo (Streaming Processing)

O processamento em fluxo (streaming) lida com o dado em seu estado natural: ilimitado, contínuo e orientado a eventos. Plataformas como Apache Kafka e Amazon Kinesis são utilizadas para manter e persistir temporariamente esse fluxo.

Ao processar streams, o engenheiro de dados precisa lidar com as sutilezas do tempo: 

- **Tempo do Evento:** Quando ocorreu na origem;
- **Tempo de Ingestão:** Quando entrou no pipeline;
- **Tempo de Processamento:** Quando foi transformado;

Para realizar agregações estatísticas, como médias móveis, utilizam-se janelas temporais para tornar o dado ilimitado temporariamente limitado:

1. **Janelas Fixas/Tumbling:** Divisões em tempo fixas e não sobrepostas (ex: blocos de 20 segundos);
2. **Janelas Deslizantes/Sliding:** Janelas com tempo de duração fixo que se sibrepõem ao avançar em intervalos menores (ex: a cada 30 segundos processa o último minuto), ideais para médias móveis;
3. **Janelas de Sessão:** Agrupamentos baseados na atividade do usuário, encerrando-se após um limite de inatividade;

O mercado utiliza processamento contínuo estritamente para casos de **extrema sensibilidade à latência**, como detecção de fraudes financeiras em tempo real ou monitoramento crítico de IoT. O custo e a complexidade técnica para depurar, lidar com dados atrasados usando marcas d'água (watermarks) e evitar perda de mensagens são significativamente maiores do que no modelo em lote.

Para dados de streaming, o mascaramento de PII deve ser feito "in-flight" (em trânsito). Funções sem servidor, como AWS Lambda ou Google Cloud Functions, ou processadores de fluxo, como Apache Spark Streaming, devem interceptar o evento e hashear as chaves de identificação pessoal antes que o registro seja gravado em disco no storage analítico.


### Abstrações de Armazenamento: Data Warehouse, Lake e LakeHouse

O desenho da infraestrutura de dados analíticos evoluiu para suportar diferentes volumes, variedades e velocidades de dados.

#### Data Warehouse
    - Suporta apenas dados estruturados;
    - Utiliza o Schema-on-Write, rígido na gravação;
    - As transações ACID são complexas e nativas;
    - Possui um alto custo de armazenamento, historicamente acoplado à computação;

O **Data Warehouse (DWH)** é um hub de dados central analítico que se baseia na clássica definição de Bill Inmon: um repositório integrado, não volátil, variante com o tempo e orientado a assuntos.

É projetado especificamente para separar o processamento transacional (OLTP) de produção do processamento analíico (OLAP). O mercado utiliza o Data Warehouse porque ele oferece consultas SQL de altíssimo desempenho e baixa latência para analistas de negócios, impulsionado por bancos colunares MPP (Massively Parallel Processing) como Snowflake, BigQuery e Amazon Redshift. A organização típica desses dados baseia-se na modelagem dimensional de Ralph Kimball (esquema estrela com tabelas de fatos e dimensões) e na disponibilização de dados especializados via Data Marts.

Por gerenciar metadados e esquemas internamente, o DWH facilita o controle de acesso granular de dados por meio de linguagens de controle (DCL) como `GRANT` e `REVOKE` no nível de colunas e linhas. No entanto, a carga de dados deve passar por transformações (ex: via dbt) que limpam, padronizam e aplicam criptografia de dados sensíveis antes que fiquem visíveis para os usuários finais.

#### Data Lake

    - Suporta todos os tipos de dados: Estruturados, semi e não estruturados;
    - Usa do Schema-on-Read, com flexibilidade na leitura;
    - As transações ACID são praticamente inexistentes, com uma difícil implementação manual;
    - Tem um custo de armazenamento muito baixo, pelo Object Storage desacoplado;

Com a explosão do volume de dados gerados pela internet e dispositivos conectados, o Data Warehouse tradicional tornou-se caro e rígido demais para armazenar logs compelxos e mídias. Surgiu o **Data Lake**, que atua como um imenso repositório para despejar qualquer tipo de dado, seja estruturado, semiestruturado como JSON ou Parquet, e não estruturado como áudio ou imagens, em seu formato original bruto.

Historicamente construiídos sobre o ecossistema hadoop (HDFS) e migrados massivamente para o armazenamento de objetos em nuvem (Amazon S3, Google Cloud Storage), os Data Lakes são amplamente utilizados devido ao baixíssimo custo de armazenamento e ao total desacoplamento entre computação e armazenamento. O engenheiro de dados pode carregar o dado imediatamente sem gastar tempo desenhando esquemas complexos (abordagem _schema-on-read_).

Sem governança de metadados, catálogos e qualidade de dados, o Data Lake inevitavelmente se transforma em um **Data Swamp**. Além disso, o conceito original era estritamente baseado no padrão _write-onde_, _read-many_ (WORM). Isso gerou uma crise grave de segurança com a chegada das leis de privacidade. Se um cliente acionar o "direito de ser esquecido" e solicitar a exclusão de seus dados pessoais, o engenheiro de dados em um Data Lake Clássico precisava reconstruir arquivos Parquet inteiros manualmente em lote, pois não havia suporte nativo a comandos SQL simples de atualização ou exclusão analítica (`UPDATE`ou  `DELETE`).

#### Data Lakehouse

    - Suporta todos os tipos de dados: Estruturados, semi e não estruturados;
    - Schema-on-Write para tabelas estruturadas e Schema-on-Read para arquivos brutos;
    - Transações ACID completas e nativas via metadados abertos;
    - Custo de armazenamento muito baixo, pelo Object Storage com computação elástica;

Para resolver as limitações de conformidade do Data Lake e a rigidez/alto custo do Data Warehouse, o mercado desenvolveu a arquitetura de **Data Lakehouse**. O Lakehouse armazena os dados no barato armazenamento de objetos (como o S3), mas introduz uma camada de gerenciamento de arquivos e metadados abertos (Delta Lake, Apache Iceberg ou Apache Hudi) diretamente sobre os arquivos, como Parquet.

| Data Lakehouse |
| :---: |
| **Camada de Consulta** (SQL, BI, Machine Learning, Python) |
| **Camada de Metadados / Transações ACID** (Delta, Iceberg) |
| **Armazenamento de Objetos Imutável** (Amazon S3, GCS) |
| |

O Lakehouse suporta transações ACID (Atomicidade, consistência, isolamento e durabilidade), garantindo a consistência das leituras simultâneas e integridade dos esquemas analíticos. O mercado adota essa arquitetura porque ela permite centralizar a infraestrutura: cientistas de dados e engenheiros de ML acessam arquivos não estruturados brutos de imagem e áudio, enquanto analistas de BI e relatórios consultam tabelas estruturadas e otimizadas diretamente no mesmo local, eliminando redundâncias e custos desnecessários de movimentação de dados (ETL).

No cotidiano do engenheiro de dados, trabalhar com formatos de tabelas como Delta Lake, Hudi ou Iceberg permite a utilização de comandos DML complexos, como `MERGE` e `UPSERT`. Em conformidade com a LGPD, o esquecimento de dados pessoais torna-se simples: executa-se uma instrução de deleção direcionada que altera apenas os metadados e os pointers da tabela, preservando a imutabilidade física do storage subjacente e gerando versões históricas de rollback de forma automatizada.
