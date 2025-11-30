#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="myapp:dev"
CONTAINER_NAME="myapp_test_container"

echo "1) Сборка образа..."
docker build -f Dockerfile.python -t "$IMAGE_NAME" .

echo "2) Запуск контейнера в фоне..."
docker run -d --name "$CONTAINER_NAME" -p 5000:5000 "$IMAGE_NAME"

echo "3) Ждём старта приложения (проверяем / пробуем опросить 10 раз)..."
TRIES=0
MAX_TRIES=20
until curl -sSf http://127.0.0.1:5000/ >/dev/null 2>&1 || [ $TRIES -ge $MAX_TRIES ]; do
  TRIES=$((TRIES+1))
  echo "Попытка $TRIES/$MAX_TRIES — жду 2 секунды..."
  sleep 2
done

if [ $TRIES -ge $MAX_TRIES ]; then
  echo "Ошибка: приложение не ответило. Логи контейнера:"
  docker logs "$CONTAINER_NAME" --tail 200
  docker rm -f "$CONTAINER_NAME" || true
  exit 1
fi

echo "4) Приложение запущено — тестируем конечную точку / (или /health)."
curl -v http://127.0.0.1:5000/ || true
echo
echo "5) Очищаем тестовый контейнер..."
docker rm -f "$CONTAINER_NAME"

echo "Готово — сборка и базовый запуск прошли успешно."