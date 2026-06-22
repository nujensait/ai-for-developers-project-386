# PLAN — Сервис бронирования «Календарь»

> План выполнения ТЗ (`doc/AGENT_TZ.md`) ИИ-агентом.
> Подход: Design-First, backend MVP в первую очередь, затем frontend / E2E / CI.

## 0. Ключевые решения (согласовано)
- **Охват:** сначала backend MVP (Symfony API + Docker + тесты), затем фазы frontend, E2E, CI/CD.
- **Хранилище:** `FilesystemAdapter` за интерфейсом `*RepositoryInterface` (не `ArrayAdapter`) — данные переживают запросы под `php -S`.
- **Отклонения от ТЗ:** ошибки в примерах кода исправляются и документируются (см. §2).
- **TypeSpec:** переносится в `typespec/main.tsp` и переписывается как контракт Calendar API.

## 1. Окружение и предпосылки
- PHP локально **8.4** (ТЗ: 8.3; `>=8.3` — ок). Расширение **`intl` локально отсутствует** → канонический запуск/проверка через **Docker** (daemon UP), где `intl` ставится в образ.
- Compose: использовать `docker-compose` (v2.27); плагин `docker compose` отсутствует.
- Node 22 / npm 10 — для TypeSpec и (позже) фронтенда.
- Конфигурацию Symfony строить без жёсткой зависимости от `intl` для локальной разработки.

## 2. Отклонения от ТЗ (фиксируются в коде и WORK_LOG)
1. **Хранилище:** `FilesystemAdapter` (PSR-6) за `EventTypeRepositoryInterface` / `BookingRepositoryInterface` вместо in-process `ArrayAdapter`.
2. **`findConflicting`:** исправить инвертированную логику (`AGENT_TZ.md:404`) — конфликт = пересечение интервалов по **всем** бронированиям владельца (одна календарная сетка), а не пропуск по совпадению `eventTypeId`.
3. **PSR-6 API:** заменить несуществующий `$cache->set(...)` на `getItem()/$item->set()/save()`.
4. **Доп. зависимость:** `nelmio/cors-bundle` для CORS (в `composer.json` ТЗ его нет).
5. **`.env`:** убрать неиспользуемый `DATABASE_URL` (Doctrine не подключается).

## 3. Допущения
- Календарь одного владельца, без авторизации (по README).
- `endTime` вычисляется из `EventType.duration`.
- Слоты: интервал 30 мин, 09:00–21:00, на 14 дней — из параметров `services.yaml`.
- Формат ID: `evt_*` / `bok_*` (как в примерах README).
- Все даты — UTC, ISO 8601 (`Y-m-d\TH:i:s\Z`).

---

## 4. Фазы и шаги

### Фаза 0 — Контракт (Design-First)
- Создать `typespec/`, перенести `main.tsp`, переписать под Calendar API:
  модели `EventType`, `CreateEventType`, `Booking`, `CreateBooking`, `Slot`, `Error{code,message}`;
  маршруты: `/event-types` (CRUD), `/availability` (GET), `/bookings` (GET list/one, POST, DELETE).
- Обновить `tspconfig.yaml` / `package.json`; цель `make generate-api` → OpenAPI 3.1 в `openapi/`.
- **Готово:** `npx tsp compile` без ошибок, OpenAPI сгенерирован.

### Фаза 1 — Каркас backend
- `backend/composer.json` (Symfony 7.2: framework-bundle, cache, validator, dotenv; fosrest ^3.8, jms/serializer-bundle ^5.4, nelmio/api-doc-bundle, nelmio/cors-bundle; dev: phpunit ^11, maker, phpunit-bridge).
- `public/index.php`, `src/Kernel.php`, `config/{bundles.php,services.yaml,routes.yaml,packages/*}`, `.env`.
- Параметры: `app.working_hours_start/end`, `app.availability_days`.
- **Готово:** `composer install` ок; приложение поднимается; `GET /api/event-types` → `[]`.

