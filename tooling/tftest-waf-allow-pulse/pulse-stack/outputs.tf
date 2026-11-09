output "path_regression" {
  description = "URI regression results per rule; plan and test share the same failure list."
  value = {
    check = {
      must_match_failures     = local.path_regression_check_must_match_failures
      must_not_match_failures = local.path_regression_check_must_not_match_failures
    }
    test = {
      must_match_failures     = local.path_regression_test_must_match_failures
      must_not_match_failures = local.path_regression_test_must_not_match_failures
    }
  }
}
