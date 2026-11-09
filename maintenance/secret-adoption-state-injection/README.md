# secret-adoption-state-injection

Runnable Terraform example: adopting existing secrets into Terraform state — a PG admin password via `random_password` import, an Entra client secret via state injection — with KV copies that point at the sources instead of holding duplicate values.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | The `key_vault_secrets` sheet and adoption inputs |
| `variables.tf` | Input shapes |
| `pg_admin_password.tf` | `random_password.admin`, used as-is; `length` matches the real one |
| `pg_server.tf` | `administrator_password_wo` / `_wo_version` fields — the password ships only when the version bumps |
| `entra_password.tf` | `local.adopted_password` for the `azuread_application_password` state instance (no import support, injection only) |
| `kv_secret.tf` | `azurerm_key_vault_secret` `for_each` keyed off `key_vault_secrets` |
| `outputs.tf` | Password version, credential metadata (no plaintext), and per-copy expiry |

The adoption step itself isn't run here: in a real environment you `terraform import random_password.admin '<password>'`, align `length`, get a clean plan, then start rotating.

## Try

- Change `length` in `pg_admin_password.tf` to `20` and plan: `random_password` rebuilds, the two `pg` copies get new hashes, the server stays put — the version didn't bump.
- Set `client_secret` to an empty string: the precondition stops the plan.
- Add a KV: one more row in `key_vault_secrets`; `source` decides which source it follows.
