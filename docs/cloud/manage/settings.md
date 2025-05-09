---
sidebar_label: Configuring Settings
slug: /manage/settings
---

import cloud_settings_sidebar from '@site/static/images/cloud/manage/cloud-settings-sidebar.png';

# Configuring Settings

To specify settings for your ClickHouse Cloud service for a specific [user](/operations/access-rights#user-account-management) or [role](/operations/access-rights#role-management), you must use [SQL-driven Settings Profiles](/operations/access-rights#settings-profiles-management). Applying Settings Profiles ensures that the settings you configure persist, even when your services stop, idle, and upgrade. To learn more about Settings Profiles, please see [this page](/operations/settings/settings-profiles.md).

Please note that XML-based Settings Profiles and [configuration files](/operations/configuration-files.md) are currently not supported for ClickHouse Cloud.

To learn more about the settings you can specify for your ClickHouse Cloud service, please see all possible settings by category in [our docs](/operations/settings).

<img src={cloud_settings_sidebar} class="image" style={{width: 300, float: "left"}} />
