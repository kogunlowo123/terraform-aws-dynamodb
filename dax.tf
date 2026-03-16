################################################################################
# DAX Cluster
################################################################################

resource "aws_dax_cluster" "this" {
  count = var.enable_dax ? 1 : 0

  cluster_name       = "${var.table_name}-dax"
  iam_role_arn       = aws_iam_role.dax[0].arn
  node_type          = var.dax_node_type
  replication_factor = var.dax_node_count

  subnet_group_name    = aws_dax_subnet_group.this[0].name
  parameter_group_name = aws_dax_parameter_group.this[0].name

  server_side_encryption {
    enabled = true
  }

  tags = var.tags
}

################################################################################
# DAX Subnet Group
################################################################################

resource "aws_dax_subnet_group" "this" {
  count = var.enable_dax ? 1 : 0

  name       = "${var.table_name}-dax-subnet-group"
  subnet_ids = var.dax_subnet_ids
}

################################################################################
# DAX Parameter Group
################################################################################

resource "aws_dax_parameter_group" "this" {
  count = var.enable_dax ? 1 : 0

  name = "${var.table_name}-dax-params"

  parameters {
    name  = "query-ttl-millis"
    value = "300000"
  }

  parameters {
    name  = "record-ttl-millis"
    value = "180000"
  }
}

################################################################################
# DAX IAM Role
################################################################################

resource "aws_iam_role" "dax" {
  count = var.enable_dax ? 1 : 0

  name = "${var.table_name}-dax-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "dax.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "dax" {
  count = var.enable_dax ? 1 : 0

  name = "${var.table_name}-dax-policy"
  role = aws_iam_role.dax[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:ConditionCheckItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
        ]
        Resource = [
          aws_dynamodb_table.this.arn,
          "${aws_dynamodb_table.this.arn}/index/*",
        ]
      }
    ]
  })
}
