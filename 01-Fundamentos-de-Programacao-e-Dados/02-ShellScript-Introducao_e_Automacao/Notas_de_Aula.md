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
