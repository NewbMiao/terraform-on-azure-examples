# tfpolicy-mock-guards

Org `policy.hcl` + `policytest` mocks for storage blob public access (`allow_nested_items_to_be_public`). No Azure credentials; validates with the HashiCorp `tfpolicy` CLI only.

## Install

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/tfpolicy
```

Requires `tfpolicy` on `PATH` (`tfpolicy version`).

## Run

```bash
tfpolicy validate --policies=policies
tfpolicy test --policies=policies --tests=tests
```

Optional: `contrast/module_storage_check.tf` is the lesson’s module `check` pattern — not part of `tfpolicy test`.

## Files

| File | Contents |
|------|----------|
| `policies/storage_no_public_blob.policy.hcl` | `resource_policy` on `azurerm_storage_account` |
| `tests/storage_no_public_blob.policytest.hcl` | `relay_dev_ok` pass · `pulse_legacy_public` `expect_failure` |
| `contrast/module_storage_check.tf` | Module `check` for upgraded callers only |