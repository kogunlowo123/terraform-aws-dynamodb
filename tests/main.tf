terraform {
  required_version = ">= 1.7.0"
}

module "test" {
  source = "../"

  table_name   = "test-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"
  range_key    = "sk"

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
    }
  ]

  enable_point_in_time_recovery = true
  enable_encryption             = true

  enable_ttl    = true
  ttl_attribute = "expireAt"

  enable_stream    = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  enable_contributor_insights = true

  tags = {
    Test = "true"
  }
}
