# Shell Script: Introdução e Como Automatizar Tarefas

**Sumário:**

---

Este curso de **Shell Script** é uma introdução prática para quem quer dar os primeiros passos na automação de tarefas no terminal. O foco não é teoria pesada, mas sim exemplos reais de uso, mostrando como o shell pode facilitar o dia a dia de quem trabalha com sistemas, programação ou dados.

## 1. O Que é Shell Script e os Tipos de Shell?

O **Shell** é o programa de interface de linha de comando (CLI) que faz a ponte direta entre o usuário e o kernel do sistema operacional. Um **Shell Script** é um arquivo de texto executável que consolida uma sequência ordenada de comandos do sistema operacional para automatizar rotinas, gerenciar infraestrutura e disparar pipelines sem intervenção manual.

Atua como a cola de infraestrutura mais próxima ao sistema operacional, essencial para inicialização de containers, rotinas de backup, disparo de jobs de extração/carga e configuração de variáveis de ambiente antes da execução de pipelines complexos.

### Tipos de Shell

SHELL | ORIGEM / PADRÃO | CARACTERÍSTICAS
--- | --- | ---
`sh` - Bourne Shell | Unix clássico original | Menor denominador comum de portabilidade; compatível com quase todos os sistemas Unix-like.
`bash` - Bourne Again Shell | Distribuições Linux (Ubuntu, Debian, RHEL) | Padrão dominante da indústria para scripts de infraestrutura, automação e pipelines de dados.
`zsh` - Z Shell | Padrão nativo do macOS moderno | Alta compatibilidade com o Bash, focado em usabilidade, autocomplete e recursos interativos avançados.
`PowerShell` | Nativo do ecossistema Windows | Baseados em **objetos**, e não em fluxos de texto puro como os shells Unix; sintaxe e modelo operacional distintos.

### Operação e Identificação

- **Execução Sequencial:** O interpretador lê o arquivo de script de cima para baixo, executando cada instrução como se estivesse sendo digitada diretamente no console.
- **Comando de Identificação do Shell Ativo:**

```bash
echo $0
```

Retorna o nome do interpretador que gerencia a sessão corrente (ex: `-bash`, `/bin/zsh`).

---

### Shebang e a Portabilidade do Interpretador

O **Shebang (`#!`)** é a diretiva posicionada obrigatoriamente na primeira linha de um script que instrui o kernel do sistema operacional sobre qual interpretador binário deve ser carregado para executar o código contido no arquivo.

#### Mecânica de Funcionamento:

1. **Leitura do Cabeçalho:** Ao disparar a execução de um arquivo (ex: `./script.sh`), o kernel intercepta os primeiros bytes `#!`.
2. **Identificação do Binário:** O kernel extrai o caminho absoluto declarado logo após o prefixo.
3. **Invocação:** O interpretador especificado é iniciado, recebendo o restante do arquivo de texto como argumento de entrada.

#### Comparativo de Portabilidade

DECLARAÇÃO | MECANISMO | RISCO / LIMITAÇÃO | RECOMENDAÇÃO
--- | --- | --- | ---
`#!/bin/bash` | Aponta para um caminho estático e absoluto no sistema de arquivos. | Quebra de portabilidade: Falha se o binário estiver em diretórios alternativos (ex: `/usr/local/bin/bash` em FreeBSD, Solaris ou macOS via Homebrew). | Evitar em scripts distribuídos/cross-platform.
`#!/usr/bin/env bash` | Utiliza o utilitário `env` para buscar a localização do interpretador dinamicamente via `$PATH`. | Nulo ou desprezível na maioria dos sistemas Unix-like modernos. | Garante portabilidade entre diferentes ambientes, contêineres e distribuições de nuvem.

**Regra de Infraestrutura:** O uso de caminhos dinâmicos via `env` desacopla o script do layout físico rígido do sistema de arquivos hospedeiro, prevenindo quebras em pipelines que transitam entre ambientes locais, contêineres Docker e instâncias cloud.

