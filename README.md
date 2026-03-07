# terraform-aws-dynamodb

Terraform module to provision an AWS DynamoDB table with full-featured support for global tables, DAX caching, auto-scaling, encryption, streaming, and more.

## Architecture

```
                                    +-------------------+
                                    |   CloudWatch      |
                                    | Contributor       |
                                    |   Insights        |
                                    +--------+----------+
                                             |
+----------------+    +---------------------+|+---------------------+
|  Application   |--->|    DAX Cluster       |||   DynamoDB Table    |
|                |    |  (Optional Cache)    |-->                    |
+----------------+    +---------------------+ |  - GSIs / LSIs      |
                                              |  - TTL              |
                                              |  - Encryption (KMS) |
                                              |  - PITR             |
                                              +----------+----------+
                                                         |
                              +--------------------------+--------------------------+
                              |                          |                          |
                    +---------v---------+     +----------v---------+    +-----------v----------+
                    |  DynamoDB Stream   |     |  Kinesis Stream    |    |  Global Table        |
                    |  (Optional)        |     |  (Optional)        |    |  Replicas            |
                    +-------------------+     +--------------------+    |  (Multi-Region)      |
                                                                       +----------------------+

                    +-------------------+
                    |  Auto Scaling      |
                    |  (Read/Write)      |
                    +-------------------+
```

## Features

- **DynamoDB Table** with configurable hash/range keys, attributes, and table class
- **Billing Modes**: PAY_PER_REQUEST (on-demand) or PROVISIONED
- **Global Secondary Indexes (GSIs)** and **Local Secondary Indexes (LSIs)**
- **Global Tables**: Multi-region replication with configurable replicas
- **DAX Cluster**: In-memory caching with subnet group, parameter group, and IAM role
- **Auto Scaling**: Target tracking policies for read and write capacity
- **Point-in-Time Recovery (PITR)**: Continuous backups enabled by default
- **Server-Side Encryption**: AWS managed or customer-managed KMS keys
- **TTL**: Configurable time-to-live attribute
- **DynamoDB Streams**: Change data capture with configurable view types
- **Kinesis Streaming**: Stream table changes to Amazon Kinesis Data Streams
- **Contributor Insights**: CloudWatch Contributor Insights enabled by default

## Usage

### Basic

```hcl
module "dynamodb_table" {
  source = "github.com/kogunlowo123/terraform-aws-dynamodb"

  table_name = "my-table"
  hash_key   = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]
}
```

### Provisioned with Auto Scaling

```hcl
module "dynamodb_table" {
  source = "github.com/kogunlowo123/terraform-aws-dynamodb"

  table_name     = "my-table"
  billing_mode   = "PROVISIONED"
  hash_key       = "pk"
  range_key      = "sk"
  read_capacity  = 10
  write_capacity = 10

  attributes = [
    { name = "pk", type = "S" },
    { name = "sk", type = "S" },
  ]

  enable_autoscaling             = true
  autoscaling_read_min_capacity  = 5
  autoscaling_read_max_capacity  = 100
  autoscaling_read_target        = 70
  autoscaling_write_min_capacity = 5
  autoscaling_write_max_capacity = 100
  autoscaling_write_target       = 70
}
```

### Global Table with DAX

```hcl
module "dynamodb_table" {
  source = "github.com/kogunlowo123/terraform-aws-dynamodb"

  table_name = "my-global-table"
  hash_key   = "id"

  attributes = [
    { name = "id", type = "S" },
  ]

  enable_global_tables = true
  replica_regions = [
    { region_name = "eu-west-1" },
    { region_name = "ap-southeast-1" },
  ]

  enable_dax     = true
  dax_node_type  = "dax.r5.large"
  dax_node_count = 3
  dax_subnet_ids = ["subnet-abc123", "subnet-def456"]
}
```

## Examples

- [Basic](examples/basic/) - Simple on-demand table
- [Advanced](examples/advanced/) - Provisioned table with autoscaling, TTL, streams, and GSIs
- [Complete](examples/complete/) - Full-featured table with global replication, DAX, Kinesis streaming, and CMK encryption

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.20.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.20.0 |

## Resources

