# infracost-multi-project

Infracost example: `pulse-dev` / `pulse-prod` share `stacks/pulse/`; the autovars are `pg`, `aca`, and `diff` (`diff.enabled` defaults to `false` → worker ACA + Redis).

## Run

```bash
cd stacks/pulse && terraform init
terraform plan -var-file=config/dev/terraform.auto.tfvars

# from this directory (where infracost.yml lives)
infracost scan --json > /tmp/infracost-baseline.json
# change config/dev or config/prod terraform.auto.tfvars
infracost diff --compare-to /tmp/infracost-baseline.json
```

## Sample diffs (measured locally; prices drift)

**dev only** — `diff.enabled = true`, prod untouched:

```text
pulse-dev   +worker +redis(Basic_C0)     +$44  ($254 → $298)
pulse-prod  —                            $0
total +$44
```

**prod scale-up + diff on** (`pg` D4→D8, bigger `aca` replicas/CPU, `diff` on Standard C1; baseline is the pre-scale scan):

```text
pulse-prod  ~api ~pg  +worker +redis     +$1,106  ($568 → $1,674)
pulse-dev   (if diff.enabled too)        +$44
total ≈ +$1,150  ($822 → $1,972)
```

| Exercise | Autovar to change |
|----------|-------------------|
| Small delta, dev only | dev: `diff.enabled = true` |
| Scale-up | `pg.sku`, `aca.*` (prod already runs one tier above dev) |
| Large delta | prod scale-up + `diff.enabled = true` |

In a PR, paste the delta from the **Changed project** table — not the whole-repo total.
