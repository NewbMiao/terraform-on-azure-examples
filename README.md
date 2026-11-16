# terraform-on-azure-examples

Companion examples for [*Terraform on Azure — Platform Governance in Practice*](https://leanpub.com/terraform-on-azure). No Azure subscription needed (`terraform_data` + locals).

```bash
cd <permissions|security|maintenance|tooling>/<case>/
terraform init && terraform plan
```

| Directory | Topic |
|-----------|--------|
| `permissions/` | Identity and access |
| `security/` | Network and edge |
| `maintenance/` | Ops, monitoring, cost |
| `tooling/` | fmt, lint, scan, pre-commit demos |

Optional: `pre-commit install` at repo root (fmt/validate/tflint). Full gate demo → `tooling/pre-commit-iac-gates/README.md`.