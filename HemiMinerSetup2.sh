#!/bin/bash

# Node Mafia ASCII Art
echo "
     __             _                        __  _        
  /\ \ \  ___    __| |  ___   /\/\    __ _  / _|(_)  __ _ 
 /  \/ / / _ \  / _\` | / _ \ /    \  / _\` || |_ | | / _\` |
/ /\  / | (_) || (_| ||  __// /\/\ \| (_| ||  _|| || (_| |
\_\ \/   \___/  \__,_| \___|\/    \/ \__,_||_|  |_| \__,_|
                                                          
EN Telegram: soon..
RU Telegram: https://t.me/SixThoughtsLines
GitHub: https://github.com/NodeMafia
"

# Переходим в директорию HemiMiner
echo ""
echo "Navigating to HemiMiner/heminetwork_v0.4.3_linux_amd64/..."
cd HemiMiner/heminetwork_v0.4.3_linux_amd64/ || { echo "Failed to navigate to directory. Exiting."; exit 1; }

# Создаем и переходим в screen сессию, выполняем команды внутри неё
echo "Creating and entering a new screen session named 'Hemi_nodeeval' and executing commands..."
screen -S Hemi_nodeeval -dm bash -c "
    # Получаем переменные из файла popm-address.json
    eval \$(jq -r '. | \"ETHEREUM_ADDRESS=\(.ethereum_address)\nNETWORK=\(.network)\nPRIVATE_KEY=\(.private_key)\nPUBLIC_KEY=\(.public_key)\nPUBKEY_HASH=\(.pubkey_hash)\"' ~/popm-address.json)

    # Экспортируем переменные
    export POPM_BTC_PRIVKEY=\$PRIVATE_KEY
    export POPM_STATIC_FEE=50
    export POPM_BFG_URL=wss://testnet.rpc.hemi.network/v1/ws/public

    # Вывод переменных для отладки внутри screen
    echo \"Ethereum Address: \$ETHEREUM_ADDRESS\"
    echo \"Network: \$NETWORK\"
    echo \"Private Key: \$PRIVATE_KEY\"
    echo \"Public Key: \$PUBLIC_KEY\"
    echo \"Public Key Hash: \$PUBKEY_HASH\"

    # Инструкции
    echo -e \"\n\033[31m!INSTRUCTIONS FOR USE!\033[0m\"
    echo -e \"\033[35mTo close the screen, use: CTRL+A+D\033[0m\"
    echo -e \"\033[35mTo open the screen for viewing logs: screen -r Hemi_nodeeval\033[0m\"
    echo -e \"\033[35mView list of screens: screen -ls\033[0m\"
    echo -e \"\033[35mTo stop HemiMiner: screen -r Hemi_nodeeval -X quit\033[0m\"

    # Подтверждение кнопкой Enter
    read -p \"Press Enter to continue and start popmd...\"

    # Запуск popmd
    ./popmd
"

# Автоматически открываем сессию Hemi_nodeeval
echo "Opening the screen session 'Hemi_nodeeval'..."
screen -r Hemi_nodeeval
