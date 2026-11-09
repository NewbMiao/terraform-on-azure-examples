locals {
  allow_path_rules = [
    for r in var.custom_rules : merge(r, {
      match_values = try(var.test_match_values_override[r.name], r.match_values)
    })
    if r.action == "Allow" && r.path_regression != null
  ]

  allow_path_rules_check = [
    for r in local.allow_path_rules : r
    if r.regression_gate == "check"
  ]

  allow_path_rules_test = [
    for r in local.allow_path_rules : r
    if r.regression_gate == "test"
  ]

  path_regression_check_must_match_failures = compact(flatten([
    for r in local.allow_path_rules_check : [
      for u in r.path_regression.must_match :
      !can(regex("(?i)${r.match_values[0]}", u)) ? "${r.name}: must_match ${u}" : ""
    ]
  ]))

  path_regression_check_must_not_match_failures = compact(flatten([
    for r in local.allow_path_rules_check : [
      for u in r.path_regression.must_not_match :
      can(regex("(?i)${r.match_values[0]}", u)) ? "${r.name}: must_not_match ${u}" : ""
    ]
  ]))

  path_regression_test_must_match_failures = compact(flatten([
    for r in local.allow_path_rules_test : [
      for u in r.path_regression.must_match :
      !can(regex("(?i)${r.match_values[0]}", u)) ? "${r.name}: must_match ${u}" : ""
    ]
  ]))

  path_regression_test_must_not_match_failures = compact(flatten([
    for r in local.allow_path_rules_test : [
      for u in r.path_regression.must_not_match :
      can(regex("(?i)${r.match_values[0]}", u)) ? "${r.name}: must_not_match ${u}" : ""
    ]
  ]))
}
