---
slug: /sql-reference/aggregate-functions/reference/approxtopk
sidebar_position: 107
title: "approx_top_k"
description: "Возвращает массив приблизительно самых частых значений и их количества в указанной колонке."
---


# approx_top_k

Возвращает массив приблизительно самых частых значений и их количества в указанной колонке. Полученный массив отсортирован в порядке убывания приблизительной частоты значений (не по самим значениям).


``` sql
approx_top_k(N)(column)
approx_top_k(N, reserved)(column)
```

Эта функция не предоставляет гарантируемый результат. В некоторых ситуациях могут возникнуть ошибки, и она может вернуть частые значения, которые не являются самыми частыми.

Рекомендуем использовать значение `N < 10`; производительность снижается с большими значениями `N`. Максимальное значение `N = 65536`.

**Параметры**

- `N` — Количество элементов для возврата. Необязательный. Значение по умолчанию: 10.
- `reserved` — Определяет, сколько ячеек зарезервировано для значений. Если uniq(column) > reserved, результат функции topK будет приблизительным. Необязательный. Значение по умолчанию: N * 3.
 
**Аргументы**

- `column` — Значение для вычисления частоты.

**Пример**

Запрос:

``` sql
SELECT approx_top_k(2)(k)
FROM VALUES('k Char, w UInt64', ('y', 1), ('y', 1), ('x', 5), ('y', 1), ('z', 10));
```

Результат:

``` text
┌─approx_top_k(2)(k)────┐
│ [('y',3,0),('x',1,0)] │
└───────────────────────┘
```


# approx_top_count

Является псевдонимом для функции `approx_top_k`.

**См. также**

- [topK](../../../sql-reference/aggregate-functions/reference/topk.md)
- [topKWeighted](../../../sql-reference/aggregate-functions/reference/topkweighted.md)
- [approx_top_sum](../../../sql-reference/aggregate-functions/reference/approxtopsum.md)
