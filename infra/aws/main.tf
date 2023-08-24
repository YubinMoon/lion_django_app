terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-2"
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "lion-vpc"
  }
}

# Create IAM user
resource "aws_iam_user" "dev" {
  for_each = toset(["terry", "lime", "sernoo"])

  name = each.key
  path = "/dev/"
}

resource "aws_iam_access_key" "lb" {
  for_each = aws_iam_user.dev
  user     = each.value.name
}

data "aws_iam_policy_document" "lb_ro" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
}

# resource "aws_iam_user_policy" "lb_ro" {
#   name   = "test"
#   user   = aws_iam_user.lb.name
#   policy = data.aws_iam_policy_document.lb_ro.json
# }

# resource "aws_iam_user_login_profile" "lb-login" {
#   user = aws_iam_user.lb.name
# }

# output "password" {
#   value = aws_iam_user_login_profile.lb-login.password
# }

# resource "local_file" "users" {
#   content  = aws_iam_user_login_profile.lb-login.password
#   filename = "${path.module}/users.txt"
# }
