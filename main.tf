
provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

data "aws_caller_identity" "current" {}

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
      }
    ]
  })
}


resource "aws_iam_role_policy" "DataLakeWorkflow" {
  name ="DataLakeWorkflow"
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
      }
    ]
  })
}
