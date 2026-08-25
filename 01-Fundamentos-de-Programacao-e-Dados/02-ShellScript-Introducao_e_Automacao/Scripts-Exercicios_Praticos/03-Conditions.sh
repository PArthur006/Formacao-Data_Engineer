#!/usr/bin/env bash

# Descrição: Demonstra o uso de condições em Shell Script

set -euo pipefail

ARQ="${1:-/etc/hosts}"

if [[ -f "${ARQ}" ]]; then
    echo "O arquivo ${ARQ} existe."
else
    echo "O arquivo ${ARQ} não existe."
fi

read -r -p "Digite um número: " NUM

if [[ "${NUM}" -gt 10 ]]; then
    echo "O número ${NUM} é maior que 10."
elif [[ "${NUM}" -eq 10 ]]; then
    echo "O número ${NUM} é igual a 10."
else
    echo "O número ${NUM} é menor que 10."
fi

