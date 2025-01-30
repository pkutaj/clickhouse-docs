#!/bin/bash

# always run "yarn copy-clickhouse-repo-docs" before invoking this script
# otherwise it will fail not being able to find the files it needs which
# are copied to scripts/tmp and configured in package.json -> "autogen_settings_needed_files"

target_dir=$(dirname "$(dirname "$(realpath "$0")")")
file="$target_dir/tmp/clickhouse"
SCRIPT_NAME=$(basename "$0")

echo "[$SCRIPT_NAME] Auto-generating settings"

# Install ClickHouse
touch "$file"
curl -fsSL "https://clickhouse.com/" > "$file"
chmod +x "$file"

cd "$target_dir/tmp" || exit

# Autogenerate Format settings
./clickhouse -q "
WITH
'FormatFactorySettings.h' AS cpp_file,
settings_from_cpp AS
(
    SELECT extract(line, 'DECLARE\\(\\w+, (\\w+),') AS name
    FROM file(cpp_file, LineAsString)
    WHERE match(line, '^\\s*DECLARE\\(')
),
main_content AS
(
    SELECT format('## {} {}\\n{}\\n\\nType: {}\\n\\nDefault value: {}\\n\\n{}\\n\\n',
                  name, '{#'||name||'}', multiIf(tier == 'Experimental', '<ExperimentalBadge/>', tier == 'Beta', '<BetaBadge/>', ''), type, default, trim(BOTH '\\n' FROM description))
    FROM system.settings WHERE name IN settings_from_cpp
    ORDER BY name
),
'---
title: Format Settings
sidebar_label: Format Settings
slug: /en/operations/settings/formats
toc_max_heading_level: 2
---

import ExperimentalBadge from \'@theme/badges/ExperimentalBadge\';
import BetaBadge from \'@theme/badges/BetaBadge\';

<!-- Autogenerated -->
These settings are autogenerated from [source](https://github.com/ClickHouse/ClickHouse/blob/master/src/Core/FormatFactorySettings.h).
' AS prefix
SELECT prefix || (SELECT groupConcat(*) FROM main_content)
INTO OUTFILE '../../docs/en/operations/settings/settings-formats.md' TRUNCATE FORMAT LineAsString
"

# Autogenerate core settings
./clickhouse -q "
WITH
'Settings.cpp' AS cpp_file,
settings_from_cpp AS
(
    SELECT extract(line, 'DECLARE\\(\\w+, (\\w+),') AS name
    FROM file(cpp_file, LineAsString)
    WHERE match(line, '^\\s*DECLARE\\(')
),
main_content AS
(
    SELECT format('## {} {}\\n{}\\n\\nType: {}\\n\\nDefault value: {}\\n\\n{}\\n\\n',
                  name, '{#'||name||'}', multiIf(tier == 'Experimental', '<ExperimentalBadge/>', tier == 'Beta', '<BetaBadge/>', ''), type, default, replaceOne(trim(BOTH '\\n' FROM description), ' and [MaterializedMySQL](../../engines/database-engines/materialized-mysql.md)',''))
    FROM system.settings WHERE name IN settings_from_cpp
    ORDER BY name
),
'---
title: Core Settings
sidebar_label: Core Settings
slug: /en/operations/settings/settings
toc_max_heading_level: 2
---

import ExperimentalBadge from \'@theme/badges/ExperimentalBadge\';
import BetaBadge from \'@theme/badges/BetaBadge\';

<!-- Autogenerated -->
All below settings are also available in table [system.settings](/docs/en/operations/system-tables/settings). These settings are autogenerated from [source](https://github.com/ClickHouse/ClickHouse/blob/master/src/Core/Settings.cpp).
' AS prefix
SELECT prefix || (SELECT groupConcat(*) FROM main_content)
INTO OUTFILE '../../docs/en/operations/settings/settings.md' TRUNCATE FORMAT LineAsString
"

echo "[$SCRIPT_NAME] Auto-generation of settings markdown pages completed"
