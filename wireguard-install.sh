#!/bin/bash

# Устанавливаем необходимые пакеты
apt-get update
apt-get install -y wireguard qrencode

# Генерируем ключи
umask 077
wg genkey > server_private_key
wg genkey > client_private_key
wg pubkey < server_private_key > server_public_key
wg pubkey < client_private_key > client_public_key

SERVER_PRIVATE_KEY=$(cat server_private_key)
SERVER_PUBLIC_KEY=$(cat server_public_key)
CLIENT_PRIVATE_KEY=$(cat client_private_key)
CLIENT_PUBLIC_KEY=$(cat client_public_key)

# Автоматически определяем публичный IP-адрес сервера
SERVER_IP=$(curl -s https://ifconfig.me)

# Создаем конфигурационный файл сервера
cat <<EOL > /etc/wireguard/wg0.conf
[Interface]
Address = 10.0.0.1/24
PrivateKey = ${SERVER_PRIVATE_KEY}
ListenPort = 51820

[Peer]
PublicKey = ${CLIENT_PUBLIC_KEY}
AllowedIPs = 10.0.0.2/32
EOL

# Запускаем WireGuard
wg-quick up wg0
systemctl enable wg-quick@wg0

# Выводим конфигурационный файл для клиента
echo "Конфигурация клиента:"
cat <<EOL
[Interface]
Address = 10.0.0.2/24
PrivateKey = ${CLIENT_PRIVATE_KEY}

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
Endpoint = ${SERVER_IP}:51820
AllowedIPs = 0.0.0.0/0
EOL
