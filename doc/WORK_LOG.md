# WORK LOG — Сервис «Календарь»

Краткий лог разработки (новые записи сверху).

## 2026-06-22

- **Старт.** Прочитано ТЗ (`doc/AGENT_TZ.md`), согласованы уточнения заказчика:
  SQLite+Doctrine вместо in-memory, порт по умолчанию 8081, полная поставка backend+Docker+Makefile+README.
- **Окружение проверено:** PHP 8.4 локально (нет `pdo_sqlite`/`intl`), Docker UP,
  `docker-compose` v2.27, Node 22 + `tsp`. Решение: backend собирается/проверяется в Docker.
- **PLAN.md обновлён:** зафиксированы решения, отклонения от ТЗ (SQLite, нативный стек Symfony
  без FOSRest/JMS/Nelmio, Swagger UI из TypeSpec-OpenAPI), порт 8081.
