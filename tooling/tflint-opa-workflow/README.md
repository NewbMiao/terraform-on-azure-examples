# tflint-opa-workflow

TFLint + OPA example (fictional EG / harbor). Acceptance uses TFLint only — no `terraform plan`, no Azure environment. `demo-stack` plays a Resource Group's `name` with `terraform_data`.

## Setup

```bash
export TFLINT_OPA_POLICY_DIR="$PWD/policies"
tflint --init --config=tflint.hcl
```

## 1 — Regular rules + OPA (current demo-stack)

```bash
cd demo-stack && tflint --config=../tflint.hcl
```

Expected: **Warning** `terraform_unused_declarations` (`team_label` in `variables.tf`) plus **Error** `opa_deny_*` (the `input` prefix in `harbor_rg.tf`).

Remove `variables.tf` or the unused variable and scan again — the regular warning goes away; the **RG prefix** still fails.

## 2 — OPA layer

Change `input = "…"` in `harbor_rg.tf` to `RG-EG-HARBOR-SEA-01` and `opa_deny_*` should disappear.

## Policy unit tests

```bash
cd demo-stack && TFLINT_OPA_TEST=1 tflint --config=../tflint.hcl
```
