import hashlib

# Dados brutos de exemplo
email_bruto = "  Carlos.Souza@provedor.com  "
cpf_bruto = "123.456.789-01"

# 2. Normalização dos dados
"""
    strip() - Remove espaços em branco no início e no fim da string
    lower() - Converte todos os caracteres para minúsculas
"""
email_normalizado = email_bruto.strip().lower()

# Removendo caracteres não numéricos do CPF
cpf_normalizado = cpf_bruto.replace(".", "").replace("-", "").strip()

# 3. Geração de Hashing SHA-256 via hashlib
"""
    O hashlib exige que a string vire bytes para gerar o hash. Isso é feito com o método encode('utf-8').
"""
email_bytes = email_normalizado.encode('utf-8')
email_hash = hashlib.sha256(email_bytes).hexdigest()

cpf_bytes = cpf_normalizado.encode('utf-8')
cpf_hash = hashlib.sha256(cpf_bytes).hexdigest()

# 4. Saída segura dos resultados
print(f"Email normalizado e hasheado: {email_hash}")
print(f"CPF normalizado e hasheado: {cpf_hash}")
