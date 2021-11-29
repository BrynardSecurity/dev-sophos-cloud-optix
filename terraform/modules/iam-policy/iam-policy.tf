variable "name" { }
variable "policy_file" { }
variable "default_region" { default = "" }
variable "user_account" { default = "" }
variable "flow_log_bucket" { default = "" }
variable "flow_log_folder" { default = "" }
variable "lambda_name" { default = "" }

data "template_file" "policy" {
  template                    = "${file("${path.module}/policies/${var.policy_file}")}"
  vars = {
    default_region = var.default_region
    user_account = var.user_account
    flow_log_bucket = var.flow_log_bucket
    flow_log_folder = var.flow_log_folder
    lambda_name = var.lambda_name
  }
}

resource "aws_iam_policy" "policy" {
  name                        = var.name
  policy                      = data.template_file.policy.rendered
}

output "iam-policy-id" { value = "${aws_iam_policy.policy.id}" }
output "iam-policy-arn" { value = "${aws_iam_policy.policy.arn}" }
output "iam-policy-name" { value = "${aws_iam_policy.policy.name}" }
