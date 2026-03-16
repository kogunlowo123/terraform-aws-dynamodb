################################################################################
# Table
################################################################################

output "table_name" {
  description = "Name of the DynamoDB table."
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table."
  value       = aws_dynamodb_table.this.arn
}

output "table_id" {
  description = "ID of the DynamoDB table."
  value       = aws_dynamodb_table.this.id
}

output "table_hash_key" {
  description = "Hash key of the DynamoDB table."
  value       = aws_dynamodb_table.this.hash_key
}

output "table_range_key" {
  description = "Range key of the DynamoDB table."
  value       = aws_dynamodb_table.this.range_key
}

output "table_billing_mode" {
  description = "Billing mode of the DynamoDB table."
  value       = aws_dynamodb_table.this.billing_mode
}

################################################################################
# Stream
################################################################################

output "table_stream_arn" {
  description = "ARN of the DynamoDB table stream."
  value       = try(aws_dynamodb_table.this.stream_arn, null)
}

output "table_stream_label" {
  description = "Timestamp of the DynamoDB table stream."
  value       = try(aws_dynamodb_table.this.stream_label, null)
}

################################################################################
# DAX
################################################################################

output "dax_cluster_arn" {
  description = "ARN of the DAX cluster."
  value       = try(aws_dax_cluster.this[0].arn, null)
}

output "dax_cluster_address" {
  description = "DNS name of the DAX cluster without the port."
  value       = try(aws_dax_cluster.this[0].cluster_address, null)
}

output "dax_cluster_port" {
  description = "Port of the DAX cluster."
  value       = try(aws_dax_cluster.this[0].port, null)
}

output "dax_configuration_endpoint" {
  description = "Configuration endpoint of the DAX cluster."
  value       = try(aws_dax_cluster.this[0].configuration_endpoint, null)
}

################################################################################
# Autoscaling
################################################################################

output "autoscaling_read_target_id" {
  description = "ID of the read capacity autoscaling target."
  value       = try(aws_appautoscaling_target.read[0].id, null)
}

output "autoscaling_write_target_id" {
  description = "ID of the write capacity autoscaling target."
  value       = try(aws_appautoscaling_target.write[0].id, null)
}
