# relay-group-portal-multi-tenant

Runnable Terraform example: one shared multi-tenant app registration, with sign-in audience restrictions applied by PATCHing the existing application object.

No Azure credentials or subscription needed: Azure resources are played by `terraform_data` and locals, so `terraform plan` expands the full wiring locally.

## Run

```bash
terraform init
terraform plan
```

## Files

| File | Contents |
|------|----------|
| `case.auto.tfvars` | Home tenant `example.com`, plus `example.org` as the pulse consumer tenant |
| `variables.tf` | Input shapes for app registrations, tenant IDs, and email domains |
| `locals.tf` | The subset that needs a PATCH, tenant-key resolution, Graph request assembly |
| `applications.tf` | Plays the publisher's existing `azuread_application` |
| `audience_patch.tf` | Plays `msgraph_update_resource`; a comment at the end contrasts the wrong POST |
| `outputs.tf` | Application object IDs and the PATCH requests |

The `_anti_pattern/` folder holds the don't-do-this variant for comparison.
