
#
# Data Lake Admins, Create Database and Default Permissions
#
resource "aws_lakeformation_data_lake_settings" "datalake_admins" {
  admins = [aws_iam_user.dl_admin.arn]
}

#
# Create S3 bucket
#
resource "aws_s3_bucket" "LF_bucket_resource" {
  bucket = "${var.s3bucket_name}"

  tags = {
    Name        = "${var.s3bucket_name}"
    Environment = "Dev"
  }
}

#
# Registers a Lake Formation resource (e.g. S3 bucket)
# as managed by the Data Catalog.
#
resource "aws_lakeformation_resource" "LF_Resource" {
  arn = aws_s3_bucket.LF_bucket_resource.arn
}


#
# Grant Permissions For A Lake Formation S3 Resource
#
resource "aws_lakeformation_permissions" "LF_Permission" {
  principal   = aws_iam_role.DataLakeWorkflowRole.arn
  permissions = ["DATA_LOCATION_ACCESS"]

  data_location {
    arn = aws_lakeformation_resource.LF_Resource.arn
  }
}
