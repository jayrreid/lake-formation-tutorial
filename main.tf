
provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

data "aws_iam_role" "DataLakeWorkflowRole" {
  name ="DataLakeWorkflowRole"
}

resource "aws_iam_role_policy" "DataLakeWorkflowRolePolicy" {
  name ="DataLakeWorkflowRolePolicy"
  role = aws_iam_roile.DataLakeWorkflowRole.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid : "LakeFormation"
        Effect = "Allow"
        Action = ["lakeformation:GetDataAccess","lakeformation:GetPermissions"]
        resources = ["*"]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AWSGlueServiceRoleAttach" {
  role = "DataLakeWorkflowRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
