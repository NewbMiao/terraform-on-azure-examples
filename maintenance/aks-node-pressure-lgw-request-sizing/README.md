# aks-node-pressure-lgw-request-sizing

Runnable Terraform example: a Monitor workbook that ranks AKS deployments by request-vs-usage gap, driven by a KQL file kept next to the Terraform.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `rank.kql` | The ranking query; the `datatable` two-row stub stands in for the `KubePodInventory` + `Perf` join (CPU P90, daily-peak memory P90) |
| `variables.tf` + `case.auto.tfvars` | Which Log Analytics workspace the workbook binds, plus cluster/namespace pill defaults |
| `locals.tf` | `file(rank.kql)` into the workbook `data_json` (intro, parameter bar, ranking table) |
| `workbook.tf` | Plays `azurerm_application_insights_workbook`; plan shows only the `data_json` shape |
| `outputs.tf` | `workbook_item_count` (expect 3) and `workbook_kql_titles` (expect `Deployments — req → Sug`) |
