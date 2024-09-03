#!/bin/bash

# Determina o diretório onde o script está localizado
SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

# Carrega o arquivo de configuração do mesmo diretório onde o script está localizado
source "$SCRIPT_DIR/config.conf"

# Verifica se o arquivo de configuração foi carregado
if [ -z "$PROJECTS_DIR" ]; then
    echo "Erro: Não foi possível carregar o arquivo de configuração. Certifique-se de que o config.conf está no mesmo diretório que o script."
    exit 1
fi

# Defina o arquivo de log com base no SCRIPT_DIR
LOG_FILE="$SCRIPT_DIR/logs/sync_log_$(date +'%Y%m%d_%H%M%S').log"

# Início do log
echo "Início da execução: $(date)" > "$LOG_FILE"
echo "Sincronização de projetos iniciada..." >> "$LOG_FILE"

# Criação da pasta temporária se não existir
echo "Criando pasta temporária, se não existir..." >> "$LOG_FILE"
mkdir -p "$TEMP_DIR"

# Criação das subpastas temporárias se não existirem
echo "Criando subpastas temporárias 'projects' e 'archive', se não existirem..." >> "$LOG_FILE"
mkdir -p "$TEMP_DIR/projects"
mkdir -p "$TEMP_DIR/archive"

# Criação da pasta temporária dos projetos se não existir
echo "Criando pasta temporária dos projetos, se não existir..." >> "$LOG_FILE"
mkdir -p "$TEMP_DIR/projects/Dev"

# Criação da pasta temporária do XAMPP se não existir
echo "Criando pasta temporária do XAMPP, se não existir..." >> "$LOG_FILE"
mkdir -p "$TEMP_DIR/projects/xampp"

# Verificação de status do Git em todos os subdiretórios
echo "Verificando status dos repositórios Git em $PROJECTS_DIR..." >> "$LOG_FILE"
cd "$PROJECTS_DIR"
for dir in $(find . -type d -name ".git"); do
    repo_dir=$(dirname "$dir")
    cd "$repo_dir"
    
    # Verifica se há uma operação em andamento (rebase, merge, etc.)
    if [ -d "$repo_dir/.git/rebase-apply" ] || [ -d "$repo_dir/.git/rebase-merge" ] || [ -d "$repo_dir/.git/MERGE_HEAD" ]; then
        echo "Operação em andamento detectada no repositório $repo_dir. Snapshot não será criado." >> "$LOG_FILE"
        echo "Fim da execução: $(date)" >> "$LOG_FILE"
        exit 1
    fi
    
    cd "$PROJECTS_DIR"
done

# Sincroniza o diretório de projetos para a subpasta temporária 'projects/Dev'
echo "Sincronizando o diretório de projetos Dev para a subpasta temporária 'projects'..." >> "$LOG_FILE"
rsync -a --delete "$PROJECTS_DIR/" "$TEMP_DIR/projects/Dev/"

# Sincroniza o diretório do XAMPP para a subpasta temporária 'projects/xampp'
echo "Sincronizando o diretório do XAMPP para a subpasta temporária 'projects'..." >> "$LOG_FILE"
rsync -a --delete "/mnt/c/xampp/" "$TEMP_DIR/projects/xampp/"

# Cria um novo snapshot com a data e hora atuais e armazena na subpasta 'archive'
SNAPSHOT_NAME="snapshot_$(date +'%Y%m%d_%H%M%S').tar.gz"
echo "Criando um novo snapshot: $SNAPSHOT_NAME..." >> "$LOG_FILE"
tar -czf "$TEMP_DIR/archive/$SNAPSHOT_NAME" -C "$TEMP_DIR/projects" .

# Criptografa o snapshot e armazena na subpasta 'archive'
echo "Criptografando o snapshot..." >> "$LOG_FILE"
gpg --batch --yes --passphrase "$PASSWORD" --symmetric --cipher-algo AES256 -o "$TEMP_DIR/archive/$SNAPSHOT_NAME.gpg" "$TEMP_DIR/archive/$SNAPSHOT_NAME"

# Remove o último snapshot do OneDrive
echo "Removendo o último snapshot do OneDrive..." >> "$LOG_FILE"
find "$ONEDRIVE_DIR" -type f -name "snapshot_*.tar.gz.gpg" -exec rm -f {} +

# Move o arquivo criptografado para o OneDrive
echo "Movendo o novo snapshot criptografado para o OneDrive..." >> "$LOG_FILE"
mv "$TEMP_DIR/archive/$SNAPSHOT_NAME.gpg" "$ONEDRIVE_DIR/"

# Remove o arquivo compactado não criptografado
echo "Removendo o arquivo compactado não criptografado..." >> "$LOG_FILE"
rm -f "$TEMP_DIR/archive/$SNAPSHOT_NAME"

# Finalização do log
echo "Snapshot criado, criptografado, e movido para $ONEDRIVE_DIR/$SNAPSHOT_NAME.gpg" >> "$LOG_FILE"
echo "Fim da execução: $(date)" >> "$LOG_FILE"
