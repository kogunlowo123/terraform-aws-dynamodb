locals {
  # Determine if we need to set up provisioned capacity
  is_provisioned = var.billing_mode == "PROVISIONED"

  # Autoscaling requires provisioned billing mode
  autoscaling_enabled = var.enable_autoscaling && local.is_provisioned

  # Build the table ARN pattern for autoscaling resource IDs
  table_arn_prefix = "table/${var.table_name}"

  # Merge default tags
  tags = merge(
    {
      "ManagedBy" = "terraform"
      "Module"    = "terraform-aws-dynamodb"
    },
    var.tags,
  )
}
