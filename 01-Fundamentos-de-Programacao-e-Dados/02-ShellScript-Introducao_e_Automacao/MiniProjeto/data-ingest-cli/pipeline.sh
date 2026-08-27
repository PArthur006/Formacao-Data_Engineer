#!/bin/bash

# Configurações de diretórios
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LANDING_DIR="$BASE_DIR/data/landing"
RAW_DIR="$BASE_DIR/data/raw/$(date +%F)"
QUARANTINE_DIR="$BASE_DIR/data/quarantine"
LOG_FILE="$BASE_DIR/logs/pipeline.log"

# Garante a existência dos diretórios necessários
mkdir -p "$LANDING_DIR" "$RAW_DIR" "$QUARANTINE_DIR" "$BASE_DIR/logs"

log() {
    local nivel="$1"
    local msg="$2"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$nivel] $msg" | tee -a "$LOG_FILE"
}

validate_csv() {
    local arquivo="$1"

    # 1. Verifica se existe e não está vazio
    if [[ ! -s "$arquivo" ]]; then
        log "WARN" "Arquivo vazio ou inacessível: $(basename "$arquivo")"
        return 1
    fi

    # 2. Verifica se tem mais de 1 linha (pelo menos cabeçalho + 1 registro)
    local total_linhas
    total_linhas=$(wc -l < "$arquivo")
    if (( total_linhas <= 1 )); then
        log "WARN" "Arquivo contém apenas o cabeçalho (sem dados): $(basename "$arquivo")"
        return 1
    fi

    return 0
}

process_files() {
    log "INFO" "Iniciando esteira de ingestão..."

    # Itera sobre arquivos csv na landing zone
    shopt -s nullglob
    local arquivos=("$LANDING_DIR"/*.csv)
    shopt -u nullglob

    if (( ${#arquivos[@]} == 0 )); then
        log "INFO" "Nenhum arquivo CSV encontrado em $LANDING_DIR."
        return
    fi

    for arq in "${arquivos[@]}"; do
        local nome_arquivo
        nome_arquivo=$(basename "$arq")

        if validate_csv "$arq"; then
            local linhas
            linhas=$(wc -l < "$arq")
            mv "$arq" "$RAW_DIR/"
            log "INFO" "Sucesso: $nome_arquivo ingerido ($linhas linhas) -> $RAW_DIR"
        else
            mv "$arq" "$QUARANTINE_DIR/"
            log "ERROR" "Falha de validação: $nome_arquivo movido para $QUARANTINE_DIR"
        fi
    done

    log "INFO" "Esteira finalizada com sucesso."
}

# Execução do pipeline
process_files