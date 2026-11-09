# aca-size-update

Runnable Terraform example: a Container App where the pipeline owns image/env/secrets and Terraform updates only size and volume mounts — sizing changes replace the template, live fields stay untouched.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally. Names mirror a real `aca_app` setup: `var.live` stands in for `data.azapi_resource.live`, and `terraform_data.template` + `ignore_changes = [input]` stands in for `azapi_resource_action.template` + `ignore_changes = [body]`.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | The `live` shape, size inputs, and `volume_mounts` |
| `variables.tf` | `template_cpu` / `template_memory` / replica bounds / `volume_mounts` |
| `main.tf` | Fingerprint locals, `revision_suffix`, the sizing/template resources |
| `modules/aca/` | The reusable ACA module |

## Try

- Change `live.image` → `terraform_data.template` shows **No changes**.
- Change `max_replicas` → **replace** `template`; the new body is current live ⊕ new size, only `cpu`/`memory` change under `resources`.
- Change `volume_mounts` → the fingerprint changes, triggering the same replace with `volumes` / `volumeMounts` updated together.