| Name | Type |
|------|------|
| aws_dynamodb_table.this | resource |
| aws_dynamodb_contributor_insights.this | resource |
| aws_dynamodb_kinesis_streaming_destination.this | resource |
| aws_appautoscaling_target.read | resource |
| aws_appautoscaling_policy.read | resource |
| aws_appautoscaling_target.write | resource |
| aws_appautoscaling_policy.write | resource |
| aws_dax_cluster.this | resource |
| aws_dax_subnet_group.this | resource |
| aws_dax_parameter_group.this | resource |
| aws_iam_role.dax | resource |
| aws_iam_role_policy.dax | resource |
| aws_region.current | data source |
| aws_caller_identity.current | data source |
| aws_partition.current | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| table_name | Name of the DynamoDB table | `string` | n/a | yes |
| billing_mode | Billing mode (PROVISIONED or PAY_PER_REQUEST) | `string` | `"PAY_PER_REQUEST"` | no |
| hash_key | Hash (partition) key attribute | `string` | n/a | yes |
| range_key | Range (sort) key attribute | `string` | `null` | no |
| attributes | List of attribute definitions | `list(object)` | n/a | yes |
| table_class | Storage class (STANDARD or STANDARD_INFREQUENT_ACCESS) | `string` | `"STANDARD"` | no |
| read_capacity | Read capacity units (required for PROVISIONED) | `number` | `null` | no |
| write_capacity | Write capacity units (required for PROVISIONED) | `number` | `null` | no |
| global_secondary_indexes | List of GSI definitions | `list(object)` | `[]` | no |
| local_secondary_indexes | List of LSI definitions | `list(object)` | `[]` | no |
| enable_point_in_time_recovery | Enable PITR | `bool` | `true` | no |
| enable_encryption | Enable server-side encryption | `bool` | `true` | no |
| kms_key_arn | KMS key ARN for encryption | `string` | `null` | no |
| enable_ttl | Enable TTL | `bool` | `false` | no |
| ttl_attribute | TTL attribute name | `string` | `""` | no |
| enable_stream | Enable DynamoDB Streams | `bool` | `false` | no |
| stream_view_type | Stream view type | `string` | `"NEW_AND_OLD_IMAGES"` | no |
| enable_global_tables | Enable global tables | `bool` | `false` | no |
| replica_regions | List of replica region configurations | `list(object)` | `[]` | no |
| enable_contributor_insights | Enable Contributor Insights | `bool` | `true` | no |
| enable_autoscaling | Enable auto scaling | `bool` | `false` | no |
| autoscaling_read_min_capacity | Min read capacity for autoscaling | `number` | `5` | no |
| autoscaling_read_max_capacity | Max read capacity for autoscaling | `number` | `100` | no |
| autoscaling_read_target | Target read utilization (%) | `number` | `70` | no |
| autoscaling_write_min_capacity | Min write capacity for autoscaling | `number` | `5` | no |
| autoscaling_write_max_capacity | Max write capacity for autoscaling | `number` | `100` | no |
| autoscaling_write_target | Target write utilization (%) | `number` | `70` | no |
| enable_dax | Enable DAX cluster | `bool` | `false` | no |
| dax_node_type | DAX node type | `string` | `"dax.r5.large"` | no |
| dax_node_count | Number of DAX nodes | `number` | `1` | no |
| dax_subnet_ids | Subnet IDs for DAX | `list(string)` | `[]` | no |
| enable_kinesis_streaming | Enable Kinesis streaming | `bool` | `false` | no |
| kinesis_stream_arn | Kinesis stream ARN | `string` | `null` | no |
| tags | Map of tags for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| table_name | Name of the DynamoDB table |
| table_arn | ARN of the DynamoDB table |
| table_id | ID of the DynamoDB table |
| table_hash_key | Hash key of the table |
| table_range_key | Range key of the table |
| table_billing_mode | Billing mode of the table |
| table_stream_arn | ARN of the table stream |
| table_stream_label | Timestamp of the table stream |
| dax_cluster_arn | ARN of the DAX cluster |
| dax_cluster_address | DNS name of the DAX cluster |
| dax_cluster_port | Port of the DAX cluster |
| dax_configuration_endpoint | Configuration endpoint of the DAX cluster |
| autoscaling_read_target_id | ID of the read autoscaling target |
| autoscaling_write_target_id | ID of the write autoscaling target |

## Cost Estimation

Key cost factors for this module:

| Component | Pricing Model | Notes |
|-----------|--------------|-------|
| DynamoDB Table (On-Demand) | Per-request pricing | $1.25 per million write request units, $0.25 per million read request units |
| DynamoDB Table (Provisioned) | Per-hour per capacity unit | ~$0.00065/WCU/hr, ~$0.00013/RCU/hr |
| Global Tables | Replicated write capacity | Charged per replicated WCU in each region |
| DAX | Per-node-hour | dax.r5.large ~$0.269/hr per node |
| PITR | Per GB/month | $0.20 per GB/month of table size |
| DynamoDB Streams | Per 100K read requests | $0.02 per 100,000 stream read requests |
| Data Storage | Per GB/month | First 25 GB free, then $0.25 per GB |

> Prices shown are approximate for us-east-1. Check [AWS DynamoDB Pricing](https://aws.amazon.com/dynamodb/pricing/) for current rates.

## License

MIT License. See [LICENSE](LICENSE) for details.

## Author

Module maintained by [kogunlowo123](https://github.com/kogunlowo123).
