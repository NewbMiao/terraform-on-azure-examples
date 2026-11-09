# aca-domain-certificate-binding

Runnable Terraform example: an ACA environment with a managed certificate and custom domain, wired so removing the binding shows a clean destroy in plan.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | The `aca.custom_domain` block, enabled by default |
| `aca_env.tf` | `count` + `local.aca_custom_domain_enabled` gating the certificate and domain blocks |
| `outputs.tf` | `certificate` / `domain`, set only while the binding is enabled |

## Try

Comment out the whole `custom_domain = { … }` block in `case.auto.tfvars`, run `terraform plan` again — it should plan to destroy the certificate and the custom domain.
