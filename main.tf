
provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

data "aws_caller_identity" "current" {}

data "aws_iam_user" "administrator" {
  user_name = "Administrator"
}

/*
 Create an IAM Role for Workflows
*/
resource "aws_iam_role" "DataLakeWorkflowRole" {
  name ="DataLakeWorkflowRole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "glue.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_role_policy" "DataLakeWorkflowRolePolicy" {
  name ="DataLakeWorkflowRolePolicy"
  role = aws_iam_role.DataLakeWorkflowRole.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "LakeFormation",
        "Effect": "Allow",
        "Action": [
          "lakeformation:GetDataAccess",
          "lakeformation:GetPermissions"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": ["iam:PassRole"],
        "Resource": [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/DataLakeWorkflowRole"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AWSGlueServiceRoleAttach" {
  role = aws_iam_role.DataLakeWorkflowRole.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "DataAccessPolicyForS3" {
  name ="DataAccessPolicyForS3"
  role = aws_iam_role.DataLakeWorkflowRole.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "s3:GetObject",
        "Resource": ["arn:aws:s3:::${var.s3bucket_name}/*"]
      }
    ]
  })
}
