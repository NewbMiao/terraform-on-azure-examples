# workload-identity-la-graph-roles

Runnable Terraform example: Microsoft Graph app-role assignments on a Logic App's managed identity, with a legacy client-secret path kept for contrast.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | Workloads and their Graph app roles |
| `variables.tf` | Input shapes for workloads, the Graph API catalog, and legacy apps |
| `logic_app.tf` | Plays `azurerm_logic_app_workflow`, with a `SystemAssigned` `principal_id` |
| `locals.tf` | Workload × `graph_roles` expansion |
| `graph_roles.tf` | Plays `azuread_app_role_assignment` |
| `legacy_secret_path.tf` | Optional contrast: the old client-secret path (no secrets in plaintext) |
| `outputs.tf` | Role assignments per workload |
