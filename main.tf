
provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

data "aws_caller_identity" "current" {}

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
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AWSGlueServiceRoleAttach" {
  role = aws_iam_role.DataLakeWorkflowRole.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}


/*
Create a Data Lake Administrator
*/
resource "aws_iam_user" "dl_admin" {
  name = "dl_admin"
  force_destroy = true
}

resource "aws_iam_user_policy_attachment" "Attach-AWSLakeFormationDataAdmin" {
  user       = aws_iam_user.dl_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLakeFormationDataAdmin"
}

resource "aws_iam_user_policy_attachment" "Attach-CloudWatchFullAccess" {
  user       = aws_iam_user.dl_admin.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_user_policy_attachment" "Attach-CloudWatchLogsReadOnlyAccess" {
  user       = aws_iam_user.dl_admin.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess"
}

resource "aws_iam_user_policy_attachment" "Attach-AWSLakeFormationCrossAccountManager" {
  user       = aws_iam_user.dl_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLakeFormationCrossAccountManager"
}

resource "aws_iam_user_policy_attachment" "Attach-AmazonAthenaFullAccess" {
  user       = aws_iam_user.dl_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
}

resource "aws_iam_user_policy" "DataLakeSLR" {
  name = "DataLakeSLR"
  user = aws_iam_user.dl_admin.name

  policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "iam:CreateServiceLinkedRole",
          "Resource": "*",
          "Condition": {
              "StringEquals": {
                  "iam:AWSServiceName": "lakeformation.amazonaws.com"
                }
              }
          },
          {
              "Effect": "Allow",
              "Action": [
                 "iam:PutRolePolicy"
               ],
               "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/lakeformation.amazonaws.com/AWSServiceRoleForLakeFormationDataAccess"
          }
        ]
    })
}

resource "aws_iam_user_policy" "UserPassRole" {
  name = "UserPassRole"
  user = aws_iam_user.dl_admin.name

  policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
            "Sid": "PassRolePermissions",
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
              ],
            "Resource": [
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/DataLakeWorkflowRole"
            ]
        }
      ]
    })
}

resource "aws_iam_user_policy" "RAMAccess" {
  name = "RAMAccess"
  user = aws_iam_user.dl_admin.name

  policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "ram:AcceptResourceShareInvitation",
              "ram:RejectResourceShareInvitation",
              "ec2:DescribeAvailabilityZones",
              "ram:EnableSharingWithAwsOrganization"
            ],
            "Resource": "*"
        }
      ]
    })
}
