---
title: 'Переизбыток памяти'
description: 'Экспериментальная техника, предназначенная для установки более гибких ограничений по памяти для запросов.'
slug: /operations/settings/memory-overcommit
---


# Переизбыток памяти

Переизбыток памяти — это экспериментальная техника, предназначенная для установки более гибких ограничений по памяти для запросов.

Идея этой техники состоит в том, чтобы ввести настройки, которые могут представлять гарантированное количество памяти, которое может использовать запрос. Когда переизбыток памяти включен и достигнуто ограничение памяти, ClickHouse выберет самый перегруженный запрос и попытается освободить память, убив этот запрос.

Когда достигнуто ограничение памяти, любой запрос будет ждать некоторое время во время попытки выделить новую память. Если время ожидания истекает, и память освобождается, запрос продолжает выполнение. В противном случае будет выброшено исключение, и запрос будет убит.

Выбор запроса для остановки или убийства выполняется либо глобальными, либо пользовательскими трекерами переизбытка, в зависимости от того, какое ограничение памяти достигнуто. Если трекер переизбытка не может выбрать запрос для остановки, будет выброшено исключение MEMORY_LIMIT_EXCEEDED.

## Пользовательский трекер переизбытка {#user-overcommit-tracker}

Пользовательский трекер переизбытка находит запрос с наибольшим коэффициентом переизбытка в списке запросов пользователя. Коэффициент переизбытка для запроса рассчитывается как количество выделенных байт, деленное на значение настройки `memory_overcommit_ratio_denominator_for_user`.

Если `memory_overcommit_ratio_denominator_for_user` для запроса равно нулю, трекер переизбытка не выберет этот запрос.

Время ожидания устанавливается настройкой `memory_usage_overcommit_max_wait_microseconds`.

**Пример**

```sql
SELECT number FROM numbers(1000) GROUP BY number SETTINGS memory_overcommit_ratio_denominator_for_user=4000, memory_usage_overcommit_max_wait_microseconds=500
```

## Глобальный трекер переизбытка {#global-overcommit-tracker}

Глобальный трекер переизбытка находит запрос с наибольшим коэффициентом переизбытка в списке всех запросов. В этом случае коэффициент переизбытка рассчитывается как количество выделенных байт, деленное на значение настройки `memory_overcommit_ratio_denominator`.

Если `memory_overcommit_ratio_denominator` для запроса равно нулю, трекер переизбытка не выберет этот запрос.

Время ожидания устанавливается параметром `memory_usage_overcommit_max_wait_microseconds` в файле конфигурации.
