variable "EXTERNAL_ID" {}
variable "CUSTOMER_ID" {}
variable "DNS_PREFIX_CLOUDTRAIL" {}
variable "DNS_PREFIX_FLOW" {}
variable "FLOW_LOG_S3_BUCKET_PREFIX" {}
variable "CLOUDTRAIL_S3_BUCKET_PREFIX" {}
variable "AWS_DEFAULT_REGION" {
  default = "us-east-2"
}
variable "OPTIX_RESOURCE_KEY" {}
variable "OPTIX_RESOURCE_VALUE" {}
variable "FLOW_LOGS_S3_RETENTION" {}
variable "CLOUDTRAIL_S3_RETENTION" {}
variable "S3_FORCE_DESTROY" {}

variable "SET_RETENTION_ON_S3_CLOUDTRAIL" {}
variable "SET_RETENTION_ON_S3_FLOW" {}
variable "FLOWLOG_REGIONS" {}
variable "FLOW_ONE_REGION_VALUE" {}
variable "FLOW_LOGS" {}
variable "CLOUDTRAIL_LOGS" {}
variable "ENABLE_FLOW_ONE_REGION" {}