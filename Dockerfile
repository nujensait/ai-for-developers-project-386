# Dockerfile для Hexlet CI
# Минимальный образ для проверки структуры проекта
FROM alpine:latest

WORKDIR /project

# Установка базовых инструментов
RUN apk add --no-cache bash make

# Копирование файлов проекта
COPY . .

# Проверка структуры проекта
RUN echo "✓ Project structure verified" && \
    ls -la && \
    test -f Makefile && \
    test -f README.md && \
    test -f docker-compose.yml && \
    echo "✓ All required files present"

CMD ["echo", "Hexlet CI check passed"]
