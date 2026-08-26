#!/usr/bin/env bash

# Descrição:

set -euo pipefail

saudacao() {
    local nome="${1:-Visitante}"
    echo "Bem vindo, ${nome}!"
}

somar () {
    local a="${1:-0}"
    local b="${2:-0}"
    echo "$((a + b))"
}

saudacao "$@"
echo "Soma de 5 e 10: $(somar 5 10)"