# waf-aca-private-origin

Runnable Terraform example: an org Front Door custom domain, a `private_link` origin, and a route — the public hostname is owned at the edge, ACA only supplies the origin hostname.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | `waf.public_hostname` and `aca.origin_hostname` kept separate |
| `variables.tf` | Input shapes |
| `main.tf` | Shared locals and the edge wiring |
| `waf.tf` | `waf_aca_origin` with `private_link = true`; the route binds the edge domain |
| `outputs.tf` | Hostname ownership for review |

Compare with `../aca-domain-certificate-binding/`: the same business hostname should not appear as the long-term owner of both an ACA custom domain and a WAF domain.
