# subnet-migration-private-dns-lifecycle

Runnable Terraform example: Private Endpoints with a `verify_a_record` gate that checks `private_link_dns` zone A records against the PE's private IPs.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | `stpulseprd_blob` and `relay_pg_dev` record names with `172.*` private IPs |
| `variables.tf` | Input shapes, including `verify_a_record` |
| `storage_pe.tf` | Team-stack `for_each` module inputs (RG / VNet / subnet names) |
| `dns_verify.tf` | `coalesce(dns_a_records, [])` + `contains` checks and the precondition gate |
| `outputs.tf` | `stpulseprd_dns_match` and `storage_pe_verify_enabled` |

## Try

Set `stpulseprd_blob.dns_a_records` to `[]` to reproduce the plan failure after a legacy PE deletion sweeps the A record away.
