variable "region_append" { }
variable "account_id" { }
variable "s3_should_run" { }
variable "expiration_days" { }
variable "env_customer_id" { }
variable "env_dns_prefix" { }
variable "env_dns_path" { default = "s3key/vpclogs" }
variable "fl_should_run" { }
variable "flow_default_region" { }
variable "is_single_bucket" { }
variable "lifecycle_enabled" { }
variable "tag_key" { }
variable "tag_value" { }
variable "policy_depends_on" { }
variable "s3_dependency" { default = "" }
variable "s3_bucket_prefix" { }
variable "s3_force_destroy" { }


###########S3 bucket##############
resource "aws_s3_bucket" "avid" {
    count = var.s3_should_run == true ? 1 : 0
    bucket = "${var.s3_bucket_prefix}-${var.account_id}-${var.region_append}"
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
    tags = {
  (var.tag_key) = var.tag_value
  }     
}
output "s3-arn" { value = aws_s3_bucket.avid.*.arn}
output "s3-id" { value = aws_s3_bucket.avid.*.id}
output "region-append" { value = var.region_append }

resource "null_resource" "previous" {
  depends_on = [aws_s3_bucket.avid]
}

resource "time_sleep" "wait_2_seconds" {
  depends_on = [null_resource.previous]
  create_duration = "2s"
}
resource "null_resource" "next" {
  depends_on = [time_sleep.wait_2_seconds]
}

##########Iam Role Policy#########
data "template_file" "avid" {
  template = "${file("${path.module}/policies/flowlogss3policy.json.tpl")}"
  vars = {
    bucket_name = "${var.s3_bucket_prefix}-${var.account_id}-${var.region_append}"
    bucket_folder = "sophos-optix-flowlogs"
  }
}

data "template_file" "policy" {
  template                    = "${file("${path.module}/policies/optix-log-read-policy.json.tpl")}"
  vars = {
    s3_name = "${var.s3_bucket_prefix}-${var.account_id}-${var.region_append}"
  }
}
resource "aws_iam_role_policy" "avid" {
  count = var.s3_should_run == true ? 1 : 0
  name = "Sophos-Optix-flowlogs-read-policy-${var.region_append}"
  role = "Sophos-Optix-role"
  policy = data.template_file.policy.rendered
  depends_on = [
    var.policy_depends_on
  ]

}

resource "aws_s3_bucket_policy" "avid" {
  count = var.s3_should_run == true ? 1 : 0
  bucket = "${var.s3_bucket_prefix}-${var.account_id}-${var.region_append}"
  policy = data.template_file.avid.rendered
  depends_on = [aws_s3_bucket.avid]
}

###########Lambda Function############
resource "aws_lambda_function" "avid" {
  count = var.s3_should_run == true ? 1 : 0
  function_name = "Sophos-Optix-flowlogs-fn"
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
    count = var.s3_should_run == true ? 1 : 0
    name = "Sophos-Optix-flowlogs-s3-sns-topic"
    policy = <<POLICY
    {
	    "Version": "2012-10-17",
	    "Statement": [
		    {
			    "Sid": "OptixSNSpermission20150201",
			    "Action": ["SNS:Publish"],
			    "Effect": "Allow",
			    "Resource": "arn:aws:sns:${var.region_append}:${var.account_id}:Sophos-Optix-flowlogs-s3-sns-topic",
			    "Principal": {
			    		"Service": "s3.amazonaws.com"
			    	},
			    "Condition": {
			    		"StringEquals": {
			    			"AWS:SourceArn": "arn:aws:s3:::${var.s3_bucket_prefix}-${var.account_id}-${var.region_append}"
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
  count = var.s3_should_run == true ? 1 : 0
  topic_arn = aws_sns_topic.avid[count.index].arn
  protocol = "lambda"
  endpoint = aws_lambda_function.avid[count.index].arn
}

############S3 Event trigger##############
resource "aws_s3_bucket_notification" "avid" {
    count = var.s3_should_run == true ? 1 : 0
    bucket = "${var.s3_bucket_prefix}-${var.account_id}-${var.region_append}"
    topic {
        id = "s3eventtriggersSNS"
        topic_arn = aws_sns_topic.avid[count.index].arn
        events = ["s3:ObjectCreated:*"]
        filter_prefix = "sophos-optix-flowlogs/AWSLogs/${var.account_id}/"
        filter_suffix = ".log.gz"
    }
   depends_on = [aws_s3_bucket.avid] 
}

###################Lambda Permission############
resource "aws_lambda_permission" "avid" {
    count = var.s3_should_run == true ? 1 : 0
    statement_id = "givessnspermissionflow${var.account_id}${var.region_append}"
    action = "lambda:InvokeFunction"
    function_name = "Sophos-Optix-flowlogs-fn"
    principal = "sns.amazonaws.com"
    source_arn = aws_sns_topic.avid[count.index].arn
}

####################Flow Logs###################
data "aws_vpcs" "list" {
  count = var.fl_should_run == true ? 1 : 0
 }
resource "aws_flow_log" "fl" {
  count = var.fl_should_run == true ? length(data.aws_vpcs.list[0].ids) : 0
  traffic_type = "ACCEPT"
  log_destination_type = "s3"
  log_format="$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${vpc-id} $${subnet-id} $${instance-id} $${type} $${pkt-srcaddr} $${pkt-dstaddr} $${region} $${az-id} $${pkt-src-aws-service} $${pkt-dst-aws-service} $${flow-direction} $${traffic-path}"
  log_destination = var.is_single_bucket ? "arn:aws:s3:::${var.s3_bucket_prefix}-${var.account_id}-${var.flow_default_region}/sophos-optix-flowlogs/" : "arn:aws:s3:::${var.s3_bucket_prefix}-${var.account_id}-${var.region_append}/sophos-optix-flowlogs/"
  vpc_id = tolist(data.aws_vpcs.list[0].ids)[count.index]
  tags = {
  (var.tag_key) = var.tag_value
}
  depends_on = [null_resource.next]
}