#!/bin/bash

# Determina o diretório onde o script está localizado
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Carrega o arquivo de configuração do mesmo diretório onde o script está localizado
source "$SCRIPT_DIR/config.conf"

# Verifica se o arquivo de configuração foi carregado
if [ -z "$ONEDRIVE_DIR" ]; then
    echo "Erro: Não foi possível carregar o arquivo de configuração. Certifique-se de que o config.conf está no mesmo diretório que o script."
    exit 1
fi

# Criação da pasta temporária se não existir
echo "Verificando a existência da pasta temporária..."
if [ ! -d "$TEMP_DIR" ]; then
    echo "Criando a pasta temporária em $TEMP_DIR..."
    mkdir -p "$TEMP_DIR"
fi

# Criação da subpasta 'archive' se não existir
echo "Criando a subpasta 'archive' dentro de TEMP_DIR, se não existir..."
mkdir -p "$TEMP_DIR/archive"

# Encontra o último arquivo GPG na pasta do OneDrive
ENCRYPTED_FILE=$(ls -t "$ONEDRIVE_DIR"/*.tar.gz.gpg 2>/dev/null | head -n 1)

# Verifica se um arquivo foi encontrado
if [ -z "$ENCRYPTED_FILE" ]; then
    echo "Nenhum arquivo .tar.gz.gpg encontrado na pasta do OneDrive."
    exit 1
fi

# Caminho do arquivo de saída (o arquivo decriptado na subpasta 'archive')
OUTPUT_FILE="$TEMP_DIR/archive/$(basename "${ENCRYPTED_FILE%.gpg}")"

# Executa a decriptação
echo "Decriptando o arquivo $ENCRYPTED_FILE..."
gpg --batch --yes --passphrase "$PASSWORD" --output "$OUTPUT_FILE" --decrypt "$ENCRYPTED_FILE"

# Verifica se a decriptação foi bem-sucedida
if [ $? -eq 0 ]; then
    echo "Decriptação concluída com sucesso: $OUTPUT_FILE"
else
    echo "Falha na decriptação."
    exit 1
fi