### Фаза 2 — Домен: Entity / DTO / Repository
- `Entity/EventType`, `Entity/Booking` (+ геттеры).
- DTO: `CreateEventTypeDTO`, `EventTypeDTO::fromEntity`, `CreateBookingDTO`, `BookingDTO::fromEntity`, `SlotDTO`.
- Репозитории за интерфейсами на `FilesystemAdapter`; исправленный `findConflicting`; генерация ID.
- **Готово:** тесты логики пересечения слотов зелёные.

### Фаза 3 — Сервисы
- `EventTypeService` (CRUD), `BookingService` (create: вычисление `endTime`, проверка конфликта → `ConflictException`, проверка рабочего окна), `AvailabilityService` (генерация слотов, исправленная).
- `Exception/ConflictException`, `Exception/NotFoundException`.
- **Готово:** тесты сервисов (конфликт → исключение; корректный список слотов).

### Фаза 4 — Контроллеры и обвязка
- `EventTypeController` (GET all/one, POST, PUT, DELETE), `BookingController` (GET all/one, POST, DELETE, GET `/availability`).
- Единый формат ошибок `{code,message}`: 400 (валидация), 404 (не найдено), 409 (конфликт).
- FOSRest view listener, JMS serializer, Nelmio doc `/api/doc`, CORS для фронтенда.
- **Готово:** сквозной `curl`-сценарий; `/api/doc` открывается.

### Фаза 5 — Тесты (PHPUnit)
- `WebTestCase`: CRUD event-types, availability, booking 201/409, валидация 400, 404.
- `phpunit.xml.dist`, тестовое окружение (filesystem-кэш в `var/cache/test`, очистка в `setUp`).
- **Готово:** `php bin/phpunit` зелёный.

### Фаза 6 — Docker (backend)
- `backend/Dockerfile` (php:8.3 + intl/opcache + composer, `php -S 0.0.0.0:$PORT -t public`), `docker/php.ini`.
- `docker-compose.yml` (сервис backend), `Makefile` (`install/dev/build/test/generate-api`).
- **Готово:** `docker-compose build` без ошибок; контейнер отдаёт API на `$PORT`; `curl` работает.

### Фаза 7 — Frontend (React/Vite) — *последующая фаза*
- Vite + TS + клиент API из OpenAPI; экраны: список типов, выбор слота, бронирование.

### Фаза 8 — E2E (Playwright) — *последующая фаза*
- Сценарий «забронировать слот»; `Dockerfile.playwright`, сервис в compose.

### Фаза 9 — CI/CD — *последующая фаза*
- GitHub Actions (composer install, phpunit, build), release-please. **Не трогать** `hexlet-check.yml`.

---

## 5. Процесс
- Вести `doc/WORK_LOG.md` по шагам; при необходимости — `doc/tasks/*.md` на фазу.
- Коммиты — только по явному запросу.
- Проверка — преимущественно через Docker (`intl` доступен) + `curl` + PHPUnit.

## 6. Риски и митигации
- `intl` нет локально → канонический запуск в Docker; конфиг без зависимости от `intl`.
- Нет плагина `docker compose` → использовать `docker-compose` (v2.27).
- Дрейф версий SF 7.2 + бандлы → пиннинг и фиксация `composer.lock`.
- Filesystem-кэш в тестах → изоляция по окружению и очистка перед каждым тестом.

## 7. Definition of Done (по чек-листу ТЗ)
- [ ] Эндпоинты по контракту TypeSpec
- [ ] Хранилище переживает запросы (Filesystem)
- [ ] Валидация (Symfony Validator)
- [ ] Конфликт → 409
- [ ] Документация `/api/doc`
- [ ] CORS для фронтенда
- [ ] Docker-образ собирается
- [ ] Запуск на `$PORT`
- [ ] PHPUnit зелёный
- [ ] (поздняя фаза) интеграция с фронтендом
