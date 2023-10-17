#!/bin/bash

# Установка WireGuard
apt-get update
apt-get install -y wireguard

# Генерация ключей
umask 077
wg genkey | tee server_private_key | wg pubkey > server_public_key
wg genkey | tee client_private_key | wg pubkey > client_public_key

server_private_key=$(cat server_private_key)
server_public_key=$(cat server_public_key)
client_private_key=$(cat client_private_key)
client_public_key=$(cat client_public_key)

# Получение публичного IP-адреса сервера
server_ip=$(curl -s ifconfig.me)

# Создание конфигурационного файла сервера
cat <<EOL > /etc/wireguard/wg0.conf
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = $server_private_key

[Peer]
PublicKey = $client_public_key
AllowedIPs = 10.0.0.2/32
EOL

# Запуск WireGuard сервера
wg-quick up wg0

# Создание конфигурационного файла клиента
cat <<EOL
[Interface]
Address = 10.0.0.2/24
PrivateKey = $client_private_key

[Peer]
PublicKey = $server_public_key
Endpoint = $server_ip:51820
AllowedIPs = 0.0.0.0/0
EOL
