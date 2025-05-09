---
slug: /sql-reference/functions/geo/geohash
sidebar_label: Geohash
title: "Функции для работы с Geohash"
---

## Geohash {#geohash}

[Geohash](https://en.wikipedia.org/wiki/Geohash) — это система геокодирования, которая разбивает поверхность Земли на ячейки в форме сетки и кодирует каждую ячейку в короткую строку букв и цифр. Это иерархическая структура данных, поэтому чем длиннее строка geohash, тем точнее будет географическое местоположение.

Если вам нужно вручную преобразовать географические координаты в строки geohash, вы можете использовать [geohash.org](http://geohash.org/).

## geohashEncode {#geohashencode}

Кодирует широту и долготу в строку [geohash](#geohash).

**Синтаксис**

``` sql
geohashEncode(longitude, latitude, [precision])
```

**Входные значения**

- `longitude` — Долгота части координаты, которую вы хотите закодировать. Значение с плавающей точкой в диапазоне `[-180°, 180°]`. [Float](../../data-types/float.md). 
- `latitude` — Широта части координаты, которую вы хотите закодировать. Значение с плавающей точкой в диапазоне `[-90°, 90°]`. [Float](../../data-types/float.md).
- `precision` (опционально) — Длина полученной закодированной строки. По умолчанию `12`. Целое число в диапазоне `[1, 12]`. [Int8](../../data-types/int-uint.md).

:::note
- Все параметры координат должны быть одного типа: либо `Float32`, либо `Float64`.
- Для параметра `precision` любое значение меньше `1` или больше `12` будет беззвучно преобразовано в `12`.
:::

**Возвращаемые значения**

- Алфавитно-цифровая строка закодированной координаты (используется модифицированная версия алфавита для кодирования base32). [String](../../data-types/string.md).

**Пример**

Запрос:

``` sql
SELECT geohashEncode(-5.60302734375, 42.593994140625, 0) AS res;
```

Результат:

``` text
┌─res──────────┐
│ ezs42d000000 │
└──────────────┘
```

## geohashDecode {#geohashdecode}

Декодирует любую строку, закодированную в [geohash](#geohash), в долготу и широту.

**Синтаксис**

```sql
geohashDecode(hash_str)
```

**Входные значения**

- `hash_str` — Закодированная строка geohash.

**Возвращаемые значения**

- Кортеж `(longitude, latitude)` значений `Float64` долготы и широты. [Tuple](../../data-types/tuple.md)([Float64](../../data-types/float.md))

**Пример**

``` sql
SELECT geohashDecode('ezs42') AS res;
```

``` text
┌─res─────────────────────────────┐
│ (-5.60302734375,42.60498046875) │
└─────────────────────────────────┘
```

## geohashesInBox {#geohashesinbox}

Возвращает массив строк, закодированных в [geohash](#geohash) с заданной точностью, которые попадают внутрь и пересекают границы данного прямоугольника, в основном 2D-решетка, плоская в массиве.

**Синтаксис**

``` sql
geohashesInBox(longitude_min, latitude_min, longitude_max, latitude_max, precision)
```

**Аргументы**

- `longitude_min` — Минимальная долгота. Диапазон: `[-180°, 180°]`. [Float](../../data-types/float.md).
- `latitude_min` — Минимальная широта. Диапазон: `[-90°, 90°]`. [Float](../../data-types/float.md).
- `longitude_max` — Максимальная долгота. Диапазон: `[-180°, 180°]`. [Float](../../data-types/float.md).
- `latitude_max` — Максимальная широта. Диапазон: `[-90°, 90°]`. [Float](../../data-types/float.md).
- `precision` — Точность geohash. Диапазон: `[1, 12]`. [UInt8](../../data-types/int-uint.md).

:::note    
Все параметры координат должны быть одного типа: либо `Float32`, либо `Float64`.
:::

**Возвращаемые значения**

- Массив строк длины точности, представляющих geohash-ячейки, покрывающие указанную область, не следует полагаться на порядок элементов. [Array](../../data-types/array.md)([String](../../data-types/string.md)).
- `[]` - Пустой массив, если минимальные значения широты и долготы не меньше соответствующих максимальных значений.

:::note    
Функция вызывает исключение, если полученный массив превышает 10'000'000 элементов.
:::

**Пример**

Запрос:

``` sql
SELECT geohashesInBox(24.48, 40.56, 24.785, 40.81, 4) AS thasos;
```

Результат:

``` text
┌─thasos──────────────────────────────────────┐
│ ['sx1q','sx1r','sx32','sx1w','sx1x','sx38'] │
└─────────────────────────────────────────────┘
```
