# shared-vnet-subnet-nsg-edges

Runnable Terraform example: platform subnet roles in shared VNets plus NSG inbound/outbound rule registrations.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | Three keys — `dev_sea_01`, `prod_sea_01`, `prod_ea_01` — matching the lesson's address table |
| `variables.tf` | Input shapes |
| `subnets.tf` | Flat subnets with a `role` (`aca` / `pe_db` / `pe`) |
| `nsg_edges.tf` | ALB inbound, ACA→PE, ACA-to-ACA deny, and the `pe_db` inbound allowlist |
| `outputs.tf` | `deny_vnet_rule_keys` and `dev_sea_relay_to_pe_db` for review |
