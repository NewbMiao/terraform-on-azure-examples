# aks-overlay-pls-origin

Runnable Terraform example: the internal path from an overlay AKS cluster to an org Front Door — node-subnet NSG egress allowlist, an internal ILB + Private Link Service from Service annotations, and a `private_link` origin.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | Non-overlapping `pod_cidr` and node subnet; `nsg_edges` limited to the database and NAT |
| `aks.tf` | `network_plugin = "azure"` + `overlay`; cluster identity holds Network Contributor on the node VNet |
| `nsg.tf` | Outbound allowlist plus the `AzureLoadBalancer` probe; no deny on `VirtualNetwork` |
| `k8s/` | `ingress-nginx-controller-service.yaml` annotations forming the bridge; `crest-api-ingress.yaml` host matching the edge domain |
| `waf.tf` | Origin `private_link` targeting the PLS name; custom domain and route at the edge |
| `outputs.tf` | `network` and `edge` families for review |
