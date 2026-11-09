# checkov-workflow

Checkov example: the skip list registers only CKVs that genuinely Fail in this directory — everything else must keep failing loudly.

## Run

```bash
checkov --config-file .checkov.yaml
```

## Files

| File | Contents |
|------|----------|
| `.checkov.yaml` | Four targeted skips, each with a comment |
| `demo-stack/relay_storage.tf` | No skips — public network/TLS checks still fail |
| `demo-stack/harbor_kv.tf` · `harbor_kv_secret.tf` | The hits for `CKV_AZURE_189` / `42` / `41` |
| `demo-stack/harbor_blob.tf` | Team-level Blob; `CKV_AZURE_33` is held down by the skip |

## Skip ↔ file (only entries that actually hit)

| Kind | CKV | File |
|------|-----|------|
| Deferred | `CKV_AZURE_189` | `harbor_kv.tf` |
| Intentional | `CKV_AZURE_42` | `harbor_kv.tf` |
| Intentional | `CKV_AZURE_41` | `harbor_kv_secret.tf` |
| Deferred | `CKV_AZURE_33` | `harbor_blob.tf` (all Storage in the directory) |

**Should still fail (not skipped):** `59` / `44` / `190` on `relay_storage.tf`; `109` / `110` on `harbor_kv.tf`.

`Skipped checks: 0` in the summary is normal: a configured skip means the CKV never runs, so it isn't counted as skipped.
