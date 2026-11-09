# The check only warns about URI regressions; CI blocking is path_regression.tftest.hcl's job.
check "allow_path_regression_must_match" {
  assert {
    condition     = length(local.path_regression_check_must_match_failures) == 0
    error_message = join("\n", local.path_regression_check_must_match_failures)
  }
}

check "allow_path_regression_must_not_match" {
  assert {
    condition     = length(local.path_regression_check_must_not_match_failures) == 0
    error_message = join("\n", local.path_regression_check_must_not_match_failures)
  }
}
