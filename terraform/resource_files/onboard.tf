##############Global Configuration(IAM)##################
module "avid-role" {
  source                  = "../modules/iam-role"
  name                    = "Sophos-Optix-role"
  external_id             = var.EXTERNAL_ID
  tag_key                 = var.OPTIX_RESOURCE_KEY
  tag_value               = var.OPTIX_RESOURCE_VALUE
  assume_role_policy_file = "role.json.tpl"
}
output "sophos-role-arn" {
  value = module.avid-role.iam-role-arn
}

module "Sophos-Avid-read-policy" {
  source      = "../modules/iam-policy"
  name        = "Sophos-Optix-read-policy"
  policy_file = "readonly-inline.json"
}

module "avid-role-policy-attachment-1" {
  source     = "../modules/iam-role-policy-attachment"
  role       = module.avid-role.iam-role-name
  policy_arn = module.Sophos-Avid-read-policy.iam-policy-arn
}

module "avid-role-policy-attachment-2" {
  source     = "../modules/iam-role-policy-attachment"
  role       = module.avid-role.iam-role-name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

module "lambda-role" {
  source                  = "../modules/iam-role"
  name                    = "Sophos-Optix-lambda-logging-role"
  assume_role_policy_file = "lambdaRole.json"
  tag_key                 = var.OPTIX_RESOURCE_KEY
  tag_value               = var.OPTIX_RESOURCE_VALUE
}
module "avid-flowlog-lambda-logging-policy" {
  source         = "../modules/iam-policy"
  name           = "Sophos-Optix-lambda-logging-policy"
  user_account   = data.aws_caller_identity.current.account_id
  default_region = "*"
  policy_file    = "lambdaLoggingRole.json.tpl"
  lambda_name    = "Sophos-Optix-flowlogs-fn"
}
module "flow-log-policy-attachment-1" {
  source     = "../modules/iam-role-policy-attachment"
  role       = module.lambda-role.iam-role-name
  policy_arn = module.avid-flowlog-lambda-logging-policy.iam-policy-arn
}

locals {
  fl_depends_on = "module.flow-logs-module-${var.FLOW_ONE_REGION_VALUE}"
}

#############Flow Log Configuration######################
module "flow-logs-module-us-west-1" {
  providers = {
    aws = aws.us-west-1
  }
  source              = "../modules/flow_log_module"
  region_append       = "us-west-1"
  s3_should_run       = contains(var.FLOWLOG_REGIONS, "us-west-1") && var.FLOW_LOGS == true && "${var.ENABLE_FLOW_ONE_REGION != true || var.FLOW_ONE_REGION_VALUE == "us-west-1"}"
  fl_should_run       = contains(var.FLOWLOG_REGIONS, "us-west-1") && var.FLOW_LOGS == true
  account_id          = data.aws_caller_identity.current.account_id
  s3_bucket_prefix    = var.FLOW_LOG_S3_BUCKET_PREFIX
  expiration_days     = var.FLOW_LOGS_S3_RETENTION
  s3_force_destroy    = var.S3_FORCE_DESTROY
  lifecycle_enabled   = var.SET_RETENTION_ON_S3_FLOW
  env_customer_id     = var.CUSTOMER_ID
  env_dns_prefix      = var.DNS_PREFIX_FLOW
  tag_key             = var.OPTIX_RESOURCE_KEY
  tag_value           = var.OPTIX_RESOURCE_VALUE
  flow_default_region = var.FLOW_ONE_REGION_VALUE
  is_single_bucket    = var.ENABLE_FLOW_ONE_REGION
  policy_depends_on   = module.avid-role
}


module "flow-logs-module-us-west-2" {
  providers = {
    aws = aws.us-west-2
  }
  source              = "../modules/flow_log_module"
  region_append       = "us-west-2"
  s3_should_run       = contains(var.FLOWLOG_REGIONS, "us-west-2") && var.FLOW_LOGS == true && "${var.ENABLE_FLOW_ONE_REGION != true || var.FLOW_ONE_REGION_VALUE == "us-west-2"}"
  fl_should_run       = contains(var.FLOWLOG_REGIONS, "us-west-2") && var.FLOW_LOGS == true
  account_id          = data.aws_caller_identity.current.account_id
  s3_bucket_prefix    = var.FLOW_LOG_S3_BUCKET_PREFIX
  expiration_days     = var.FLOW_LOGS_S3_RETENTION
  s3_force_destroy    = var.S3_FORCE_DESTROY
  lifecycle_enabled   = var.SET_RETENTION_ON_S3_FLOW
  env_customer_id     = var.CUSTOMER_ID
  env_dns_prefix      = var.DNS_PREFIX_FLOW
  tag_key             = var.OPTIX_RESOURCE_KEY
  tag_value           = var.OPTIX_RESOURCE_VALUE
  flow_default_region = var.FLOW_ONE_REGION_VALUE
  is_single_bucket    = var.ENABLE_FLOW_ONE_REGION
  policy_depends_on   = module.avid-role
}

module "flow-logs-module-us-east-1" {
  providers = {
    aws = aws.us-east-1
  }
  source              = "../modules/flow_log_module"
  region_append       = "us-east-1"
  s3_should_run       = contains(var.FLOWLOG_REGIONS, "us-east-1") && var.FLOW_LOGS == true && "${var.ENABLE_FLOW_ONE_REGION != true || var.FLOW_ONE_REGION_VALUE == "us-east-1"}"
  fl_should_run       = contains(var.FLOWLOG_REGIONS, "us-east-1") && var.FLOW_LOGS == true
  account_id          = data.aws_caller_identity.current.account_id
  s3_bucket_prefix    = var.FLOW_LOG_S3_BUCKET_PREFIX
  expiration_days     = var.FLOW_LOGS_S3_RETENTION
  lifecycle_enabled   = var.SET_RETENTION_ON_S3_FLOW
  env_customer_id     = var.CUSTOMER_ID
  env_dns_prefix      = var.DNS_PREFIX_FLOW
  s3_force_destroy    = var.S3_FORCE_DESTROY
  tag_key             = var.OPTIX_RESOURCE_KEY
  tag_value           = var.OPTIX_RESOURCE_VALUE
  flow_default_region = var.FLOW_ONE_REGION_VALUE
  is_single_bucket    = var.ENABLE_FLOW_ONE_REGION
  policy_depends_on   = module.avid-role
}


module "flow-logs-module-us-east-2" {
  providers = {
    aws = aws.us-east-2
  }
  source              = "../modules/flow_log_module"
  region_append       = "us-east-2"
  s3_should_run       = contains(var.FLOWLOG_REGIONS, "us-east-2") && var.FLOW_LOGS == true && "${var.ENABLE_FLOW_ONE_REGION != true || var.FLOW_ONE_REGION_VALUE == "us-east-2"}"
  fl_should_run       = contains(var.FLOWLOG_REGIONS, "us-east-2") && var.FLOW_LOGS == true
  account_id          = data.aws_caller_identity.current.account_id
  s3_bucket_prefix    = var.FLOW_LOG_S3_BUCKET_PREFIX
  expiration_days     = var.FLOW_LOGS_S3_RETENTION
  lifecycle_enabled   = var.SET_RETENTION_ON_S3_FLOW
  env_customer_id     = var.CUSTOMER_ID
  s3_force_destroy    = var.S3_FORCE_DESTROY
  env_dns_prefix      = var.DNS_PREFIX_FLOW
  tag_key             = var.OPTIX_RESOURCE_KEY
  tag_value           = var.OPTIX_RESOURCE_VALUE
  flow_default_region = var.FLOW_ONE_REGION_VALUE
  is_single_bucket    = var.ENABLE_FLOW_ONE_REGION
  policy_depends_on   = module.avid-role
}


module "flow-logs-module-eu-west-1" {
  providers = {
    aws = aws.eu-west-1
  }
  source              = "../modules/flow_log_module"
  region_append       = "eu-west-1"
  s3_should_run       = contains(var.FLOWLOG_REGIONS, "eu-west-1") && var.FLOW_LOGS == true && "${var.ENABLE_FLOW_ONE_REGION != true || var.FLOW_ONE_REGION_VALUE == "eu-west-1"}"
  fl_should_run       = contains(var.FLOWLOG_REGIONS, "eu-west-1") && var.FLOW_LOGS == true
  account_id          = data.aws_caller_identity.current.account_id
  s3_bucket_prefix    = var.FLOW_LOG_S3_BUCKET_PREFIX
  expiration_days     = var.FLOW_LOGS_S3_RETENTION
  lifecycle_enabled   = var.SET_RETENTION_ON_S3_FLOW
  env_customer_id     = var.CUSTOMER_ID
  s3_force_destroy    = var.S3_FORCE_DESTROY
  env_dns_prefix      = var.DNS_PREFIX_FLOW
  tag_key             = var.OPTIX_RESOURCE_KEY
  tag_value           = var.OPTIX_RESOURCE_VALUE
  flow_default_region = var.FLOW_ONE_REGION_VALUE
  is_single_bucket    = var.ENABLE_FLOW_ONE_REGION
  policy_depends_on   = module.avid-role
}


module "flow-logs-module-eu-west-2" {
  providers = {
    aws = aws.eu-west-2
  }
  source              = "../modules/flow_log_module"
  region_append       = "eu-west-2"
  s3_should_run       = contains(var.FLOWLOG_REGIONS, "eu-west-2") && var.FLOW_LOGS == true && "${var.ENABLE_FLOW_ONE_REGION != true || var.FLOW_ONE_REGION_VALUE == "eu-west-2"}"
  fl_should_run       = contains(var.FLOWLOG_REGIONS, "eu-west-2") && var.FLOW_LOGS == true
  account_id          = data.aws_caller_identity.current.account_id
  s3_bucket_prefix    = var.FLOW_LOG_S3_BUCKET_PREFIX
  expiration_days     = var.FLOW_LOGS_S3_RETENTION
  lifecycle_enabled   = var.SET_RETENTION_ON_S3_FLOW
  env_customer_id     = var.CUSTOMER_ID
  s3_force_destroy    = var.S3_FORCE_DESTROY
  env_dns_prefix      = var.DNS_PREFIX_FLOW
  tag_key             = var.OPTIX_RESOURCE_KEY
  tag_value           = var.OPTIX_RESOURCE_VALUE
  flow_default_region = var.FLOW_ONE_REGION_VALUE
  is_single_bucket    = var.ENABLE_FLOW_ONE_REGION
  policy_depends_on   = module.avid-role
}

module "flow-logs-module-eu-central-1" {
  providers = {
    aws = aws.eu-central-1
  }
  source              = "../modules/flow_log_module"
  region_append       = "eu-central-1"
  s3_should_run       = contains(var.FLOWLOG_REGIONS, "eu-central-1") && var.FLOW_LOGS == true && "${var.ENABLE_FLOW_ONE_REGION != true || var.FLOW_ONE_REGION_VALUE == "eu-central-1"}"
  fl_should_run       = contains(var.FLOWLOG_REGIONS, "eu-central-1") && var.FLOW_LOGS == true
  account_id          = data.aws_caller_identity.current.account_id
  s3_bucket_prefix    = var.FLOW_LOG_S3_BUCKET_PREFIX
  expiration_days     = var.FLOW_LOGS_S3_RETENTION
  lifecycle_enabled   = var.SET_RETENTION_ON_S3_FLOW
  env_customer_id     = var.CUSTOMER_ID
  s3_force_destroy    = var.S3_FORCE_DESTROY
  env_dns_prefix      = var.DNS_PREFIX_FLOW
  tag_key             = var.OPTIX_RESOURCE_KEY
  tag_value           = var.OPTIX_RESOURCE_VALUE
  flow_default_region = var.FLOW_ONE_REGION_VALUE
  is_single_bucket    = var.ENABLE_FLOW_ONE_REGION
  policy_depends_on   = module.avid-role
}


module "flow-logs-module-ap-south-1" {
  providers = {
    aws = aws.ap-south-1
  }
  source              = "../modules/flow_log_module"
  region_append       = "ap-south-1"
  s3_should_run       = contains(var.FLOWLOG_REGIONS, "ap-south-1") && var.FLOW_LOGS == true && "${var.ENABLE_FLOW_ONE_REGION != true || var.FLOW_ONE_REGION_VALUE == "ap-south-1"}"
  fl_should_run       = contains(var.FLOWLOG_REGIONS, "ap-south-1") && var.FLOW_LOGS == true
  account_id          = data.aws_caller_identity.current.account_id
  s3_bucket_prefix    = var.FLOW_LOG_S3_BUCKET_PREFIX
  expiration_days     = var.FLOW_LOGS_S3_RETENTION
  lifecycle_enabled   = var.SET_RETENTION_ON_S3_FLOW
  env_customer_id     = var.CUSTOMER_ID
  s3_force_destroy    = var.S3_FORCE_DESTROY
  env_dns_prefix      = var.DNS_PREFIX_FLOW
  tag_key             = var.OPTIX_RESOURCE_KEY
  tag_value           = var.OPTIX_RESOURCE_VALUE
  flow_default_region = var.FLOW_ONE_REGION_VALUE
  is_single_bucket    = var.ENABLE_FLOW_ONE_REGION
  policy_depends_on   = module.avid-role
}


module "flow-logs-module-ap-southeast-1" {
  providers = {
    aws = aws.ap-southeast-1
  }
  source              = "../modules/flow_log_module"
  region_append       = "ap-southeast-1"
  s3_should_run       = contains(var.FLOWLOG_REGIONS, "ap-southeast-1") && var.FLOW_LOGS == true && "${var.ENABLE_FLOW_ONE_REGION != true || var.FLOW_ONE_REGION_VALUE == "ap-southeast-1"}"
  fl_should_run       = contains(var.FLOWLOG_REGIONS, "ap-southeast-1") && var.FLOW_LOGS == true
  account_id          = data.aws_caller_identity.current.account_id
  s3_bucket_prefix    = var.FLOW_LOG_S3_BUCKET_PREFIX
  expiration_days     = var.FLOW_LOGS_S3_RETENTION
  lifecycle_enabled   = var.SET_RETENTION_ON_S3_FLOW
  env_customer_id     = var.CUSTOMER_ID
  s3_force_destroy    = var.S3_FORCE_DESTROY
  env_dns_prefix      = var.DNS_PREFIX_FLOW
  tag_key             = var.OPTIX_RESOURCE_KEY
  tag_value           = var.OPTIX_RESOURCE_VALUE
  flow_default_region = var.FLOW_ONE_REGION_VALUE
  is_single_bucket    = var.ENABLE_FLOW_ONE_REGION
  policy_depends_on   = module.avid-role
}


module "flow-logs-module-ap-southeast-2" {
  providers = {
    aws = aws.ap-southeast-2
  }
  source              = "../modules/flow_log_module"
  region_append       = "ap-southeast-2"
  s3_should_run       = contains(var.FLOWLOG_REGIONS, "ap-southeast-2") && var.FLOW_LOGS == true && "${var.ENABLE_FLOW_ONE_REGION != true || var.FLOW_ONE_REGION_VALUE == "ap-southeast-2"}"
  fl_should_run       = contains(var.FLOWLOG_REGIONS, "ap-southeast-2") && var.FLOW_LOGS == true
  account_id          = data.aws_caller_identity.current.account_id
  s3_bucket_prefix    = var.FLOW_LOG_S3_BUCKET_PREFIX
  expiration_days     = var.FLOW_LOGS_S3_RETENTION
  lifecycle_enabled   = var.SET_RETENTION_ON_S3_FLOW
  env_customer_id     = var.CUSTOMER_ID
  env_dns_prefix      = var.DNS_PREFIX_FLOW
  s3_force_destroy    = var.S3_FORCE_DESTROY
  tag_key             = var.OPTIX_RESOURCE_KEY
  tag_value           = var.OPTIX_RESOURCE_VALUE
  flow_default_region = var.FLOW_ONE_REGION_VALUE
  is_single_bucket    = var.ENABLE_FLOW_ONE_REGION
  policy_depends_on   = module.avid-role
}


module "flow-logs-module-ap-northeast-1" {
  providers = {
    aws = aws.ap-northeast-1
  }
  source              = "../modules/flow_log_module"
  region_append       = "ap-northeast-1"
  s3_should_run       = contains(var.FLOWLOG_REGIONS, "ap-northeast-1") && var.FLOW_LOGS == true && "${var.ENABLE_FLOW_ONE_REGION != true || var.FLOW_ONE_REGION_VALUE == "ap-northeast-1"}"
  fl_should_run       = contains(var.FLOWLOG_REGIONS, "ap-northeast-1") && var.FLOW_LOGS == true
  account_id          = data.aws_caller_identity.current.account_id
  s3_bucket_prefix    = var.FLOW_LOG_S3_BUCKET_PREFIX
  expiration_days     = var.FLOW_LOGS_S3_RETENTION
  lifecycle_enabled   = var.SET_RETENTION_ON_S3_FLOW
  env_customer_id     = var.CUSTOMER_ID
  s3_force_destroy    = var.S3_FORCE_DESTROY
  env_dns_prefix      = var.DNS_PREFIX_FLOW
  tag_key             = var.OPTIX_RESOURCE_KEY
  tag_value           = var.OPTIX_RESOURCE_VALUE
  flow_default_region = var.FLOW_ONE_REGION_VALUE
  is_single_bucket    = var.ENABLE_FLOW_ONE_REGION
  policy_depends_on   = module.avid-role
}


module "flow-logs-module-ap-northeast-2" {
  providers = {
    aws = aws.ap-northeast-2
  }
  source              = "../modules/flow_log_module"
  region_append       = "ap-northeast-2"
  s3_should_run       = contains(var.FLOWLOG_REGIONS, "ap-northeast-2") && var.FLOW_LOGS == true && "${var.ENABLE_FLOW_ONE_REGION != true || var.FLOW_ONE_REGION_VALUE == "ap-northeast-2"}"
  fl_should_run       = contains(var.FLOWLOG_REGIONS, "ap-northeast-2") && var.FLOW_LOGS == true
  account_id          = data.aws_caller_identity.current.account_id
  s3_bucket_prefix    = var.FLOW_LOG_S3_BUCKET_PREFIX
  expiration_days     = var.FLOW_LOGS_S3_RETENTION
  lifecycle_enabled   = var.SET_RETENTION_ON_S3_FLOW
  env_customer_id     = var.CUSTOMER_ID
  env_dns_prefix      = var.DNS_PREFIX_FLOW
  s3_force_destroy    = var.S3_FORCE_DESTROY
  tag_key             = var.OPTIX_RESOURCE_KEY
  tag_value           = var.OPTIX_RESOURCE_VALUE
  flow_default_region = var.FLOW_ONE_REGION_VALUE
  is_single_bucket    = var.ENABLE_FLOW_ONE_REGION
  policy_depends_on   = module.avid-role
}


module "flow-logs-module-ap-northeast-3" {
  providers = {
    aws = aws.ap-northeast-3
  }
  source              = "../modules/flow_log_module"
  region_append       = "ap-northeast-3"
  s3_should_run       = contains(var.FLOWLOG_REGIONS, "ap-northeast-3") && var.FLOW_LOGS == true && "${var.ENABLE_FLOW_ONE_REGION != true || var.FLOW_ONE_REGION_VALUE == "ap-northeast-3"}"
  fl_should_run       = contains(var.FLOWLOG_REGIONS, "ap-northeast-3") && var.FLOW_LOGS == true
  account_id          = data.aws_caller_identity.current.account_id
  s3_bucket_prefix    = var.FLOW_LOG_S3_BUCKET_PREFIX
  expiration_days     = var.FLOW_LOGS_S3_RETENTION
  lifecycle_enabled   = var.SET_RETENTION_ON_S3_FLOW
  env_customer_id     = var.CUSTOMER_ID
  env_dns_prefix      = var.DNS_PREFIX_FLOW
  s3_force_destroy    = var.S3_FORCE_DESTROY
  tag_key             = var.OPTIX_RESOURCE_KEY
  tag_value           = var.OPTIX_RESOURCE_VALUE
  flow_default_region = var.FLOW_ONE_REGION_VALUE
  is_single_bucket    = var.ENABLE_FLOW_ONE_REGION
  policy_depends_on   = module.avid-role
}


module "flow-logs-module-sa-east-1" {
  providers = {
    aws = aws.sa-east-1
  }
  source              = "../modules/flow_log_module"
  region_append       = "sa-east-1"
  s3_should_run       = contains(var.FLOWLOG_REGIONS, "sa-east-1") && var.FLOW_LOGS == true && "${var.ENABLE_FLOW_ONE_REGION != true || var.FLOW_ONE_REGION_VALUE == "sa-east-1"}"
  fl_should_run       = contains(var.FLOWLOG_REGIONS, "sa-east-1") && var.FLOW_LOGS == true
  account_id          = data.aws_caller_identity.current.account_id
  s3_bucket_prefix    = var.FLOW_LOG_S3_BUCKET_PREFIX
  expiration_days     = var.FLOW_LOGS_S3_RETENTION
  lifecycle_enabled   = var.SET_RETENTION_ON_S3_FLOW
  env_customer_id     = var.CUSTOMER_ID
  s3_force_destroy    = var.S3_FORCE_DESTROY
  env_dns_prefix      = var.DNS_PREFIX_FLOW
  tag_key             = var.OPTIX_RESOURCE_KEY
  tag_value           = var.OPTIX_RESOURCE_VALUE
  flow_default_region = var.FLOW_ONE_REGION_VALUE
  is_single_bucket    = var.ENABLE_FLOW_ONE_REGION
  policy_depends_on   = module.avid-role
}


module "flow-logs-module-ca-central-1" {
  providers = {
    aws = aws.ca-central-1
  }
  source              = "../modules/flow_log_module"
  region_append       = "ca-central-1"
  s3_should_run       = contains(var.FLOWLOG_REGIONS, "ca-central-1") && var.FLOW_LOGS == true && "${var.ENABLE_FLOW_ONE_REGION != true || var.FLOW_ONE_REGION_VALUE == "ca-central-1"}"
  fl_should_run       = contains(var.FLOWLOG_REGIONS, "ca-central-1") && var.FLOW_LOGS == true
  account_id          = data.aws_caller_identity.current.account_id
  s3_bucket_prefix    = var.FLOW_LOG_S3_BUCKET_PREFIX
  expiration_days     = var.FLOW_LOGS_S3_RETENTION
  lifecycle_enabled   = var.SET_RETENTION_ON_S3_FLOW
  env_customer_id     = var.CUSTOMER_ID
  env_dns_prefix      = var.DNS_PREFIX_FLOW
  s3_force_destroy    = var.S3_FORCE_DESTROY
  tag_key             = var.OPTIX_RESOURCE_KEY
  tag_value           = var.OPTIX_RESOURCE_VALUE
  flow_default_region = var.FLOW_ONE_REGION_VALUE
  is_single_bucket    = var.ENABLE_FLOW_ONE_REGION
  policy_depends_on   = module.avid-role
}


module "flow-logs-module-eu-west-3" {
  providers = {
    aws = aws.eu-west-3
  }
  source              = "../modules/flow_log_module"
  region_append       = "eu-west-3"
  s3_should_run       = contains(var.FLOWLOG_REGIONS, "eu-west-3") && var.FLOW_LOGS == true && "${var.ENABLE_FLOW_ONE_REGION != true || var.FLOW_ONE_REGION_VALUE == "eu-west-3"}"
  fl_should_run       = contains(var.FLOWLOG_REGIONS, "eu-west-3") && var.FLOW_LOGS == true
  account_id          = data.aws_caller_identity.current.account_id
  s3_bucket_prefix    = var.FLOW_LOG_S3_BUCKET_PREFIX
  expiration_days     = var.FLOW_LOGS_S3_RETENTION
  lifecycle_enabled   = var.SET_RETENTION_ON_S3_FLOW
  env_customer_id     = var.CUSTOMER_ID
  env_dns_prefix      = var.DNS_PREFIX_FLOW
  s3_force_destroy    = var.S3_FORCE_DESTROY
  tag_key             = var.OPTIX_RESOURCE_KEY
  tag_value           = var.OPTIX_RESOURCE_VALUE
  flow_default_region = var.FLOW_ONE_REGION_VALUE
  is_single_bucket    = var.ENABLE_FLOW_ONE_REGION
  policy_depends_on   = module.avid-role
}


module "flow-logs-module-eu-north-1" {
  providers = {
    aws = aws.eu-north-1
  }
  source              = "../modules/flow_log_module"
  region_append       = "eu-north-1"
  s3_should_run       = contains(var.FLOWLOG_REGIONS, "eu-north-1") && var.FLOW_LOGS == true && "${var.ENABLE_FLOW_ONE_REGION != true || var.FLOW_ONE_REGION_VALUE == "eu-north-1"}"
  fl_should_run       = contains(var.FLOWLOG_REGIONS, "eu-north-1") && var.FLOW_LOGS == true
  account_id          = data.aws_caller_identity.current.account_id
  s3_bucket_prefix    = var.FLOW_LOG_S3_BUCKET_PREFIX
  expiration_days     = var.FLOW_LOGS_S3_RETENTION
  lifecycle_enabled   = var.SET_RETENTION_ON_S3_FLOW
  env_customer_id     = var.CUSTOMER_ID
  s3_force_destroy    = var.S3_FORCE_DESTROY
  env_dns_prefix      = var.DNS_PREFIX_FLOW
  tag_key             = var.OPTIX_RESOURCE_KEY
  tag_value           = var.OPTIX_RESOURCE_VALUE
  flow_default_region = var.FLOW_ONE_REGION_VALUE
  is_single_bucket    = var.ENABLE_FLOW_ONE_REGION
  policy_depends_on   = module.avid-role
}



###############Cloudtrail Log Configuration###############
module "cloudtrail-logs-module" {
  source            = "../modules/cloudtrail_log_module"
  should_run        = var.CLOUDTRAIL_LOGS == true
  account_id        = data.aws_caller_identity.current.account_id
  s3_bucket_prefix  = var.CLOUDTRAIL_S3_BUCKET_PREFIX
  expiration_days   = var.CLOUDTRAIL_S3_RETENTION
  lifecycle_enabled = var.SET_RETENTION_ON_S3_CLOUDTRAIL
  env_customer_id   = var.CUSTOMER_ID
  tag_key           = var.OPTIX_RESOURCE_KEY
  tag_value         = var.OPTIX_RESOURCE_VALUE
  env_dns_prefix    = var.DNS_PREFIX_CLOUDTRAIL
  region            = var.AWS_DEFAULT_REGION
  policy_depends_on = module.avid-role
  s3_force_destroy  = var.S3_FORCE_DESTROY
}