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

