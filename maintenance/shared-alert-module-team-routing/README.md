# shared-alert-module-team-routing

Runnable Terraform example: a platform team catalog plus per-team `aca_alerts` tiers — five ACA alert classes and `pg_restart`, each file playing `azurerm_monitor_scheduled_query_rules_alert_v2`.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

Thresholds follow the lesson's presets: prod startup rules use `threshold = 0`, nonprod `app_startup_failure` uses `1`; this case enables `app_memory_high` (90% / 15 min) and `pg_restart` (5 min window) on `relay-prod`, leaving other usage rules and `app_restart` off.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | Rule switches under the two tiers (including `pg_restart`) |
| `log_scope_model.tf` | Three tables, three scopes (system logs by env tag / metrics by RG / PG diagnostics by RG) |
| `alert_queries.tf` | Six KQL classes; `aca_environment_log_names` applies only to the three ACA system-log classes |
| `locals.tf` | Default merging, `aca_alert_catalog_by_tier`, `aca_alert_rule_matrix` |
| `platform_action_groups.tf` | Platform-side action groups |
| `alerts_*.tf` | One file per alert class; `input.query` comes from `alert_queries.tf` |
| `outputs.tf` | `alert_scope_by_data_plane`, `alert_catalog_by_tier`, `enabled_alert_rules` |
