# pipeline-kv-rg-discover-acl

Runnable Terraform example: discover Key Vaults per resource group and bind access policies, with permission tiers per principal kind and subscription.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | Access scopes keyed by team and RG; no vault names |
| `variables.tf` | Input shapes for scopes, the vault listing stand-in, and team principals |
| `locals.tf` | Vault discovery, filtering, and principal expansion |
| `bindings.tf` | Access-policy bindings for team service connections and SGRPs |
| `outputs.tf` | The expanded bindings, grouped for review |