---

### Permissões de Execução no Unix

No modelo de segurança Unix, arquivos de texto nascem **sem permissão de execução** por padrão. A transformação de um arquivo `.sh` em um executável invocável via `./` exige a atribuição explícita do bit de execução (`x`) através do comando `chmod`.

#### Estrutura de Permissões

> `ls -l`

A máscara de 10 caracteres retornada pelo comando divide-se em tipo de entrada e 3 grupos hierárquivos de privilégios:

[Tipo] | [Proprietário (u)] | [Grupo (g)] | [Outros (o)]
--- | --- | --- | ---
`-` | rwx | r-x | r-x

- **Tipo:** 
    - `-` -> Arquivo comum;
    - `d` -> Diretório
- **Níveis de Acesso:**
    - `r` (Read): Permite ler o conteúdo do arquivo.
    - `w` (Write): Permite alterar, sobrescrever ou deletar o arquivo.
    - `x` (Execute): Permite ao SO carregar e executar o arquivo como um processo/binário.

#### Change Mode (`chmod`)

- `chmod +x arquivo.sh`
    - Concede execução a **todos** (proprietário, grupo e outros).
    - Nível baixo de segurança.
    - Uso para testes locais rápidos em máquinas isoladas.
- `chmod 755 arquivo.sh
    - Proprietário (`rwx`), Grupo (`r-x`), Outros (`r-x`).
    - Nível médio de segurança.
    - Uso padrão comum para binários públicos do sistema.
- `chmod u+x arquivo.sh`
    - Concede execução **estritamente ao proprietário**.
    - Nível de segurança alto (Privilégio Mínimo).
    - Caso padrão de produção corporativo em servidores e contêineres compartilhados.

### Prática: Script de Data e Hora

Abaixo é apresentada a implementação de um script prático que consolida os conceitos de shebang, saída estruturada de dados e captura dinâmica de metadados do sistema operacional através de variáveis.

```bash
#!/usr/bin/env bash

# /Scripts-Exercicios_Praticos/01-HelloDate.sh

# Descrição: Demontração prática de Shebang, Execução e Captura de Data

# 1. Captura a data atual no formato dd/mm/aaaa hh:mm:ss
DATA_ATUAL=$(date "+%d/%m/%Y %H:%M:%S")

# 2. Exibição do resultado no terminal
echo "Iniciando execução do pipeline de dados..."
echo "Data e Hora da execução: ${DATA_ATUAL}"
```

O comando `date` foi avaliado dinamicamente e injetado diretamente na variável `${DATA_ATUAL}`, provendo a rastreabilidade essencial para arquivos de log de execução de pipelines.

---

## 2. Variáveis de Ambiente e Ingestão de Arquivos

No Bash, o gerenciamento de variáveis sustenta a parametrização e o controle de fluxo de scripts. O interceptador impõe regras estritas de sintaxe de atribuição e oferece suporte a escopos globais, locais e variáveis especiais de estado/posicionamento.

### Regras de Sintaxe e Escopo

- **Sintaxe de Atribuição:** Proibido o uso de espaços ao redor do operador de igualdade (`VAR=valor`, e nunca `VAR = valor`).
    - Aspas duplas (`"..."`): Permitem interpolação de variáveis e preservação de espaços em strings.
    - Inteiros: Declarados diretamente sem aspas (ex: `COUNT=10`).
- **Escopo Global (Padrão):** Qualquer variável declarada fora de funções (ou dentro de funções sem modificadores) é visível em qualquer ponto subsequente do script.
- **Escopo Local (`local`):** Uso obrigatório da palavra-chave `local` dentro do corpo de funções (ex: `local temp_var="xyz"`).
    - Objetivo: Isolar o contexto da função e evitar mutações acidentais (_side-effects_) em variáveis globais de mesmo nome.

### Variáveis Especiais do Sistema

- [`$0`]
    - Nome ou caminho relativo do script em execução;
    - Útil em logs padronizados e mensagens de ajuda (_usage/help_);
- [`$1, $2, ... , $N`]
    - Argumentos posicionais passados via CLI;
    - Usado na captura de parâmetros dinâmicos (ex: `./job.sh 2026-08-25 sales`);
- [`$#`]
    - Quantidade total de argumentos fornecidos;
    - útil para realizar a validação inicial de pré-requisitos antes de rodar o script;
