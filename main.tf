
provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

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
          Service = "ec2.amazonaws.com"
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
        "Resources": "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AWSGlueServiceRoleAttach" {
  role = "DataLakeWorkflowRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
