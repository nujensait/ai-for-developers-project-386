# 📅 Календарь — Сервис бронирования времени

Сервис для бронирования времени по мотивам [Cal.com](https://cal.com).  
Проект разработан в рамках курса **Hexlet AI для разработчиков**.

### Hexlet tests and linter status:
[![Actions Status](https://github.com/nujensait/ai-for-developers-project-386/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/nujensait/ai-for-developers-project-386/actions)

---

## 📑 Оглавление

- [🎯 О проекте](#-о-проекте)
- [🧱 Технологический стек](#-технологический-стек)
- [📂 Структура проекта](#-структура-проекта)
- [🚀 Быстрый старт](#-быстрый-старт)
- [📖 API Документация](#-api-документация)
- [🧪 Тестирование](#-тестирование)
- [🐳 Docker-образ](#-docker-образ)
- [🔧 Разработка](#-разработка)
- [🤖 Разработка с ИИ-агентами](#-разработка-с-ии-агентами)
- [📋 План развития](#-план-развития)
- [📝 Лицензия](#-лицензия)
- [🙏 Благодарности](#-благодарности)
- [Автор](#автор)

---

## 🎯 О проекте

**"Запись на звонок"** — это упрощённый сервис бронирования времени.  
Владелец календаря публикует доступное время для встреч, а гости выбирают свободные слоты и записываются.

### Ключевые возможности

- **Владелец календаря:**
    - Создание типов событий (название, описание, длительность)
    - Просмотр всех бронирований
    - Управление событиями (CRUD)

- **Гость:**
    - Просмотр доступных типов событий
    - Выбор свободного слота (30-минутные интервалы, 9:00–21:00, на 14 дней вперёд)
    - Бронирование с указанием имени и email

- **Бизнес-правила:**
    - Один слот — одна запись (конфликт возвращает 409)
    - Все даты в UTC (ISO 8601)
    - Данные хранятся в памяти (без БД, сброс при перезапуске)

---

## 🧱 Технологический стек

| Компонент | Технологии |
|-----------|------------|
| **Бэкенд** | Symfony 7.2, PHP 8.3, FOSRestBundle, JMSSerializer, NelmioApiDoc |
| **Фронтенд** | React + TypeScript + Vite + shadcn/ui (рекомендуется) |
| **API-контракт** | TypeSpec → OpenAPI 3.1 |
| **Тестирование** | PHPUnit (бэкенд), Playwright (E2E) |
| **Контейнеризация** | Docker + Docker Compose |
| **CI/CD** | GitHub Actions, release-please |
| **Деплой** | Render (или любой хостинг с Docker) |

---

## 📂 Структура проекта

```
calendar/
├── .github/workflows/          # CI/CD (тесты, релизы)
├── backend/                    # Symfony API
│   ├── config/                 # Конфигурация
│   ├── public/                 # Точка входа
│   ├── src/
│   │   ├── Controller/         # REST-контроллеры
│   │   ├── DTO/                # Data Transfer Objects
│   │   ├── Entity/             # Доменные сущности
│   │   ├── Exception/          # Кастомные исключения
│   │   ├── Repository/         # In-memory хранилища
│   │   └── Service/            # Бизнес-логика
│   ├── tests/                  # PHPUnit-тесты
│   ├── Dockerfile
│   └── composer.json
├── frontend/                   # React-приложение
├── typespec/                   # TypeSpec-спецификация API
├── docker-compose.yml          # Локальный запуск
├── Makefile                    # Упрощённые команды
└── README.md
```

---

## 🚀 Быстрый старт

### Требования

- **Docker** и **Docker Compose** (установлены)
- **Make** (опционально, для удобства)
- **WSL** (для Windows-пользователей)

### 1. Клонирование репозитория

```bash
git clone https://github.com/your-username/calendar.git
cd calendar
```

### 2. Запуск в Docker (рекомендуемый способ)

```bash
# Собрать и запустить все сервисы
docker-compose up -d --build

# Проверить, что всё работает
curl http://localhost:8080/api/event-types
```

Приложение будет доступно:
- **Бэкенд API:** `http://localhost:8080`
- **Документация API:** `http://localhost:8080/api/doc`
- **Фронтенд:** `http://localhost:5173`

### 3. Запуск без Docker (для разработки)

```bash
# Бэкенд
cd backend
composer install
php -S 0.0.0.0:8080 -t public

# Фронтенд (в другом терминале)
cd frontend
npm install
npm run dev
```

---

## 📖 API Документация

После запуска документация доступна по адресу:  
👉 [http://localhost:8080/api/doc](http://localhost:8080/api/doc)

### Основные эндпоинты

| Метод | Эндпоинт | Описание |
|-------|----------|----------|
| `GET` | `/api/event-types` | Список типов событий |
| `POST` | `/api/event-types` | Создать тип события |
| `GET` | `/api/availability` | Свободные слоты |
| `POST` | `/api/bookings` | Создать бронирование |
| `GET` | `/api/bookings` | Список бронирований |

### Пример запроса (создание бронирования)

```bash
curl -X POST http://localhost:8080/api/bookings \
  -H "Content-Type: application/json" \
  -d '{
    "eventTypeId": "evt_123",
    "guestName": "Иван Петров",
    "guestEmail": "ivan@example.com",
    "startTime": "2026-06-25T10:00:00Z"
  }'
```

### Ответ (201 Created)

```json
{
  "id": "bok_456",
  "eventTypeId": "evt_123",
  "guestName": "Иван Петров",
  "guestEmail": "ivan@example.com",
  "startTime": "2026-06-25T10:00:00Z",
  "endTime": "2026-06-25T10:30:00Z",
  "createdAt": "2026-06-22T17:00:00Z"
}
```

---

## 🧪 Тестирование

### PHPUnit (бэкенд)

```bash
cd backend
php bin/phpunit
```

### Playwright (E2E)

```bash
docker-compose run --rm playwright
```

---

## 🐳 Docker-образ

Приложение упаковано в Docker-образ и может быть развёрнуто на любом хостинге.

### Сборка образа

```bash
docker build -t calendar-app -f backend/Dockerfile .
```

### Запуск контейнера

```bash
docker run -p 8080:8080 -e PORT=8080 calendar-app
```

---

## 🔧 Разработка

### Генерация OpenAPI-спецификации из TypeSpec

```bash
cd typespec
npx tsp compile main.tsp --emit @typespec/openapi3 --output-dir ../openapi
```

### Добавление новой модели

1. Описать модель в `typespec/main.tsp`
2. Сгенерировать OpenAPI: `make generate-api`
3. Обновить бэкенд: добавить Entity, DTO, Repository, Service
4. Обновить фронтенд: типы и запросы

---

## 🤖 Разработка с ИИ-агентами

Весь проект разработан с использованием **ИИ-агентов** (OpenCode + Claude/DeepSeek).

**Принципы:**
- **Design First** — сначала контракт, потом код
- **Ни одной строки вручную** — весь код написан агентами
- **Итеративность** — маленькие шаги, постоянная проверка

---

## 📋 План развития

- [x] Базовый сценарий бронирования
- [ ] Кастомное расписание (гибкие окна доступности)
- [ ] Таймзоны
- [ ] Регистрация и аккаунты
- [ ] Интеграция с календарями (Google, iCloud)
- [ ] Уведомления (email, Telegram)
- [ ] Перенос/отмена бронирований
- [ ] Аналитика по записям

---

## 📝 Лицензия

MIT © [Hexlet](https://hexlet.io)

---

## 🙏 Благодарности

- [Cal.com](https://cal.com) — за вдохновение
- [TypeSpec](https://typespec.io) — за инструмент описания API
- [Symfony](https://symfony.com) — за надёжный бэкенд
- [Hexlet](https://hexlet.io) — за крутой курс и проект

---

**Вопросы?** Создайте [Issue](https://github.com/your-username/calendar/issues) или свяжитесь с автором.

---

## Как использовать этот README

1. **Сохраните файл** как `README.md` в корне проекта
2. **Замените `your-username`** на ваш GitHub-username
3. **Уберите/оставьте** разделы по мере реализации
4. **Обновляйте** по мере развития проекта

---

## Автор

- Иконников Михаил <mishaikon@gmail.com>