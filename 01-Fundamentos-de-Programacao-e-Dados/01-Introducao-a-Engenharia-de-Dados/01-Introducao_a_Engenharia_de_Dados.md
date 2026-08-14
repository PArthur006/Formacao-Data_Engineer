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

