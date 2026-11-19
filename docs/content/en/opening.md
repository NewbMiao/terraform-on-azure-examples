# Preface

Most Terraform courses start from a well-defined problem: how to declare a resource, how to organize variables, how to run `plan` and `apply`. In the AI era, syntax lookups and HCL snippets come even faster; standing up a resource from an example is no longer the hard part.

Real operations rarely arrive as a well-bounded problem. A single 403 can come from the app, from identity, from networking, or from the **edge layer** (the public entry tier traffic crosses before reaching your apps, such as Front Door, CDN, and WAF); a clean-looking `plan` can write last month's image back over the one your pipeline just published. You first have to filter noise out of logs, current state, ownership, and change history; converge a messy scene into one verifiable problem; then decide whether Terraform should manage it, at which boundary, and in what order.

AI can help research material, compare approaches, and generate code. It cannot supply the organizational context that never got written down, and it cannot take responsibility for risk, sequencing, and trade-offs. What stays valuable is judgment: which facts matter, which boundary must not be crossed, and how to keep one fix from becoming the next incident. That is the operational thinking this book aims to preserve.

So this book doesn't unfold resource by resource or syntax point by syntax point. It moves forward through real cases: the shared account that leaves only a mailbox in the **Activity Log** (the operations audit log) forces the question of "who can touch what"; once human access is split apart, the pipeline identity and its **Key Vault** boundary come into view; when apps move into private networking, **Private Endpoints**, DNS, and the edge layer have to change together; and once things run steadily, configuration drift, monitoring, cost, and pre-commit gates still remain.

Each layer solved adds one more piece of the Terraform whole: tfvars carry environment differences, locals organize relationships, modules divide responsibility, state guards resource ownership, and `plan` becomes the basis for judging a change before it lands. These are not unrelated topics — they are tools that serve one real change together.

The stories take place at the fictional company **EG**: two subscriptions, **SUB-EG-APP-DEV** and **SUB-EG-APP-PRD**; three application teams — **relay**, **pulse**, **harbor**; and **Dee** from the platform group, who gets @-mentioned constantly. Every lesson starts from an incident or an anomaly: inspect the scene, converge the problem, land the fix in Terraform, and verify through an example. Read cover to cover, what you take away is not a set of fields and resources, but a method for analyzing, deciding, and landing complex operational changes.

## Who works with Dee

| Role | Who they are | What they run into in the stories |
|------|--------------|-----------------------------------|
| **Dee** | Platform engineer, stitches together EG's Terraform and Azure operations | Balances team delivery speed against platform governance; handles problems that cross boundaries and defy ownership |
| **relay** | A team centered on APIs and the data plane | Changes often cross dev, prod, and data boundaries; they need speed without cross-team side effects |
| **pulse** | A team with heavy compute and edge-layer changes | Traffic, capacity, and access patterns keep shifting; the business must not break while they adjust |
| **harbor** | A team with lots of storage and secrets | Data and sensitive values must be shared, while least privilege and accountability stay intact |

## Who this book is for

- **Developers**: you write some Terraform and want to understand how identity, permissions, networking, release, and operational boundaries interact once your app enters a shared environment
- **Operations, SRE, DevOps, and platform engineers**: you run multi-team, multi-environment infrastructure and want field experience distilled into reviewable, verifiable governance rules
- **Tech leads and reviewers**: you care not only about whether a resource gets created, but who owns it, who a change affects, how risk surfaces early, and how rules keep being enforced

The cases are set in Azure, but the main line is a complete infrastructure governance framework: problem convergence, ownership, access boundaries, configuration organization, state ownership, change verification, monitoring, cost, and commit-time gates. Specific resources will change with the cloud platform; this order of analysis and governance still applies.

## Three acts and a toolbox extra

The main line runs in three acts. First, sort out the permissions of people and deployment identities; once responsibility has an owner, tighten networking and entry points; once boundaries hold, shift attention to long-term operations. Along the way, the infrastructure grows from "can be built" to "owned, bounded, and maintainable."

```text
  Act 1 · Who can touch what        Act 2 · Can the surface shrink
  Permission autonomy               Security hardening (network, private
                                    endpoints, edge layer)
        │                              │
        └──────────┬───────────────────┘
                   ▼
          Act 3 · Can it be maintained
          Operations, monitoring, cost
                   │
                   ▼
       Extra · Toolbox: efficiency and quality
```

When permission ownership is murky, network boundaries are hard to hold; when boundaries don't hold, long-term operations is just firefighting. The three acts follow this causal line. The toolbox comes after the main line, turning proven practice into everyday checks so feedback arrives faster and quality stays steady.

## The shape of each lesson

Every lesson starts from an incident or an anomaly and follows the investigation line, rather than starting from provider syntax. A lesson usually contains:

| Section | Content |
|---------|---------|
| **Background** | Who hit what problem, and where the error first appeared |
| **Comparison** | What the old way left behind, and how the new boundary is written in HCL |
| **Approach** | Who changes which configuration, in what order |
| **Example** | A directory table pointing at the lesson's example; in-text HCL follows real Azure idioms, while the example runs `init` / `plan` locally (see the appendix) |
| **Quiz** | Usually one question per lesson, right before the **Takeaway**; questions only, no answers — hold them up against your own environment |
| **Takeaway** | One reusable principle, pushing the story into the next lesson |

The `azurerm_*`, `azuread_*`, and real attribute names in the text are what you would write in production; the example directories play the same structures with `terraform_data` and locals, without touching Azure, so you can expand the results on a machine with no subscription.

After reading or running an example: if there's a **Quiz**, think it through against your own environment before reading the **Takeaway**; if there isn't, ask yourself one question about the two approaches in **Comparison** — which side do we look more like?

## Setting off

Cloud work never ends with one more `resource` block. At EG, three teams race their releases while Dee draws boundaries inside Entra groups, RGs, and pipeline scopes — without blocking delivery — and writes them as Terraform that `plan` can verify.

Syntax tells you how to write a piece of configuration. This book cares more about operational order: who gets handled first, who comes later, which layer cannot be skipped, and how to confirm the boundary really held after the change.

If this sounds like the cloud you maintain, start from lesson one and walk on with Dee.


---

| | |
|---|---|
| Full book | [Leanpub](https://leanpub.com/terraform-on-azure) |
| Runnable examples | [Repository](https://github.com/NewbMiao/terraform-on-azure-examples) (`permissions/`, `security/`, `tooling/`, …) |

Sidebar lists **all** lessons; **bold links** are free samples here — gray rows are in the [full book](https://leanpub.com/terraform-on-azure) only.
