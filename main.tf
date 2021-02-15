
provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

resource "aws_iam_role" "DataLakeWorkflowRole"
{
  name ="DataLakeWorkflowRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid : "LakeFormation"
        Effect = "Allow"
        Action = ["lakeformation:GetDataAccess","lakeformation:GetPermissions"]
      }
      resources = ["*"]
    ]
    })
}

resource "aws_iam_role_policy_attachment" "AWSGlueServiceRoleAttach" {
  role = "DataLakeWorkflowRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
