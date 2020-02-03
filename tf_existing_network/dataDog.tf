resource "datadog_integration_aws" "dd_int_aws" {
    account_id = var.aws_account_number
    role_name = var.aws_account_role_name_dd
}

resource "datadog_dashboard" "ordered_dashboard" {
  title         = "Looker Dashbaord for ${var.subdomain}"
  description   = "Created using the Datadog provider in Terraform"
  layout_type   = "ordered"
  is_read_only  = true

    widget {
        timeseries_definition {
            request {
                q= "sum:aws.rds.database_connections{application:looker}"
                display_type = "line"
            }
            title = "aws.rds.database_connections"
            show_legend = false
        }
    }

    widget {
        timeseries_definition {
            request {
                q= "sum:aws.rds.cpuutilization{application:looker}"
                display_type = "line"
            }
            title = "aws.rds.cpuutilization"
            show_legend = false
        }
    }

    widget {
        timeseries_definition {
            request {
                q= "avg:aws.rds.network_transmit_throughput{application:looker}.as_count()"
                display_type = "line"
            }
            title = "Avg of aws.rds.network_transmit_throughput over application:looker"
            show_legend = false
        }
    }

    widget {
        timeseries_definition {
            request {
                q= "sum:aws.applicationelb.request_count{application:looker}.as_count()"
                display_type = "line"
            }
            title = "Sum of aws.applicationelb.request_count over application:looker"
            show_legend = false
        }
    }

    widget {
        timeseries_definition {
            request {
                q= "avg:aws.ec2.cpuutilization{application:looker}"
                display_type = "line"
            }
            title = "Avg of aws.ec2.cpuutilization over application:looker"
            show_legend = false
        }
    }

    widget {
        timeseries_definition {
            request {
                q= "avg:aws.efs.percent_iolimit{application:looker}"
                display_type = "line"
            }
            title = "Avg of aws.efs.percent_iolimit over application:looker"
            show_legend = false
        }
    }

    widget {
        timeseries_definition {
            request {
                q= "avg:aws.applicationelb.target_response_time.average{application:looker}"
                display_type = "line"
            }
            title = "Avg of aws.applicationelb.target_response_time.average over application:looker"
            show_legend = false
        }
    }
}