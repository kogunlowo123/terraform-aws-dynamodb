provider "aws" {
  region = "us-east-1"
}

module "dynamodb_table" {
  source = "../../"

  table_name   = "advanced-example-table"
  billing_mode = "PROVISIONED"
  hash_key     = "pk"
  range_key    = "sk"

  read_capacity  = 10
  write_capacity = 10

  attributes = [
    {
      name = "pk"
      type = "S"
    },
    {
      name = "sk"
      type = "S"
    },
    {
      name = "gsi1pk"
      type = "S"
    },
    {
      name = "gsi1sk"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "gsi1"
      hash_key        = "gsi1pk"
      range_key       = "gsi1sk"
      projection_type = "ALL"
      read_capacity   = 5
      write_capacity  = 5
    }
  ]

  # Enable autoscaling
  enable_autoscaling             = true
  autoscaling_read_min_capacity  = 5
  autoscaling_read_max_capacity  = 50
  autoscaling_read_target        = 70
  autoscaling_write_min_capacity = 5
  autoscaling_write_max_capacity = 50
  autoscaling_write_target       = 70

  # Enable PITR
  enable_point_in_time_recovery = true

  # Enable TTL
  enable_ttl    = true
  ttl_attribute = "expires_at"

  # Enable streams
  enable_stream    = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  # Enable contributor insights
  enable_contributor_insights = true

  tags = {
    Environment = "staging"
    Project     = "advanced-example"
  }
}

output "table_name" {
  value = module.dynamodb_table.table_name
}

output "table_arn" {
  value = module.dynamodb_table.table_arn
}

output "table_stream_arn" {
  value = module.dynamodb_table.table_stream_arn
}
