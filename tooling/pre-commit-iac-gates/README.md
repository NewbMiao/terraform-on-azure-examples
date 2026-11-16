# pre-commit-iac-gates

Local gate example, split into two tiers:

| Git stage | Checks |
|-----------|--------|
| `pre-commit` | fmt, validate, TFLint, terraform-docs, `terraform test`, `tfpolicy test` (via `../tfpolicy-mock-guards/`) |
| `pre-push` | Checkov, Infracost previous → current diff |

## Files

| File | Contents |
|------|----------|
| `.pre-commit-config.yaml` | Two hook tiers; local `terraform_test`, inline `tfpolicy`, and `infracost_diff` |
| `demo-stack/terraform.auto.tfvars` | relay / pulse workloads |
| `demo-stack/locals.tf` | Platform tags merged, then handed to downstream resources |
| `demo-stack/workloads.tf` | Container Apps played by `terraform_data` |
| `demo-stack/workload_contract.tftest.hcl` | Checks environment, replicas, and platform tags |
| `infracost.yml` | Infracost project entry, shared with the pre-push hook |
| `hooks/infracost-diff.sh` | Resolves the lesson root, saves the last scan, then produces current + diff |
| `.gitignore` | Ignores the locally generated `.reports/` |

## Verify Terraform first

```bash
cd demo-stack
terraform init
terraform fmt
terraform plan
terraform test
```

## Install Git hooks

From this directory in the **examples repository** (published path `tooling/pre-commit-iac-gates/`):

```bash
pre-commit clean
pre-commit install --config .pre-commit-config.yaml --install-hooks -t pre-commit -t pre-push --overwrite
pre-commit run --config .pre-commit-config.yaml terraform_test
pre-commit run --config .pre-commit-config.yaml tfpolicy_test
pre-commit run --config .pre-commit-config.yaml infracost_diff --hook-stage pre-push
```

The first run initializes previous and current from the same scan, so the diff is zero. From the second run on, the hook keeps the last result and writes three files:

```text
.reports/infracost-previous.json
.reports/infracost-current.json
.reports/infracost-diff.txt
```

Both local hooks set `verbose: true`: `terraform_test` shows test output even on success; `infracost_diff` shows the cost summary and saves the same content to `.reports/infracost-diff.txt`. `.reports/` is gitignored and safe to keep around. Here "previous" means **the last successful scan on this machine**, not a remote branch. Infracost needs local authentication. This provider-free stack demonstrates **when a cost estimate triggers**; a real monthly-cost project should point `infracost.yml` at Terraform roots containing supported cloud resources. Local and CI should read the same project list.

<!-- BEGIN_TF_DOCS -->

<!-- END_TF_DOCS -->
