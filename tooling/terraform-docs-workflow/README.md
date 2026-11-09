# terraform-docs-workflow

terraform-docs example: refresh the `BEGIN_TF_DOCS` block in `demo-module/README.md` — run from this directory:

```bash
terraform-docs --config .terraform-docs.yml demo-module/
```

After the refresh, the **Outputs** table should match `outputs.tf` (`ingress_fqdn`, no more `api_base_url`).
