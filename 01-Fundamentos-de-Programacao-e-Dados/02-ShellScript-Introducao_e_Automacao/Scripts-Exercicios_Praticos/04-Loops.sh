#!/usr/bin/env bash

# Descrição:

set -euo pipefail

echo "Loop for em uma lista:"
for item in amarelo azul verde vermelho; do
    echo "Cor: $item"
done

echo ""

echo "Loop while lendo arquivo linha a linha:"
ARQ="$(dirname "${BASH_SOURCE[0]}")/03-Conditions.sh"
if [[ -f "${ARQ}" ]]; then
    while IFS= read -r linha; do
        [[ -z "${linha}" ]] && continue
        echo "Linha: ${linha}"
    done < "${ARQ}"
else
    echo "Arquivo não encontrado: ${ARQ}"
fi