- [`$@`]
    - Array com todos os argumentos como palavras individuais;
    - Usado para Iteração segura em loops (`for arg in "$@"`);
- [`$?`]
    - Código de saída (_Exit Code_) do último comando;
    - Tratamento de exceções: `0` -> Sucesso; `1 a 255` = Falha/Erro;

### Segurança de Ingestão de Dados

O Hardcoding de segredos no código-fonte é uma vulnerabilidade crítica de segurança. A prática correta em Engenharia de Dados consiste em desacoplar credenciais da lógica de execução, utilizando arquivos de variáveis de ambiente restritos carregados em tempo de execução via **Sourcing**.

#### Riscos do Hardcoding em Ambientes de Produção

- **Vazamento Instantâneo:** Commits acidentais contendo credenciais em texto claro para plataformas de controle de versão (GitHub, GitLab) são identificados por bots e scanners automatizados em segundos.
- **Comprometimento da Infraestrutura:** Exposição direta a acessos não autorizados, exfiltração de dados confidenciais e custos abusivos em serviços de nuvem.

#### Mecanismo de Sourcing (`source` ou `.`)

A técnica de _sourcing_ executa comandos de um arquivo diretamente na sessão corrente do shell, sem gerar um subprocesso isolado.

- **Execução Direta:**
    - `./config.sh`;
    - Abre um novo subprocesso (_subshell_);
    - Sem persistência de variáveis. As variáveis são destruídas ao término do script filho.
- **Sourcing:**
    - `source config.env` ou `. config.env`;
    - Roda no contexto do shell pai atual;
    - Possui persistência de variáveis. As variáveis permanecem carregadas na memória do shell ativo.

---

## 3. Condicionais e Idempotência em Pipelines de Ingestão

Em pipelines de dados, o controle de estado e a validação de metadados em nível de sistema de arquivos asseguram a integridade dos dados brutos antes do acionamento de processamentos custosos. O uso de estruturas de teste modernas (`[[ ... ]]`) e operadores de checagem física garante resiliência, prevenção de quebras por entradas mal formatadas e conformidade de segurança.

### Chaves Simples vs. Chaves Duplas

CARACTERÍSTICA | CHAVES SIMPLES (`[ ... ] / test`) | CHAVES DUPLAS (`[[ ... ]]`)
--- | --- | ---
Natureza Técnica | Programa/binário externo clássico (POSIX) | Palavra-chave nativa (_built-in_) do Bash 
Tratamento de Espaços | Vúlnerável a quebras por word splitting sem aspas | Seguro: Trata string com espaços e nulas de forma atômica
Expansão de Curingas | Suscetível a falhas por expansão acidental (_gloobbing_) | Protegido nativamente contra expansão indevida
Expressões Regulares | Requer comandos e pipes externos (ex: `grep`) | Suporte nativo a regex e pattern machine (`=~, *`)
Uso Recomendado | Scripts legados com foco estrito em portabilidade POSIX | Padrão de produção moderno em Bash para pipelines
|||

### Operadores de Validação de Metadados de Arquivos

O uso de operadores dentro de `[[ ... ]]` permite inspecionar o estado físico do storage antes de disparar rotinas downstream:

- **Existência e Tipo Estrutural:**
    - `-f <caminho>`: Retorna verdadeiro se o alvo for um arquivo regular existente
        - Ex: Valida se o `.csv`, `.parquet` ou `.json` foi despejado.
    - `-d <caminho>`: Retorna verdadeiro se o alvo for um diretório existente
        - Ex: Valida se as pastas `/landing`, `/staging` ou de logs estão montadas.
