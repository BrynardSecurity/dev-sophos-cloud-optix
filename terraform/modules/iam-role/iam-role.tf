variable "name" { }
variable "assume_role_policy_file" { }
variable "external_id" { default = "" }
variable "tag_key" { }
variable "tag_value" { }

data "template_file" "policy" {
  template                    = "${file("${path.module}/${var.assume_role_policy_file}")}"
  vars = {
    external_id = var.external_id
  }
}

resource "aws_iam_role" "iam-role" {
  name               = var.name
  assume_role_policy = data.template_file.policy.rendered
  tags = {
  (var.tag_key) = var.tag_value
  } 
}

output "iam-role-name" { value = "${aws_iam_role.iam-role.name}" }
output "iam-role-arn" { value = "${aws_iam_role.iam-role.arn}" }
