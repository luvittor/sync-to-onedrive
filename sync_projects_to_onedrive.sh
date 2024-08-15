#!/bin/bash

# Configurações
PROJECTS_DIR="/mnt/c/users/luciano.leite/Dev"
TEMP_DIR="/mnt/c/users/luciano.leite/Temp"
ONEDRIVE_DIR="/mnt/c/users/luciano.leite/OneDrive - Alloha Fibra/Dev"
LOG_DIR="/mnt/c/users/luciano.leite/Dev/_sync"
LOG_FILE="$LOG_DIR/sync_log_$(date +'%Y%m%d_%H%M%S').log"

# Início do log
echo "Início da execução: $(date)" > "$LOG_FILE"
echo "Sincronização de projetos iniciada..." >> "$LOG_FILE"

# Criação da pasta temporária se não existir
echo "Criando pasta temporária, se não existir..." >> "$LOG_FILE"
mkdir -p "$TEMP_DIR"

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
    
    # Exibe um aviso se houver alterações não comitadas
    if [[ $(git status --porcelain) ]]; then
        echo "Aviso: Há alterações não comitadas no repositório $repo_dir." >> "$LOG_FILE"
    fi
    
    cd "$PROJECTS_DIR"
done

# Sincroniza o diretório de projetos para um diretório temporário
echo "Sincronizando o diretório de projetos para a pasta temporária..." >> "$LOG_FILE"
rsync -a --delete "$PROJECTS_DIR/" "$TEMP_DIR/"

# Remove o último snapshot do OneDrive
echo "Removendo o último snapshot do OneDrive..." >> "$LOG_FILE"
find "$ONEDRIVE_DIR" -type f -name "snapshot_*.tar.gz" -exec rm -f {} +

# Cria um novo snapshot com a data e hora atuais
SNAPSHOT_NAME="snapshot_$(date +'%Y%m%d_%H%M%S').tar.gz"
echo "Criando um novo snapshot: $SNAPSHOT_NAME..." >> "$LOG_FILE"
tar -czf "$ONEDRIVE_DIR/$SNAPSHOT_NAME" -C "$TEMP_DIR" .

# Limpa o diretório temporário
echo "Limpando o diretório temporário..." >> "$LOG_FILE"
rm -rf "$TEMP_DIR/*"

# Finalização do log
echo "Snapshot criado e sincronizado para $ONEDRIVE_DIR/$SNAPSHOT_NAME" >> "$LOG_FILE"
echo "Fim da execução: $(date)" >> "$LOG_FILE"
