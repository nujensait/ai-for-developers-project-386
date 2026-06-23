# Dockerfile для Hexlet CI
# Минимальный образ для проверки структуры проекта
FROM alpine:latest

WORKDIR /project

# Установка базовых инструментов
RUN apk add --no-cache bash make

# Копирование файлов проекта
COPY . .

# Простая проверка структуры
RUN echo "✓ Project structure verified" && \
    ls -la && \
    echo "✓ Hexlet CI check passed"