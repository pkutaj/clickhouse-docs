---
slug: /sql-reference/table-functions/timeSeriesTags
sidebar_position: 145
sidebar_label: timeSeriesTags
title: 'timeSeriesTags'
description: 'Функция таблицы timeSeriesTags возвращает таблицу тегов, используемую таблицей `db_name.time_series_table`, у которой движок таблицы - TimeSeries.'
---


# Функция таблицы timeSeriesTags

`timeSeriesTags(db_name.time_series_table)` - Возвращает таблицу [тегов](../../engines/table-engines/integrations/time-series.md#tags-table), используемую таблицей `db_name.time_series_table`, у которой движок таблицы - [TimeSeries](../../engines/table-engines/integrations/time-series.md):

``` sql
CREATE TABLE db_name.time_series_table ENGINE=TimeSeries TAGS tags_table
```

Функция также работает, если таблица _tags_ является внутренней:

``` sql
CREATE TABLE db_name.time_series_table ENGINE=TimeSeries TAGS INNER UUID '01234567-89ab-cdef-0123-456789abcdef'
```

Следующие запросы эквивалентны:

``` sql
SELECT * FROM timeSeriesTags(db_name.time_series_table);
SELECT * FROM timeSeriesTags('db_name.time_series_table');
SELECT * FROM timeSeriesTags('db_name', 'time_series_table');
```
