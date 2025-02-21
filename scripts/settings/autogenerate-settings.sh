#!/usr/bin/env bash

if ! command -v bash &> /dev/null; then
    echo "Error: bash not found!"
    exit 1
fi

# always run "yarn copy-clickhouse-repo-docs" before invoking this script
# otherwise it will fail not being able to find the files it needs which
# are copied to scripts/tmp and configured in package.json -> "autogen_settings_needed_files"

set -x

if command -v curl >/dev/null 2>&1; then
  echo "curl is installed"
else
  echo "curl is NOT installed"
  exit 1
fi


target_dir=$(dirname "$(dirname "$(realpath "$0")")")
SCRIPT_NAME=$(basename "$0")
tmp_dir="$target_dir/tmp"

mkdir -p "$tmp_dir" || exit 1
cd "$tmp_dir" || exit 1

script_url="https://clickhouse.com/"  # URL of the installation script
script_filename="clickhouse" # Choose a descriptive name
script_path="$tmp_dir/$script_filename"

# Install ClickHouse
if [ ! -f "$script_path" ]; then
  echo -e "[$SCRIPT_NAME] Installing ClickHouse binary\n"
  curl https://clickhouse.com/ | sh
fi

if [[ ! -f "$script_path" ]]; then
  echo "Error: File not found after curl download!"
  exit 1
fi

echo "Downloaded to: $script_path"
echo "[$SCRIPT_NAME] Auto-generating settings"

# Autogenerate Format settings
chmod +x "$script_path" || { echo "Error: Failed to set execute permission"; exit 1; }

root=$(dirname "$(dirname "$(realpath "$tmp_dir")")")

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
slug: /operations/settings/formats
toc_max_heading_level: 2
---

import ExperimentalBadge from \'@theme/badges/ExperimentalBadge\';
import BetaBadge from \'@theme/badges/BetaBadge\';

<!-- Autogenerated -->
These settings are autogenerated from [source](https://github.com/ClickHouse/ClickHouse/blob/master/src/Core/FormatFactorySettings.h).

' AS prefix
SELECT prefix || (SELECT groupConcat(*) FROM main_content)
INTO OUTFILE 'settings-formats.md' TRUNCATE FORMAT LineAsString
" || { echo "Failed to Autogenerate Format settings"; exit 1; }

# Autogenerate settings
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
    SELECT format('## {} {}\\n{}\\n{}\\n\\nType: {}\\n\\nDefault value: {}\\n\\n{}\\n\\n',
                  name, '{#'||name||'}', multiIf(tier == 'Experimental', '<ExperimentalBadge/>', tier == 'Beta', '<BetaBadge/>', ''), if(description LIKE '%Only has an effect in ClickHouse Cloud%', '\\n<CloudAvailableBadge/>', ''), type, default, replaceOne(trim(BOTH '\\n' FROM description), ' and [MaterializedMySQL](../../engines/database-engines/materialized-mysql.md)',''))
    FROM system.settings WHERE name IN settings_from_cpp
    ORDER BY name
),
'---
title: Session Settings
sidebar_label: Session Settings
slug: /operations/settings/settings
toc_max_heading_level: 2
---

import ExperimentalBadge from \'@theme/badges/ExperimentalBadge\';
import BetaBadge from \'@theme/badges/BetaBadge\';
import CloudAvailableBadge from \'@theme/badges/CloudAvailableBadge\';

<!-- Autogenerated -->
All below settings are also available in table [system.settings](/docs/operations/system-tables/settings). These settings are autogenerated from [source](https://github.com/ClickHouse/ClickHouse/blob/master/src/Core/Settings.cpp).

' AS prefix
SELECT prefix || (SELECT groupConcat(*) FROM main_content)
INTO OUTFILE 'settings.md' TRUNCATE FORMAT LineAsString
" || { echo "Failed to Autogenerate Core settings"; exit 1; }

mv settings-formats.md "$root/docs/operations/settings" || { echo "Failed to move generated settings-format.md"; exit 1; }
mv settings.md "$root/docs/operations/settings" || { echo "Failed to move generated settings.md"; exit 1; }

echo "[$SCRIPT_NAME] Auto-generation of settings markdown pages completed successfully"

# perform cleanup
rm -rf "$tmp_dir"/settings-formats.md
rm -rf "$tmp_dir"/settings.md
rm -rf "$tmp_dir"/FormatFactorySettings.h
rm -rf "$tmp_dir"/Settings.cpp

echo "[$SCRIPT_NAME] Autogenerating settings completed"

