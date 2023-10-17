#!/bin/bash

# Обновление и установка необходимых пакетов
sudo apt update && sudo apt install -y wireguard

# Генерация серверных ключей
wg genkey | tee server_private_key | wg pubkey > server_public_key

# Настройка конфига сервера
echo "[Interface]
Address = 10.0.0.1/24
SaveConfig = true
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
ListenPort = 51820
PrivateKey = $(cat server_private_key)

" > /etc/wireguard/wg0.conf

# Генерация клиентских ключей
wg genkey | tee client_private_key | wg pubkey > client_public_key

# Настройка конфига клиента
echo "[Interface]
Address = 10.0.0.2/24
PrivateKey = $(cat client_private_key)

[Peer]
PublicKey = $(cat server_public_key)
Endpoint = <your_server_ip>:51820
AllowedIPs = 0.0.0.0/0

" > client.conf

# Запуск сервера
sudo wg-quick up wg0
sudo systemctl enable wg-quick@wg0

echo "Конфигурация клиента:"
cat client.conf
