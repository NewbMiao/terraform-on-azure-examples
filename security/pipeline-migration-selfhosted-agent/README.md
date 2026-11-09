# pipeline-migration-selfhosted-agent

Runnable Terraform example: a self-hosted ADO agent setup on dev — agent subnet, elastic pool, and paired NSG rules between the agent subnet and the `pe_db` subnet.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | relay dev address ranges (ADO `/28`, `pe_db` `/27`, ACA relay `/26`) |
| `ado_pool.tf` | Linux VMSS + `azuredevops_elastic_pool` |
| `ado_nsg.tf` | Agent egress to Azure DevOps / NAT / `5432` toward `db_destination_prefixes` |
| `pe_db_nsg.tf` | `pe_db_inbound_db_sources` expands inbound `5432` |
| `locals.tf` | `pipeline_db_path_ready` and `pairing_gaps` (paired-prefix self-checks) |
| `outputs.tf` | `ado_elastic_pool_name`, `ado_outbound_db`, `pairing_gaps` |

## Try

Edit only one side — remove the `ado_dev` row from `pe_db_inbound_db_sources` or change `db_destination_prefixes` in `case.auto.tfvars`, then `terraform plan` and watch `pipeline_db_path_ready` and `pairing_gaps`.
