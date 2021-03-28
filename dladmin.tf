
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

#
# Data Lake Admins, Create Database and Default Permissions
#
resource "aws_lakeformation_data_lake_settings" "datalake_admins" {
  admins = [aws_iam_user.dl_admin.arn]
}
