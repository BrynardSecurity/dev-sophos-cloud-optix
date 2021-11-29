variable "should_run" { }
variable "expiration_days" { }
variable "env_customer_id" { }
variable "env_dns_prefix" {  }
variable "env_dns_path" { default = "s3key/cloudtraillogs" }
variable "account_id" { }
variable "region" { }
variable "lifecycle_enabled" { }
variable "tag_key" { }
variable "tag_value" { }
variable "policy_depends_on" { }
variable "s3_bucket_prefix" { }
variable "s3_force_destroy" {  }



###########S3 bucket##############
data "template_file" "avid" {
  template = "${file("${path.module}/policies/cloudtrails3policy.json.tpl")}"
  vars = {
    bucket_name = "${var.s3_bucket_prefix}-${var.account_id}"
    bucket_folder = "sophos-optix-cloudtrail"
  }
}

resource "aws_s3_bucket" "avid" {
count = var.should_run == true ? 1 : 0
bucket = "${var.s3_bucket_prefix}-${var.account_id}"
acl    = "private"
force_destroy = var.s3_force_destroy

lifecycle_rule {
  id = "s3flowsdeleteafterNdays"
  prefix = ""
  enabled = var.lifecycle_enabled
  noncurrent_version_expiration {
    days = var.expiration_days
  }
}

server_side_encryption_configuration {
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = "aws/s3"
      sse_algorithm = "aws:kms"
    }
  }
}
tags = {
  (var.tag_key) = var.tag_value
}
}

output "s3-arn" { value = "aws_s3_bucket.bucket.arn"}

resource "aws_s3_bucket_policy" "avid" {
count = var.should_run == true ? 1 : 0
bucket = "${var.s3_bucket_prefix}-${var.account_id}"
policy = data.template_file.avid.rendered
depends_on = [aws_s3_bucket.avid]
}

data "template_file" "policy" {
  template                    = "${file("${path.module}/policies/optix-log-read-policy.json.tpl")}"
  vars = {
    s3_name = "${var.s3_bucket_prefix}-${var.account_id}"
  }
}
resource "aws_iam_role_policy" "avid" {
  count = var.should_run == true ? 1 : 0
  name = "Sophos-Optix-cloudtrail-read-policy"
  role = "Sophos-Optix-role"
  policy = data.template_file.policy.rendered
  depends_on = [
    var.policy_depends_on
  ]
}


###########Lambda Function############
resource "aws_lambda_function" "avid" {
  count = var.should_run == true ? 1 : 0
  function_name = "Sophos-Optix-cloudtrail-fn"
  filename = "collector-v2-sns-lambda.zip"
  handler = "collector-v2-sns-lambda.lambda_handler"
  role = "arn:aws:iam::${var.account_id}:role/Sophos-Optix-lambda-logging-role"
  memory_size = "128"
  runtime = "python3.8"
  timeout = "120"
  environment {
    variables = {
      CUSTOMER_ID = var.env_customer_id
      DNS_PREFIX = var.env_dns_prefix
      DNS_PATH = var.env_dns_path
    }
  }
  tags = {
  (var.tag_key) = var.tag_value
}
}

###########SNS Topic##############
resource "aws_sns_topic" "avid" {
  count = var.should_run == true ? 1 : 0
    name = "Sophos-Optix-cloudtrail-s3-sns-topic"
    policy = <<POLICY
    {
	    "Version": "2012-10-17",
	    "Statement": [
		    {
			    "Sid": "OptixSNSpermission20150201",
			    "Action": ["SNS:Publish"],
			    "Effect": "Allow",
			    "Resource": "arn:aws:sns:${var.region}:${var.account_id}:Sophos-Optix-cloudtrail-s3-sns-topic",
			    "Principal": {
			    		"Service": "s3.amazonaws.com"
			    	},
			    "Condition": {
			    		"StringEquals": {
			    			"AWS:SourceArn": "arn:aws:s3:::${var.s3_bucket_prefix}-${var.account_id}"
			    			}
			    }
		    }
	    ]
        }
    POLICY
    tags = {
  (var.tag_key) = var.tag_value
  }
  depends_on = [aws_s3_bucket.avid]
}
output "sns-id" { value = "${aws_sns_topic.avid.*.id}" }
output "sns-arn" { value = "${aws_sns_topic.avid.*.arn}" }

############SNS Topic Subscribe##########
resource "aws_sns_topic_subscription" "avid" {
  count = var.should_run == true ? 1 : 0
  topic_arn = aws_sns_topic.avid[count.index].arn
  protocol = "lambda"
  endpoint = aws_lambda_function.avid[count.index].arn
}

############S3 Event trigger##############
resource "aws_s3_bucket_notification" "avid" {
  count = var.should_run == true ? 1 : 0
    bucket = "${var.s3_bucket_prefix}-${var.account_id}"
    topic {
        id = "s3eventtriggersSNS"
        topic_arn = aws_sns_topic.avid[count.index].arn
        events = ["s3:ObjectCreated:*"]
        filter_prefix = "sophos-optix-cloudtrail/AWSLogs/${var.account_id}/CloudTrail/"
        filter_suffix = ".json.gz"
    }
    depends_on = [aws_s3_bucket.avid]
}

###################Lambda Permission############
resource "aws_lambda_permission" "avid" {
  count = var.should_run == true ? 1 : 0
    statement_id = "givessnspermissioncloudtrail${var.account_id}${var.region}"
    action = "lambda:InvokeFunction"
    function_name = "Sophos-Optix-cloudtrail-fn"
    principal = "sns.amazonaws.com"
    source_arn = aws_sns_topic.avid[count.index].arn
}

####################Cloudtrail##################
resource "aws_cloudtrail" "avid" {
  count = var.should_run == true ? 1 : 0
  name = "Sophos-Optix-cloudtrail"
  s3_bucket_name = "${var.s3_bucket_prefix}-${var.account_id}"
  s3_key_prefix = "sophos-optix-cloudtrail"
  include_global_service_events = true
  is_multi_region_trail = true
  enable_log_file_validation = true
  depends_on = [aws_s3_bucket_policy.avid]
  tags = {
  (var.tag_key) = var.tag_value
}
}