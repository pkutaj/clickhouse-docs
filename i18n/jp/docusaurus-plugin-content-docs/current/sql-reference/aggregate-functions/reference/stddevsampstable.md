---
slug: /sql-reference/aggregate-functions/reference/stddevsampstable
sidebar_position: 191
title: "stddevSampStable"
description: "結果は varSamp の平方根に等しい。この関数は数値的に安定したアルゴリズムを使用している点が異なります。"
---


# stddevSampStable

結果は [varSamp](../../../sql-reference/aggregate-functions/reference/varsamp.md) の平方根に等しい。[`stddevSamp`](../reference/stddevsamp.md) とは異なり、この関数は数値的に安定したアルゴリズムを使用している。処理速度は遅くなるが、計算誤差は低く抑えられる。

**構文**

```sql
stddevSampStable(x)
```

**パラメータ**

- `x`: サンプル分散の平方根を求める値。[(U)Int*](../../data-types/int-uint.md)、[Float*](../../data-types/float.md)、[Decimal*](../../data-types/decimal.md)。

**返される値**

`x` のサンプル分散の平方根。[Float64](../../data-types/float.md)。

**例**

クエリ:

```sql
DROP TABLE IF EXISTS test_data;
CREATE TABLE test_data
(
    population UInt8,
)
ENGINE = Log;

INSERT INTO test_data VALUES (3),(3),(3),(4),(4),(5),(5),(7),(11),(15);

SELECT
    stddevSampStable(population)
FROM test_data;
```

結果:

```response
┌─stddevSampStable(population)─┐
│                            4 │
└──────────────────────────────┘
```