- **Validação de Conteúdo Útil:**
    - `-s <caminho>`: Retorna verdadeiro se o arquivo existir e possuir tamanho superior a 0 bytes.
        - Aplicação: Aborta a execução para arquivos vazios, evitando custos computacionais ociosos em clusters analíticos e no Data Warehouse.
- **Segurança e Privilégios:**
    - `-r` (Read): Valida se o processo possui permissão de leitura
    - `-w` (Write): Valida permissão de escrita em diretórios temporários de staging antes de gerar arquivos anonimizados/mascarados com PII.
    - `-x` (Execute): Valida permissões de execução para scripts ou binários auxiliares.


### Códigos de Saída (Exit Codes) como Base de Observabilidade

#### Mecânica de Retorno e Tratamento de Erros
* **Intervalo Numérico:** Todo comando finalizado no Unix retorna um código numérico de 8 bits (entre `0` e `255`). O valor `0` indica sucesso absoluto; qualquer valor diferente de zero (`1` a `255`) indica erro, falta de recursos ou terminação anormal.
* **A Variável `$?`:** Armazena o código de saída do último comando executado. Pipelines defensivos devem inspecionar `$?` após operações críticas (como dumps de banco ou mascaramento SHA-256) e forçar uma saída com falha (`exit 1`) caso ocorra erro.

#### Integração com Orquestradores (Airflow) e CI/CD
* **Orquestradores de Tarefas:** Plataformas como Apache Airflow determinam o sucesso ou a falha de uma etapa avaliando o código de saída do processo. Omitir saídas explícitas pode mascarar falhas graves, caso a última linha executada seja um comando simples de log (`echo`) bem-sucedido.
* **Esteiras de CI/CD (dbt):** Testes automatizados de qualidade de dados (*data quality tests*) que falham retornam códigos diferentes de zero, bloqueando a mesclagem indevida de código quebrado para a branch principal de produção.
* **Governança e LGPD:** Se o mascaramento de PII falhar durante a ingestão, o script deve capturar o código de erro e abortar imediatamente, evitando a gravação de dados confidenciais em texto claro na camada Bronze.

### O Princípio da Idempotência em Pipelines

#### Definição e Resiliência a Falhas
* **Conceito:** Um pipeline é idempotente quando sua execução repetida sob as mesmas entradas produz exatamente o mesmo resultado final, sem duplicar dados ou causar efeitos colaterais.
* **Sobrevivência a Falhas:** Permite que retentativas automáticas (*retries*) ou execuções manuais após quedas de rede, estouros de memória (OOM) ou *timeouts* ocorram sem exigir intervenção humana para limpeza de banco.

#### Estratégias no Sistema de Arquivos
* **Limpeza Prévia de Staging:** O script deve verificar a existência de diretórios temporários e limpar resíduos de execuções incompletas anteriores antes de gravar novos lotes.
* **Processamento Atômico e Isolamento:** Uso de arquivos com marcadores dinâmicos de data/hora para impedir a escrita concorrente sobre arquivos de produção em uso.
* **Sobrescrita vs. Anexação:** Priorização da substituição atômica de arquivos (redirecionamento com `>`) em vez da anexação contínua (`>>`), prevenindo a duplicação descontrolada de registros em casos de reexecução.

---

## 4. Loops, Processamento em Lote e Manipulação de Arquivos

As estruturas de repetição sustentam a automação de pipelines em lote, permitindo iterar sobre coleções de dados, sequências numéricas e arquivos sem duplicação de código. No Bash, destacam-se as variações do loop `for` e o processamento sequencial baseado em condições com `while`.

### Variações e Sintaxe do Loop For

