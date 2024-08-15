# Sync Projects to OneDrive

Este script automatiza a criação de snapshots de projetos de desenvolvimento com Git e os sincroniza com o OneDrive. O script foi projetado para ser executado diariamente às 4h da manhã usando o cron no WSL.

## Motivação

A necessidade de criar este script surgiu devido ao fato de que, durante o desenvolvimento de múltiplos projetos, alguns arquivos e diretórios são ignorados pelo Git (`.gitignore`), mas ainda assim é importante mantê-los sincronizados e seguros.

Além disso, manter a pasta `.git` dentro do OneDrive não é recomendável, pois pode causar corrupção de dados e problemas de desempenho. Para evitar esses problemas, este script foi desenvolvido para criar snapshots dos projetos de desenvolvimento, incluindo os arquivos ignorados pelo Git, sem sincronizar diretamente o diretório `.git` com o OneDrive. Dessa forma, garantimos uma camada extra de segurança e recuperação de dados sem os riscos associados à sincronização direta do repositório Git.

## Pré-requisitos

- Windows 10/11 com WSL (Windows Subsystem for Linux) instalado.
- OneDrive configurado e sincronizando com seu sistema.
- Git instalado no WSL.

## Instalação

Siga os passos abaixo para configurar o script no seu ambiente:

### 1. Clone este repositório

Primeiro, clone este repositório na pasta onde você deseja armazenar o script:

```bash
git clone https://github.com/seu-usuario/seu-repositorio.git /mnt/c/users/luciano.leite/Dev/_sync
```

### 2. Edite o Script

Abra o terminal WSL e navegue até a pasta onde o script foi clonado:

```bash
cd /mnt/c/users/luciano.leite/Dev/_sync
```

Abra o script para edição:

```bash
nano sync_projects_to_onedrive.sh
```

### 3. Configuração das Variáveis

Verifique e configure as seguintes variáveis dentro do script:

- **`PROJECTS_DIR`**: Diretório onde estão localizados os projetos de desenvolvimento.
  - Exemplo: `/mnt/c/users/luciano.leite/Dev`
- **`TEMP_DIR`**: Diretório temporário onde o snapshot será criado antes de ser sincronizado com o OneDrive.
  - Exemplo: `/mnt/c/users/luciano.leite/Temp`
- **`ONEDRIVE_DIR`**: Diretório dentro do OneDrive onde os snapshots serão armazenados.
  - Exemplo: `/mnt/c/users/luciano.leite/OneDrive - Alloha Fibra/Dev`
- **`LOG_DIR`**: Diretório onde os logs de execução do script serão armazenados.
  - Exemplo: `/mnt/c/users/luciano.leite/Dev/_sync`

As configurações padrão no script são:

```bash
PROJECTS_DIR="/mnt/c/users/luciano.leite/Dev"
TEMP_DIR="/mnt/c/users/luciano.leite/Temp"
ONEDRIVE_DIR="/mnt/c/users/luciano.leite/OneDrive - Alloha Fibra/Dev"
LOG_DIR="/mnt/c/users/luciano.leite/Dev/_sync"
```

Salve e saia do editor:
- **No nano:** Pressione `Ctrl + O` para salvar, depois `Ctrl + X` para sair.

### 4. Tornar o Script Executável

Certifique-se de que o script tenha permissão de execução:

```bash
chmod +x /mnt/c/users/luciano.leite/Dev/_sync/sync_projects_to_onedrive.sh
```

### 5. Configurar Cron para Execução Automática

Abra o crontab para configuração:

```bash
crontab -e
```

Adicione a seguinte linha ao final do arquivo para agendar a execução do script diariamente às 4h da manhã:

```bash
0 4 * * * /mnt/c/users/luciano.leite/Dev/_sync/sync_projects_to_onedrive.sh >> /mnt/c/users/luciano.leite/Dev/_sync/cron_output.log 2>&1
```

Salve e saia do editor:
- **No nano:** Pressione `Ctrl + O` para salvar, depois `Ctrl + X` para sair.

### 6. Reiniciar o Serviço Cron

Para garantir que o cron está configurado corretamente após a alteração, reinicie o serviço cron:

```bash
sudo service cron restart
```

### 7. Verificar a Execução do Script

Após a primeira execução programada (às 4h da manhã), verifique os logs gerados.

## Funcionalidades do Script

- **Verificação de Operações Git em Andamento:** O script verifica se há operações Git em andamento (como rebase ou merge) e aborta a execução se detectar alguma.
- **Sincronização com OneDrive:** O script cria um snapshot do diretório de projetos e o sincroniza com o OneDrive.
- **Logs Detalhados:** Gera logs detalhados da execução, armazenados na mesma pasta do script.

## Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir um Pull Request ou relatar problemas na aba Issues.