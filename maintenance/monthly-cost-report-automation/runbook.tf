# Plays azurerm_automation_runbook
resource "terraform_data" "monthly_cost_report_runbook" {
  count = local.enabled ? 1 : 0

  input = {
    name           = local.report.runbook_name
    runbook_type   = "Python"
    content_source = "files/monthly_cost_report.py"
    log_verbose    = true
    log_progress   = true
  }
}

# Plays azurerm_automation_variable_string
resource "terraform_data" "monthly_cost_report_config_var" {
  count = local.enabled ? 1 : 0

  input = {
    name  = "MonthlyCostReportConfig"
    value = local.report_config_json
  }
}

resource "terraform_data" "monthly_cost_report_budget_pins_var" {
  count = local.enabled && local.budget_pins_json != null ? 1 : 0

  input = {
    name  = "MonthlyCostReportBudgetPins"
    value = local.budget_pins_json
  }
}