#### Loop For-In (Estilo Iterativo)
* **Mecânica:** Itera sequencialmente sobre uma lista explícita de elementos, strings ou arrays.
* **Funcionamento:** A cada iteração, o interpretador extrai um elemento da coleção, atribui à variável de controle e executa o bloco delimitado por `do` e `done`.
* **Aplicação:** Processamento de listas delimitadas (ex.: listas de tabelas, partições de datas ou nomes de arquivos de entrada).

```bash
for item in "fuji" "gala" "red_delicious"; do
    echo "Processando variedade: ${item}"
done
```

#### Loop For no Estilo C (Aritmético)
* **Mecânica:** Utiliza controle aritmético explícito com três expressões encapsuladas em parênteses duplos `(( inicialização; condição; incremento ))`.
* **Vantagem Técnica:** Elimina a necessidade de expansão de strings para sequências numéricas, proporcionando melhor desempenho em iterações puramente matemáticas ou controle de índices de matrizes.
* **Aplicação:** Execuções baseadas em contadores numéricos rígidos, limites de lotes (*batches*) e manipulação de índices de arrays.

```bash
limite=10
for ((i=0; i<limite; i++)); do
    echo "Índice de processamento: ${i}"
done
```

### O Loop While e Processamento Baseado em Condições

#### Leitura Sequencial com `while read`
* **Mecânica:** Mantém a execução ativa enquanto a condição avaliada for verdadeira.
* **Eficiência de Memória:** A combinação `while read` consome fluxos de texto linha por linha (usando `\n` como delimitador natural), evitando carregar arquivos massivos inteiramente na memória RAM do servidor.
* **Parâmetro Crítico (`read -r`):** O uso da flag `-r` é obrigatório para desativar a interpretação de barras invertidas (*backslashes*) como caracteres de escape, preservando a integridade literal dos dados originais.

```bash
while IFS= read -r linha; do
    echo "Processando: $linha"
done < "arquivo.txt"
```

#### Segurança e Anonimização em Tempo de Execução (LGPD)
* **Interpretação *In-Flight*:** A leitura linha a linha permite interceptar registros durante o trânsito antes da gravação em disco.
* **Tratamento de PII:** Viabiliza o isolamento de colunas sensíveis (como e-mails e CPFs) para aplicação imediata de hashing unidirecional (SHA-256) ou mascaramento, persistindo apenas os dados anonimizados na área de *Staging*.

### Processamento em Lote (Batch) e Globbing

O processamento eficiente e seguro de grandes volumes de dados no terminal Unix exige o domínio de mecanismos nativos de expansão (*globbing*), ferramentas de edição de fluxo de baixo consumo de memória (AWK e SED) e utilitários escaláveis de busca e paralelização (*find* e *xargs*).

#### Mecânica do Globbing
* **Expansão Nativa:** O *globbing* expande caracteres curinga (como `*` e `?`) em listas de caminhos correspondentes diretamente no shell antes de invocar o comando ou loop.
    - Ex: `/workspace/landing/*.csv`
    - Ex: `for arquivo in /data/*.parquet; do ... done`
* **Eficiência Computacional:** Ao contrário de abordagens que delegam a avaliação de padrões para bibliotecas externas em tempo de execução, a expansão prévia pelo próprio interpretador reduz chamadas redundantes ao sistema operacional e otimiza o uso de memória do kernel.
* **Uso de `nullglob`:** A ativação de `shopt -s nullglob` evita falhas quando nenhum arquivo corresponde ao padrão, impedindo que a string literal com asterisco seja repassada indevidamente para dentro do loop.

#### Automação Segura e Idempotência (LGPD)
* **Validação Prévia de Metadados:** Verificação via `[[ -s "$arquivo" ]]` para ignorar arquivos vazios (0 bytes), economizando processamento computacional.
* **Garantia de Idempotência:** Uso de redirecionamento simples (`>`) na geração dos arquivos processados para sobrescrever e recriar o estado do *staging* de forma limpa a cada reexecução.
* **Auditoria e Isolamento:** Movimentação imediata dos arquivos brutos processados para pastas de arquivo/histórico, prevenindo reprocessamentos duplicados acidentais e isolando dados sensíveis.

