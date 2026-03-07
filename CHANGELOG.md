# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-07

### Added

- DynamoDB table resource with configurable hash/range keys and attributes
- Support for PAY_PER_REQUEST and PROVISIONED billing modes
- Global Secondary Index (GSI) and Local Secondary Index (LSI) support
- Global tables with multi-region replication
- DAX cluster with subnet group, parameter group, and IAM role
- Application Auto Scaling for read and write capacity
- Point-in-Time Recovery (PITR) enabled by default
- Server-side encryption with optional customer-managed KMS key
- TTL (Time to Live) support
- DynamoDB Streams with configurable view types
- Kinesis streaming destination support
- CloudWatch Contributor Insights enabled by default
- Table class selection (STANDARD / STANDARD_INFREQUENT_ACCESS)
- Comprehensive tagging across all resources
- Basic, advanced, and complete usage examples
- Full documentation with architecture diagram, inputs/outputs, and cost estimation
