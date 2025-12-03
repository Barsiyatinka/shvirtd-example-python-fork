#!/bin/bash
set -e

echo "Обновляем систему "
sudo apt update -y

echo " Устанавливаем Docker "
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git

# Docker репозиторий
if [ ! -f /usr/share/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
fi

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo " Очищаем старую папку проекта "
sudo rm -rf /opt/shvirtd-example-python-fork
sudo mkdir -p /opt
cd /opt

echo " Клонируем репозиторий из ветки "
git clone --branch add-dockerfiles https://github.com/Barsiyatinka/shvirtd-example-python-fork.git
mv shvirtd-example-python-fork shvirtd-example-python-fork-ht
cd shvirtd-example-python-fork-ht

echo " Создаём PROD .env "
cat <<EOF > .env
MYSQL_ROOT_PASSWORD=YtReWq4321
MYSQL_DATABASE=virtd
MYSQL_USER=app
MYSQL_PASSWORD=QwErTy1234
EOF

echo " Запускаем проект "
sudo docker compose down || true
sudo docker compose up -d --build

echo " Ждём запуск MySQL (10 сек)" # по другому не запускалось
sleep 10

echo " Статус запустившихся контейнеров "
sudo docker compose ps

#echo " Готово! http://84.201.148.119:8090 "

echo " Получаем внешний IP машины "
PUBLIC_IP=$(curl -s ifconfig.me)
#echo "Внешний IP: $PUBLIC_IP"

echo " Проверка: сервис должен открываться по URL "
echo "http://$PUBLIC_IP:8090"