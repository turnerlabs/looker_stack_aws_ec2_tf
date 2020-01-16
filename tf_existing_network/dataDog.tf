# resource "datadog_integration_aws" "dd_int_aws" {
#     account_id = var.aws_account_number
#     role_name = var.aws_account_role_name_dd
#     filter_tags = ["key:value"]
#     host_tags = ["key:value", "key2:value2"]
#     account_specific_namespace_rules = {
#         auto_scaling = false
#         opsworks = false
#     }
# }

# resource "datadog_dashboard" "ordered_dashboard" {
#   title         = "Looker Dashbaord for ${var.domain}"
#   description   = "Created using the Datadog provider in Terraform"
#   layout_type   = "ordered"
#   is_read_only  = true
# }