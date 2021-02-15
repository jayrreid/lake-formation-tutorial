output "DataLakeWorkflowRole" {
  description = "datalake workflow role"
  value       = aws_iam_role.DataLakeWorkflowRole
}

output "DataLakeAdministrator" {
  description = "datalake administrator"
  value       = aws_iam_user.dl_admin
}
