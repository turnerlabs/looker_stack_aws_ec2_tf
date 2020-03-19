resource "aws_budgets_budget" "looker_budget" {
  name              = "${var.prefix}-budget-looker-monthly"
  budget_type       = "COST"
  limit_amount      = "600"
  limit_unit        = "USD"
  time_period_start = "2019-12-01_00:00"
  time_unit         = "MONTHLY"

  cost_filters = {
    TagKeyValue = "user:application$${var.tag_application}"
  }

  cost_types {
    use_amortized = true
  }
}