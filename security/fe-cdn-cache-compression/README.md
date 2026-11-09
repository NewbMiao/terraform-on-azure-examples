# fe-cdn-cache-compression

Runnable Terraform example: Front Door origins with two route classes — pages without cache, static assets with cache and compression — and a per-route exception list.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | `edge.origin_compress = false`, the `no_compress_patterns` exceptions; three apps — `relay` (Next), `pulse` (Vite), `harbor` (no static assets) |
| `variables.tf` | `cached` uses `optional(..., {})`, so `harbor` passes without the block |
| `locals.tf` | `front_door_compresses` decides who compresses; `static_routes` expands cache keys, TTLs, content hashes; exceptions force `compression_enabled` back to `false` |
| `cdn.tf` | Page routes with `cache = null`; static routes carry `compression_enabled` |
| `outputs.tf` | `routes` contrasts the two classes; `compression_exceptions` should list only `/legacy/download/*` |

## Try

- Set `edge.origin_compress = true` → `compression_owner` becomes `origin` and every static route's `compression_enabled` flips to `false`.
- Change `relay.cached.next_static.pattern` to `/*` → `overlapping_patterns` flags `relay` for ambiguous match order.
