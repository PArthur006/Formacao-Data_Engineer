#!/usr/bin/env bash

# Descrição: Demontração prática de Shebang, Execução e Captura de Data

# 1. Captura a data atual no formato dd/mm/aaaa hh:mm:ss
DATA_ATUAL=$(date "+%d/%m/%Y %H:%M:%S")

# 2. Exibição do resultado no terminal
echo "Iniciando execução do pipeline de dados..."
echo "Data e Hora da execução: ${DATA_ATUAL}"

