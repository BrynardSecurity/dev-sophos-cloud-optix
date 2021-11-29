variable "EXTERNAL_ID" { default = "1601d908-a738-451c-9e78-67f9af712776" }
variable "CUSTOMER_ID" { default = "1e847759-dc60-4338-8a32-264951a61e26" }
variable "DNS_PREFIX_CLOUDTRAIL" { default = "collector-staging.optix.sophos.com" }
variable "DNS_PREFIX_FLOW" { default = "collector-staging.optix.sophos.com" }
variable "FLOW_LOG_S3_BUCKET_PREFIX" { default = "sophos-optix-flowlogs" }
variable "CLOUDTRAIL_S3_BUCKET_PREFIX" { default = "sophos-optix-cloudtrail" }
variable "AWS_DEFAULT_REGION" { default = "us-west-1" }
variable "OPTIX_RESOURCE_KEY" { default = "created_by" }
variable "OPTIX_RESOURCE_VALUE" { default = "optix" }
variable "FLOW_LOGS_S3_RETENTION" { default = "1" }
variable "CLOUDTRAIL_S3_RETENTION" { default = "2190" }
variable "S3_FORCE_DESTROY" { default = false }

variable "SET_RETENTION_ON_S3_CLOUDTRAIL" { 
  default = true
  type    = bool
  }
variable "SET_RETENTION_ON_S3_FLOW" { 
  default = true
  type    = bool
  }
variable "FLOWLOG_REGIONS" {
  type = list(string)
  default = [
    "us-west-1",
    "us-west-2",
    "us-east-1",
    "us-east-2",
    "eu-west-1",
    "eu-west-2",
    "eu-central-1",
    "ap-south-1",
    "ap-southeast-1",
    "ap-southeast-2",
    "ap-northeast-1",
    "ap-northeast-2",
    "sa-east-1",
    "ca-central-1",
    "eu-west-3",
    "eu-north-1",
  ]
}
variable "FLOW_ONE_REGION_VALUE" { default = "us-west-1"  }
variable "FLOW_LOGS" { 
  default = true
  type    = bool
   }
variable "CLOUDTRAIL_LOGS" { 
  default = true
  type    = bool
   }
variable "ENABLE_FLOW_ONE_REGION" { 
  default = false
  type    = bool
}
