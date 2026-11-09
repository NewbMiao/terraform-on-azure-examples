locals {
  cluster_json   = jsonencode([for c in var.workbook.cluster_options : { value = c.value, label = c.label }])
  namespace_json = jsonencode([for n in var.workbook.namespace_options : { value = n.value, label = n.label }])

  rank_kql = file("${path.module}/rank.kql")

  workbook_data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "## ${var.workbook.display_name}\n\nPick **Cluster**, **Namespace**, and **TimeRange**; the ranking table columns run **Req** → **Sug** → **Lim** → **Sug_lim**."
        }
      },
      {
        type = 9
        content = {
          version                 = "KqlParameterItem/1.0"
          style                   = "pills"
          queryType               = 0
          resourceType            = "microsoft.operationalinsights/workspaces"
          crossComponentResources = [var.workbook.lgw_workspace_id]
          parameters = [
            {
              id         = "pulse-sizing-timerange"
              version    = "KqlParameterItem/1.0"
              name       = "TimeRange"
              type       = 4
              isRequired = true
              value      = { durationMs = 2419200000 }
              typeSettings = {
                selectableValues = [
                  { durationMs = 604800000 },
                  { durationMs = 2419200000 },
                ]
              }
            },
            {
              id         = "pulse-sizing-cluster"
              version    = "KqlParameterItem/1.0"
              name       = "Cluster"
              type       = 2
              isRequired = true
              value      = var.workbook.cluster_default
              jsonData   = local.cluster_json
            },
            {
              id          = "pulse-sizing-namespace"
              version     = "KqlParameterItem/1.0"
              name        = "Namespace"
              type        = 2
              multiSelect = true
              quote       = "'"
              delimiter   = ","
              isRequired  = true
              value       = var.workbook.namespace_default
              jsonData    = local.namespace_json
            },
          ]
        }
      },
      {
        type = 3
        content = {
          version                  = "KqlItem/1.0"
          query                    = local.rank_kql
          title                    = "Deployments — req → Sug"
          size                     = 2
          queryType                = 0
          visualization            = "table"
          resourceType             = "microsoft.operationalinsights/workspaces"
          crossComponentResources  = [var.workbook.lgw_workspace_id]
          timeContextFromParameter = "TimeRange"
        }
      },
    ]
  })
}
