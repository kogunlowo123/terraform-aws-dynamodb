################################################################################
# Table Configuration
################################################################################

variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "Controls how you are charged for read and write throughput. Valid values are PROVISIONED or PAY_PER_REQUEST"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "billing_mode must be either PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key"
  type        = string
}

variable "range_key" {
  description = "The attribute to use as the range (sort) key"
  type        = string
  default     = null
}

variable "attributes" {
  description = "List of attribute definitions for the table"
  type = list(object({
    name = string
    type = string
  }))
}

variable "table_class" {
  description = "Storage class of the table. Valid values are STANDARD and STANDARD_INFREQUENT_ACCESS"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "table_class must be either STANDARD or STANDARD_INFREQUENT_ACCESS."
  }
}

################################################################################
# Capacity Configuration
################################################################################

variable "read_capacity" {
  description = "The number of read units for the table. Required if billing_mode is PROVISIONED"
  type        = number
  default     = null
}

variable "write_capacity" {
  description = "The number of write units for the table. Required if billing_mode is PROVISIONED"
  type        = number
  default     = null
}

################################################################################
# Secondary Indexes
################################################################################

variable "global_secondary_indexes" {
  description = "List of global secondary index definitions"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = string
    non_key_attributes = optional(list(string), [])
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  default = []
}

variable "local_secondary_indexes" {
  description = "List of local secondary index definitions"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string), [])
  }))
  default = []
}

################################################################################
# Point-in-Time Recovery
################################################################################

variable "enable_point_in_time_recovery" {
  description = "Whether to enable point-in-time recovery"
  type        = bool
  default     = true
}

################################################################################
# Encryption
################################################################################

variable "enable_encryption" {
  description = "Whether to enable encryption at rest using a CMK"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of the KMS key to use for encryption. If not specified, uses AWS managed key"
  type        = string
  default     = null
}

################################################################################
# TTL
################################################################################

variable "enable_ttl" {
  description = "Whether to enable TTL on the table"
  type        = bool
  default     = false
}

variable "ttl_attribute" {
  description = "Name of the TTL attribute"
  type        = string
  default     = ""
}

################################################################################
# Streams
################################################################################

variable "enable_stream" {
  description = "Whether to enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "When an item is modified, determines what information is written to the stream. Valid values are KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"

  validation {
    condition     = contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    error_message = "stream_view_type must be one of KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."
  }
}

################################################################################
# Global Tables (Replicas)
################################################################################

variable "enable_global_tables" {
  description = "Whether to enable global tables (multi-region replication)"
  type        = bool
  default     = false
}

variable "replica_regions" {
  description = "List of regions where replicas will be created"
  type = list(object({
    region_name            = string
    kms_key_arn            = optional(string)
    point_in_time_recovery = optional(bool, true)
    propagate_tags         = optional(bool, true)
  }))
  default = []
}

################################################################################
# Contributor Insights
################################################################################

variable "enable_contributor_insights" {
  description = "Whether to enable CloudWatch Contributor Insights for the table"
  type        = bool
  default     = true
}

################################################################################
# Auto Scaling
################################################################################

variable "enable_autoscaling" {
  description = "Whether to enable auto scaling for the table"
  type        = bool
  default     = false
}

variable "autoscaling_read_min_capacity" {
  description = "Minimum read capacity for auto scaling"
  type        = number
  default     = 5
}

variable "autoscaling_read_max_capacity" {
  description = "Maximum read capacity for auto scaling"
  type        = number
  default     = 100
}

variable "autoscaling_read_target" {
  description = "Target utilization percentage for read auto scaling"
  type        = number
  default     = 70
}

variable "autoscaling_write_min_capacity" {
  description = "Minimum write capacity for auto scaling"
  type        = number
  default     = 5
}

variable "autoscaling_write_max_capacity" {
  description = "Maximum write capacity for auto scaling"
  type        = number
  default     = 100
}

variable "autoscaling_write_target" {
  description = "Target utilization percentage for write auto scaling"
  type        = number
  default     = 70
}

################################################################################
# DAX
################################################################################

variable "enable_dax" {
  description = "Whether to create a DAX cluster for the table"
  type        = bool
  default     = false
}

variable "dax_node_type" {
  description = "The node type for the DAX cluster"
  type        = string
  default     = "dax.r5.large"
}

variable "dax_node_count" {
  description = "The number of nodes in the DAX cluster"
  type        = number
  default     = 1
}

variable "dax_subnet_ids" {
  description = "List of subnet IDs for the DAX cluster subnet group"
  type        = list(string)
  default     = []
}

################################################################################
# Kinesis Streaming
################################################################################

variable "enable_kinesis_streaming" {
  description = "Whether to enable Kinesis streaming for the table"
  type        = bool
  default     = false
}

variable "kinesis_stream_arn" {
  description = "ARN of the Kinesis data stream for streaming"
  type        = string
  default     = null
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
