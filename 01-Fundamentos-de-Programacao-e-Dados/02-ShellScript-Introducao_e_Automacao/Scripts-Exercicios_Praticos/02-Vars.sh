#!/usr/bin/env bash

# Descrição: Demonstra variáveis, expansão e leitura do usuário

set -euo pipefail

NOME="${1:-Visitante}"
echo "Olá, $NOME! Vamos coletar algumas informações."

read -r -p "Qual a sua linguagem favorita? " LING
read -r -p "Qual cidade você nasceu? " CIDADE

HOJE="$(date +%d/%m/%Y)"

echo ""
echo "Resumo das informações coletadas:"
echo "Nome: $NOME"
echo "Linguagem favorita: $LING"
echo "Cidade de nascimento: $CIDADE"
echo "Data de hoje: $HOJE"