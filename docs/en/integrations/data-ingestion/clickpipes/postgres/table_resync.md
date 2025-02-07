---
title: Resyncing Specific Tables
description: Resyncing specific tables in a Postgres ClickPipe
slug: /en/integrations/clickpipes/postgres/table_resync
---

# Resyncing specific tables

There are scenarios where it would be useful to have specific tables of a pipe be re-synced. Some sample use-cases could be major schema changes on Postgres, or maybe some data re-modelling on the ClickHouse.

While resyncing individual tables with a button click is a work-in-progress, this guide will share steps on how you can achieve this today in the Postgres ClickPipe.

### 1. Remove the table from the pipe

This can be followed by following the [table removal guide](./removing_tables).

### 2. Truncate or drop the table on ClickHouse

This step is to avoid data duplication when we add this table again in the next step. You can do this by heading over to the **SQL Console** tab in ClickHouse Cloud and running a query.
Note that since PeerDB creates ReplacingMergeTree tables by default, if your table is small enough where temporary duplicates is harmless, this step can be skipped.

### 3. Add the table to the ClickPipe again
This can be followed by following the [table addition guide](./add_table).
