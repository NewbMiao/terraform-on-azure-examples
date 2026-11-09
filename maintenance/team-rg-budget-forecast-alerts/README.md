# team-rg-budget-forecast-alerts

Runnable Terraform example: a `resource_groups` sheet → locals compute budget caps → three notifications per RG row, plus one subscription-level Cost Anomaly Alert per environment subscription.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | Subscription IDs, `anomaly_label`, `cloudops_emails`, and per-RG `baseline_monthly` |
| `variables.tf` | Input shapes |
| `locals.tf` | The `buffer_percent` rounding rule and the three notification templates |
| `action_group.tf` | The cloudops Action Group stand-in (used by RG budgets) |
| `budgets.tf` | `for_each` budgets and their notification lists |
| `subscription_anomaly.tf` | Subscription-level anomaly alert (`count` tied to the RG table being non-empty) |
| `outputs.tf` | `budget_amounts`, `relay_dev_notifications`, `subscription_anomaly_alert` |
