provider "aws" {
  region = "us-east-1"
}

module "dynamodb_table" {
  source = "../../"

  table_name = "basic-example-table"
  hash_key   = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]

  tags = {
    Environment = "dev"
    Project     = "basic-example"
  }
}

output "table_name" {
  value = module.dynamodb_table.table_name
}

output "table_arn" {
  value = module.dynamodb_table.table_arn
}