### Manipulação de Arquivos e Textos de Alta Performance: AWK e SED

#### AWK: Processamento Tabular Dinâmico em Streaming
* **Arquitetura em Linha:** Linguagem interpretada orientada a padrões que processa arquivos linha por linha, permitindo filtrar e agregar arquivos gigantescos (CSVs e logs) sem carregar o conjunto completo na memória RAM.
* **Mapeamento Posicional de Campos:**
  * `$0`: Linha inteira em processamento.
  * `$1, $2, ..., $N`: Variáveis posicionais que mapeiam as colunas do registro.
* **Definição de Delimitadores (`-F`):** O parâmetro `-F` define o separador específico de colunas (ex.: `-F','` para CSVs ou `-F':'` para `/etc/passwd`).
* **Estrutura de Ação:** Opera sob o modelo `condição { ação }`, permitindo filtrar registros ruidosos de logs e extrair chaves estruturadas diretamente para a camada de *staging*.

```bash
# Exemplo: Extrair a coluna de usuário ($1) e shell ($7) de arquivos delimited por ":"
awk -F':' '{print $1 " usa o shell: " $7}' /etc/passwd
```

#### SED: Edição Não Interativa de Fluxo
* **Função Principal:** Executa transformações, exclusões e substituições rápidas de padrões de caracteres em streams de texto ou arquivos brutos.
* **Casos de Uso em Dados:** Correção de codificações incorretas, remoção de quebras de linha no padrão Windows (`\r\n`) e padronização de campos numéricos/monetários antes da carga no banco de dados.
* **Sintaxe de Substituição Global:** O padrão `sed 's/padrão/novo_valor/g'` aplica a troca em todas as ocorrências encontradas na linha (modificador `g`).

```bash
# Remove o caractere de cifrão e normaliza os delimitadores de casa decimal
cat dados_brutos.txt | sed 's/\$ //g' | sed 's/\.//g' | sed 's/,/./g'
```

### Varredura Estruturada e Paralelização: Find e Xargs

#### Busca Avançada com `find`
* **Varredura Recursiva por Metadados:** Localiza arquivos com base em atributos estruturais do sistema de arquivos sem depender de listas carregadas em memória.
* **Filtros Estruturais Críticos:**
  * `-type f` / `-type d`: Restringe a busca exclusivamente a arquivos regulares ou diretórios.
  * `-mtime` / `-mmin`: Filtra por data de modificação em dias ou minutos (essencial para isolar arquivos das últimas 24h em cargas incrementais).
  * `-name`: Filtra por padrões de nome (sempre protegido por aspas para evitar que o shell execute o *globbing* prematuramente).

```bash
# Busca arquivos Parquet modificados estritamente nas últimas 24 horas no Data Lake local
find /workspace/datalake/bronze/ -type f -name "*.parquet" -mtime -1
```

#### Paralelização e Escala com `xargs`
* **Mitigação do Erro `Argument list too long`:** Converte fluxos de texto da entrada padrão (*stdin*) em lotes gerenciáveis de argumentos, permitindo processar milhões de arquivos sem estourar o limite de buffer do terminal.
* **Padrão Seguro para Espaços em Branco (`-print0` e `-0`):**
  * `find ... -print0`: Utiliza o byte nulo (`\0`) como delimitador entre os arquivos encontrados.
  * `xargs -0`: Interpreta o byte nulo como separador, neutralizando quebras de execução e riscos de segurança causados por nomes de arquivos contendo espaços em branco ou quebras de linha acidentais.

```bash
# Busca e move os arquivos Parquet de forma segura contra quebra de nomes com espaços
find /workspace/landing/ -type f -name "*.parquet" -print0 | xargs -0 -I {} mv {} /workspace/staging/
```
