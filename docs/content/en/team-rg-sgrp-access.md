# Where the story begins: the shared account

## Background

On Tuesday afternoon, the dev application of the **relay** business team went down.

The app was timing out on its database connection. A round of container restarts changed nothing. Someone checked the database: it was running, and no firewall had changed. The private path was broken — the database's **Private Endpoint** (a private network endpoint) had been modified the night before, and **private DNS** no longer matched the current **PE**.

---

Dee from the platform team opened the **Activity Log** (the operations audit log).

There was exactly one operator: `shared-deploy@example.com`. No individual **UPN** (user login name) — just the shared account's mailbox.

---

Later, a relay developer owned up to it: the team had been doing **PE migration config** the night before, using that account; at the time it seemed it **wouldn't affect the running dev environment**, so they wrapped up and left. The impact arrived anyway, and the log still said only `shared-deploy@example.com`.

---

During the postmortem, an older problem resurfaced.

---

Back when headcount was small and the platform team was swamped, a packed schedule meant the business teams dreaded every trip to the "grant permission" door.

---

So everyone asked for an emergency **shared account**, and the platform handed out a big one: **Contributor** (a built-in role) on the **Subscription**. For resources in both the **dev** and **prod** subscriptions, this one key could reach just about everything — swap **PE**s, touch the network, delete things, create things. Most of it landed on that single mailbox.

---

People didn't run releases with it — the **pipeline** used a **service connection** — but the thing at the other end of the wire was still subscription-level **Contributor**, just as wide.

---

With three to five people, a shout in the group chat kept everyone aware of who touched what; once **pulse** and **harbor** joined, the unspoken mutual awareness stopped scaling. Nobody could keep track of who touched whose piece.

---

The log couldn't say who, yet the account could move a very large surface — dev and prod simmering in one pot.

Dee, still staring at the log, dropped the line: "We can't let `shared-deploy@example.com` keep signing for everyone forever."

---

## Comparison: why one account can't carry accountability

Back then, to keep developers unblocked by platform scheduling, the platform had given `shared-deploy@example.com` a key covering the whole Subscription. It could swap PEs, delete storage, and operate across dev and prod alike; when something broke, the Activity Log could only point at the key — it could not answer "which member of which team made this change."

```hcl
data "azuread_service_principal" "shared_deploy" {
  display_name = "shared-deploy" # corresponds to shared-deploy@example.com
}

data "azurerm_subscription" "dev" {
  subscription_id = var.dev_subscription_id
}

resource "azurerm_role_assignment" "shared_deploy_dev_subscription" {
  scope                = data.azurerm_subscription.dev.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_service_principal.shared_deploy.object_id
}
```

The **scope** sat on the entire **Subscription**; one **principal** covered several teams and both **dev** and **prod** — the log can only ever point at "that one key." There's the root of it.

---

The fix is not another shared account. Resources are first grouped into each team's **RG** by team and environment, and permissions follow that edge; people join their own **SGRP**s and only touch what lives inside their own **Resource Group**.

## Comparison: let each team own its resources

The platform moved relay's ACA, database, and storage into **relay**'s **RG**, and pulse's resources into **pulse**'s **RG**. The permissions developers need narrow down by resource type and environment; when no built-in role fits a capability, grant just that single resource. Which team owns which slice of resources now stands on Azure's own resource boundary.

Permissions are also granted **per team**: the platform binds **RBAC** to the team **SGRP** (a security group in Entra), not to individuals. People follow the group. Joins and departures only touch the group roster; each team manages its own **RG**, and nobody chases per-person changes anymore. Only then does the **Activity Log** get a chance to land on a specific person, a specific resource, and a specific team.

**dev** and **prod** each get one `dev_resource_groups` / `prod_resource_groups` table, nested under `teams.<team>`. Filled out for **relay**, it looks like this:

```hcl
teams = {
  relay = {
    members = ["owen.relay@example.com"]   # mirrors SGRP-RELAY membership; join multiple SGRPs if on multiple teams
    dev_resource_groups = {
      relay_dev = {
        subscription_key    = "dev"
        resource_group_name = "RG-RELAY-DEV-SEA"
        roles               = ["Container Apps Contributor", "Key Vault Secrets Officer"]
      }
    }
    prod_resource_groups = {
      relay_prd = {
        subscription_key    = "prod"
        resource_group_name = "RG-RELAY-PRD-SEA"
        roles               = ["Container Apps Operator", "Storage Blob Data Reader"]
      }
    }
  }
}
```

The shared **ACR** stays out of `teams`, in its own `shared_resource_access` table — one ACR, each granted team listed separately:

```hcl
shared_resource_access = {
  org_acr = {
    subscription_key    = "prod"
    resource_group_name = "RG-EG-HUB-INF"
    resource_name       = "acreg"
    resource_type       = "Microsoft.ContainerRegistry/registries"
    team_grants = {
      relay = { roles = ["Reader"] }
      pulse = { roles = ["Reader"] }
    }
  }
}
```

Every row in the tables expands into one role assignment, leaving only the team's identity at the resource boundary — the shared account no longer sits there:

```hcl
resource "azurerm_role_assignment" "relay_sgrp_dev_aca" {
  scope                = azurerm_resource_group.relay_dev_sea.id
  role_definition_name = "Container Apps Contributor"
  principal_id         = data.azuread_group.sgrp_relay.object_id
}
```

## Preparation

