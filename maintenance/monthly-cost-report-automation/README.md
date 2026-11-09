# monthly-cost-report-automation

Runnable Terraform example: an Azure Automation monthly cost report — config sheet → flattened RG scopes → variables, runbook, monthly schedule, cross-subscription read RBAC, and Graph email.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | `resource_groups`, `schedule`, `email` |
| `locals.tf` | `workload_scopes`, `schedule_start_time`, `report_config_json` |
| `automation_account.tf` | The account with a system-assigned managed identity |
| `cost_reader_rbac.tf` | `Cost Management Reader` across subscriptions |
| `runbook.tf` | Runbook and report-scope variables |
| `schedule.tf` | The 1st-of-month schedule and job-schedule binding |
| `email.tf` | Sender/recipient variables and `Mail.Send` |
| `outputs.tf` | `schedule_anchor`, `workload_scope_count` |
