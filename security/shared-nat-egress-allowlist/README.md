# shared-nat-egress-allowlist

Runnable Terraform example: platform NAT Gateway subnet attachments plus a third-party egress allowlist registry. Scope: ACA `subnet_keys` (crest registered) and the `ado_agent` self-hosted agent subnet.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally. All IDs, `RG-EG-*` names, and subnets are fictional; the PIP outputs use RFC 5737 `198.51.100.*`.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | NAT gateway entries and the allowlist registry |
| `variables.tf` | Input shapes |
| `locals.tf` | Shared expansions |
| `shared_nat.tf` | NAT Gateway subnet attachments |
| `allowlist.tf` | Third-party egress allowlist entries |
| `outputs.tf` | Attachment and allowlist shapes |

## Try

Attach the same subnet ID in two `shared_nat_gateways` entries — the precondition reports the double attachment.
