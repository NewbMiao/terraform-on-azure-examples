# tftest-waf-allow-pulse

terraform test example: two pulse Allow rules, one shared `pulse-stack/terraform.auto.tfvars`.

| Rule | `regression_gate` | Who checks the URI table |
|------|-------------------|--------------------------|
| `AllowPulsePath` | `check` | `validations.tf` → every **plan** |
| `AllowPulseHookPath` | `test` | `path_regression.tftest.hcl` → **`terraform test`** |

## Files

| File | Contents |
|------|----------|
| `pulse-stack/terraform.auto.tfvars` | Two `custom_rules` blocks plus `path_regression` |
| `pulse-stack/locals.tf` | Test patterns merged into per-gate URI failure lists |
| `pulse-stack/validations.tf` | The `check` consuming the failure list, warning at plan time |
| `pulse-stack/path_regression.tftest.hcl` | Happy-path regression plus a narrowed-pattern self-test |
| `pulse-stack/outputs.tf` | Current failure lists per rule; empty means every sample behaves |

## Run

```bash
cd pulse-stack
terraform init
terraform plan
terraform test
```
