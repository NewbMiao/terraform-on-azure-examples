# aks-ingress-tls-rotation

Runnable Terraform example: cert-manager DNS-01 issuance on AKS with per-environment certificates, DNS child zones, and a scoped issuer identity.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally. Cluster objects (`SecretProviderClass`, `ClusterIssuer`, `Certificate`, `Ingress` / `Gateway`) live as YAML under `k8s/` — the `.tf` files only record the shape; apply the YAML with `kubectl`.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | dev `api-dev.crest.example.com` / prod `api.crest.example.com`, both in the `crest.example.com` child zone; `legacy_kv_csi.enabled = false`, `cert_manager.enabled = true` |
| `locals.tf` | `env_zones` and per-environment certificate/Secret names |
| `dns_zone.tf` | Child zone, parent NS delegation, `DNS Zone Contributor` scoped to the child zone |
| `identity.tf` | Issuer identity and federated credential (`system:serviceaccount:cert-manager:cert-manager`) |
| `cert_manager.tf` | `ClusterIssuer` (DNS-01, selector limited to the child zone) and per-environment `Certificate` |
| `ingress.tf` | One Ingress per environment, `tls.secretName` matching the `Certificate`; a precondition blocks double-writing |
| `k8s/` | YAML by mode: `retired/` (KV + CSI), `cert-manager/`, `ingress.yaml`, `future/gateway-tls-options.yaml` |
| `outputs.tf` | `secret` (per environment), `dns` (delegation and grants), `cert_manager` |
