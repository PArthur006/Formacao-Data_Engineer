import hashlib
import json
from datetime import datetime, timezone

# Dados brutos de exemplo
email_cliente = "gustavo.guanabara@provedor.com"
cpf_cliente = "12345678901"
faturamento_pedido = 350.00

# Aplicação de Hashing SHA-256 in-memory 
email_hash = hashlib.sha256(email_cliente.encode('utf-8')).hexdigest()
cpf_hash = hashlib.sha256(cpf_cliente.encode('utf-8')).hexdigest()

# O log registra apenas a transação com os dados sensíveis mascarados
log_seguro = {
    "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S"),
    "level": "INFO",
    "action": "pedido_processado",
    "email_hash": email_hash,
    "cpf_hash": cpf_hash,
    "valor_pedido": faturamento_pedido
}

# Impressão segura do log em formato JSON
print(json.dumps(log_seguro))