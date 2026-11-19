# Checkov: From “It Runs” to “It's Compliant”

## Background

relay needed another **Storage Account** for log storage in the EG environment. The change added only a few lines of `azurerm_storage_account`. dev had run `terraform validate` and `plan` locally; both passed, and the diff showed only an ordinary tier and replication change. The team was ready to merge.

---

The merge pipeline failed at **IaC security scanning**. This was not a Terraform syntax error. A string of identifiers beginning with `CKV_AZURE_` all pointed to the same resource and `.tf` line numbers: nested objects allowed public access, and the **TLS** version was below the baseline. None of those words appeared in the plan.

---

relay's developer stared at the log. "If the HCL is wrong, shouldn't validate or plan have failed?"

Dee placed the change beside the scan report. Every failure landed in the new `.tf` file; no old configuration had suddenly become invalid. To pass the gate, the resource definition had to change at those lines.

The developer had never run this scan on a laptop. At the bottom of the report, they asked: "What are these CKV numbers, and how are they different from validate?"

## Checkov and CKV

The pipeline was running **Checkov**. It treats `**.tf` files — and some other registered IaC such as **YAML** — as descriptions of the shape that will reach production. Without connecting to a subscription or running `apply`, it checks each section against built-in rules: could this Storage expose a public path by default? Does a **Key Vault** lack a firm network boundary? Is **TLS** below the team baseline? Are diagnostics and soft-delete retention missing from the HCL?

Every failed line carries a **CKV** identifier: a short label for the security or quality rule that was not met. The same `CKV_AZURE_59` means the same thing in different changes, so a ticket, a review, and a code fix can refer to one rule. The questions are consistent: is the exposure too broad, is encryption or transport too weak, is observability missing, or are retention and recovery below the baseline? If this HCL were applied tomorrow, would Azure produce a configuration nobody wanted to own?

That is the boundary between Checkov and **validate** / plan. Validate and plan answer whether the configuration is well-formed and whether a plan can be produced. Azure still accepts many legal but risky combinations, and a plan usually shows a tier or location change rather than highlighting "publicly reachable." relay's Storage was schema-valid and plan-valid, but failed CKV.

Checkov moves that gap to the merge boundary. Fixing a few HCL lines in Git costs less than closing a public resource, changing TLS, or adding audit logs after deployment.

Dee added one practical detail: local runs must use the same `**.checkov.yaml**` as CI:

```bash
checkov --config-file .checkov.yaml
```

Use the same directory and rule set, then fix the `.tf` line named by each CKV result. A green local scan makes the pipeline repeat a check already done, instead of making CI the first place to reveal the intended risk.

## Comparison

| | validate / plan | Checkov (**CKV**) |
|--|----------------|-------------------|
| relay's change | green | Failed (public access, TLS, and so on) |
| before merge | unchanged | `checkov --config-file .checkov.yaml` |

## Approach

1. Run `checkov --config-file .checkov.yaml` from the IaC repository root and trace each Failed result to its `.tf` line.
2. Fix the HCL: exposure, TLS, diagnostics, retention, and other findings belong in Terraform.
3. Run the scan locally before pushing.
4. Optionally keep a machine-readable report:

   ```bash
   checkov --config-file .checkov.yaml --output json --quiet
   ```

`skip-check` in the central configuration is for a small number of reviewed exceptions. The normal path is to fix a Failed result in code. The example README also shows a skip comparison.

## Example & verification

| Directory | What it's for |
|-----------|----------------|
| [`tooling/checkov-workflow/`](https://github.com/NewbMiao/terraform-on-azure-examples/tree/main/tooling/checkov-workflow/) | `relay_storage.tf` reproduces the Storage finding from the story; the reading order is in its `README.md` |

```bash
checkov --config-file tooling/checkov-workflow/.checkov.yaml
```

## Takeaway

relay's HCL ran and its plan was green, yet the scan still found CKV failures. Once Checkov and validate have clear jobs, the local `checkov --config-file` run lines up with the merge gate and closes the gap while the `.tf` is still being changed. The next lesson puts the same discipline around naming rules.
