variable "EXTERNAL_ID" {
  default = ""
}
variable "CUSTOMER_ID" {
  default = ""
}
variable "DNS_PREFIX_CLOUDTRAIL" {
  default = ""
}
variable "DNS_PREFIX_FLOW" {
  default = ""
}
variable "FLOW_LOG_S3_BUCKET_PREFIX" {
  default = ""
}
variable "CLOUDTRAIL_S3_BUCKET_PREFIX" {
  default = ""
}
variable "AWS_DEFAULT_REGION" {
  default = "us-west-2"
}
variable "OPTIX_RESOURCE_KEY" {
  default = ""
}
variable "OPTIX_RESOURCE_VALUE" {
  default = ""
}
variable "FLOW_LOGS_S3_RETENTION" {
  default = ""
}
variable "CLOUDTRAIL_S3_RETENTION" {
  default = ""
}
variable "S3_FORCE_DESTROY" {
  default = ""
}
variable "CLOUDTRAIL_LOGS" {
  default = ""
}

variable "SET_RETENTION_ON_S3_CLOUDTRAIL" {
  default = ""
}
variable "SET_RETENTION_ON_S3_FLOW" {
  default = ""
}
variable "FLOWLOG_REGIONS" {
  default = ""
}
variable "FLOW_ONE_REGION_VALUE" {
  default = ""
}
variable "FLOW_LOGS" {
  default = ""
}
variable "ENABLE_FLOW_ONE_REGION" {
  default = ""
}