**Who does the prep**: for each team, assemble a "people + SGRP + RG + resources + rough permissions" sheet. It's good enough if it survives a walkthrough in a meeting or a doc.

| Step | What to do |
| ---- | ---------- |
| **Inventory** | List per team: **who** (member UPNs), **which resources** they occupy (ACA, PG, KV…), and which **RG** / Subscription they land in; mark mixed or misassigned ones **to-migrate** |
| **Team SGRP** | **Create** one Entra **SGRP** per team (e.g. `SGRP-RELAY`) — one group per team; `azuread_group` via Terraform also works |
| **Team members** | **Bind member UPNs** into the matching SGRP (going forward, `teams.<team>.members` mirrors this); people on multiple teams join multiple SGRPs — don't merge into one big group |
| **Team RGs** | Fix one team RG name per **dev / prod**; **create if missing** (e.g. `RG-<TEAM>-DEV-SEA` / `RG-<TEAM>-PRD-SEA`). At this stage only confirm boundaries and naming; resources sitting in mixed RGs stay on the sheet's **to-migrate** list |
| **Rough permissions** | Filter the **Activity Log** for `shared-deploy@example.com`: the shared-account era's write operations per **resourceId**, attributed to the right team / resource type, so no team or type is missed; then draft built-in roles per **dev / prod** (e.g. dev ACA **Contributor**, prod ACA **Operator**); capabilities without a fitting built-in role are marked **single-resource** + role name. A **rough list** is enough for now |

relay's inventory, as an example:

| team  | SGRP         | dev RG                                | prod RG                               | Resource summary     | dev rough roles                    | prod rough roles                              |
| ----- | ------------ | ------------------------------------- | ------------------------------------- | -------------------- | ---------------------------------- | --------------------------------------------- |
| relay | `SGRP-RELAY` | `RG-RELAY-DEV-SEA` · `SUB-EG-APP-DEV` | `RG-RELAY-PRD-SEA` · `SUB-EG-APP-PRD` | ACA, PG, KV, Storage | ACA Contributor, PG @ server…      | ACA Operator; no human read/write on prod KV secrets… |

`subscription_key` is simply `dev` / `prod`; the platform's subscription table resolves the **subscription ID**.

## Approach

**1. Move resources into the team RGs by environment**
Following the inventory's **to-migrate** column, move ACA, databases, storage, and the like into the team's **dev** or **prod** RG. Only after the move does **scope** match the RBAC tables.

**2. Write the sheet into the configuration**
Cross-check the "rough permissions" against the **Activity Log**, then fill `teams.<team>` per team: `members`, plus **dev** / **prod** `dev_resource_groups` / `prod_resource_groups`; inventory rows marked "single-resource" go into `resource_access`; the shared **ACR** goes into `shared_resource_access`. A person on two teams → two `members` entries, permissions unioned.

**3. Tighten the shared ACR one more notch**
Several teams share one **ACR**; read access via `shared_resource_access` is enough. If pull/push must also be separated by repository prefix (e.g. `relay/…`, `pulse/…`), pick one path and stay on it: either an **ABAC** condition on the team identity, or **scope tokens**. Condition/token details live in the example directory's `README.md`.

relay's final table (`dev_resource_groups` / `prod_resource_groups`):

| Type          | dev                         | prod                              | Notes |
| ------------- | --------------------------- | --------------------------------- | ----- |
| **ACA apps**  | Container Apps Contributor  | Container Apps Operator           | dev: free to tweak revisions and troubleshoot; **prod** releases go through the **pipeline** (the service connection uses a deployment identity), so team members don't need standing **Contributor**/**Container Apps Contributor** — **Operator** covers status checks and limited operations |
| **Key Vault** | Key Vault Secrets Officer, etc. | Usually no human read/write on **prod secrets** | Daily development shouldn't touch production secrets; one-off initialization is handled by the platform team |
| **Storage**   | Storage Account Contributor | Storage Blob Data Reader          | prod data plane is commonly read-only; blob writes go to the **pipeline** or a backend identity |

## Example & verification

| Directory                                | What it's for |
| ---------------------------------------- | ------------- |
| [`permissions/team-permissions/`](https://github.com/NewbMiao/terraform-on-azure-examples/tree/main/permissions/team-permissions/) | Three teams' `teams`, relay's single-resource grant, and the shared **ACR** with optional **scope tokens**; one **provider** alias per `dev` / `prod`, consistent with the "one provider set per subscription" mental model on the permissions side. See that directory's `README.md` |

```bash
cd permissions/team-permissions
terraform init
terraform plan
```

Read the `terraform plan` diff: do the **SGRP**s, per-team **RG**s, and role names line up? On the **prod** side of the table, it should still be **Operator**-class — the whole subscription must not get painted **Contributor** again.

## Quiz

Why bind RBAC to the **SGRP** instead of assigning roles to members directly on the **RG**? When a team is just two or three people, isn't the group ceremony overkill?

## Takeaway

That round of **PE** changes left one fear hanging over relay: what if it turns red again in **prod** — the first sentence in the meeting room would still be "who did it," and the answer can't be a single mailbox.

After the change, the **Activity Log** can at least trace back to the team and the person: people move through **SGRP**s, things land in each team's own **RG**, **dev** and **prod** mind their own business — no more one key taking the blame for the whole crew.

But keep this in mind: a **Contributor** grant is still hanging on the subscription, and asking "who" still goes in circles — don't grant more than the few RGs each team is actually willing to own.
