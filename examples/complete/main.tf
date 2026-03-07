provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu_west_1"
  region = "eu-west-1"
}

################################################################################
# VPC for DAX (minimal example)
################################################################################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

################################################################################
# KMS Key for Encryption
################################################################################

resource "aws_kms_key" "dynamodb" {
  description             = "KMS key for DynamoDB table encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Environment = "production"
    Project     = "complete-example"
  }
}

################################################################################
# Kinesis Stream
################################################################################

resource "aws_kinesis_stream" "dynamodb_stream" {
  name             = "complete-example-kinesis-stream"
  shard_count      = 1
  retention_period = 24

  tags = {
    Environment = "production"
    Project     = "complete-example"
  }
}

################################################################################
# DynamoDB Table - Complete Example
################################################################################

module "dynamodb_table" {
  source = "../../"

  table_name   = "complete-example-table"
  billing_mode = "PROVISIONED"
  hash_key     = "pk"
  range_key    = "sk"
  table_class  = "STANDARD"

  read_capacity  = 20
  write_capacity = 20

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
    },
    {
      name = "lsi1sk"
      type = "N"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "gsi1"
      hash_key        = "gsi1pk"
      range_key       = "gsi1sk"
      projection_type = "ALL"
      read_capacity   = 10
      write_capacity  = 10
    }
  ]

  local_secondary_indexes = [
    {
      name            = "lsi1"
      range_key       = "lsi1sk"
      projection_type = "ALL"
    }
  ]

  # Encryption with CMK
  enable_encryption = true
  kms_key_arn       = aws_kms_key.dynamodb.arn

  # Point-in-time recovery
  enable_point_in_time_recovery = true

  # TTL
  enable_ttl    = true
  ttl_attribute = "expires_at"

  # Streams
  enable_stream    = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  # Kinesis streaming
  enable_kinesis_streaming = true
  kinesis_stream_arn       = aws_kinesis_stream.dynamodb_stream.arn

  # Global tables
  enable_global_tables = true
  replica_regions = [
    {
      region_name            = "eu-west-1"
      point_in_time_recovery = true
      propagate_tags         = true
    }
  ]

  # Contributor insights
  enable_contributor_insights = true

  # Auto scaling
  enable_autoscaling             = true
  autoscaling_read_min_capacity  = 10
  autoscaling_read_max_capacity  = 200
  autoscaling_read_target        = 65
  autoscaling_write_min_capacity = 10
  autoscaling_write_max_capacity = 200
  autoscaling_write_target       = 65

  # DAX
  enable_dax     = true
  dax_node_type  = "dax.r5.large"
  dax_node_count = 3
  dax_subnet_ids = data.aws_subnets.default.ids

  tags = {
    Environment = "production"
    Project     = "complete-example"
  }
}

################################################################################
# Outputs
################################################################################

output "table_name" {
  value = module.dynamodb_table.table_name
}

output "table_arn" {
  value = module.dynamodb_table.table_arn
}

output "table_stream_arn" {
  value = module.dynamodb_table.table_stream_arn
}

output "dax_cluster_address" {
  value = module.dynamodb_table.dax_cluster_address
}

output "dax_configuration_endpoint" {
  value = module.dynamodb_table.dax_configuration_endpoint
}
