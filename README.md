# terraform-on-azure-examples

Runnable Terraform examples for Azure networking, permissions, maintenance, and tooling workflows.

The examples are provider-free: Azure resources are represented by `terraform_data` and locals, so they can be planned without Azure credentials or a subscription.

## Run

Choose an example directory, then run:

```bash
terraform init
terraform plan
```

Each example has its own `README.md` with the file layout and any example-specific command.

## Book

These examples accompany [Terraform on Azure — Platform Governance in Practice](https://leanpub.com/terraform-on-azure).

## Categories

| Directory | Contents |
|-----------|----------|
| `permissions/` | Identity, access, and scope examples |
| `security/` | Network, ingress, DNS, and edge examples |
| `maintenance/` | Operations, monitoring, cost, and lifecycle examples |
| `tooling/` | Terraform quality and workflow tooling examples |
