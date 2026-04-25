output "state_bucket_name" {
  value = module.state_bucket.s3_bucket_id
}
output "lock_table_name" {
  value = module.lock_table.dynamodb_table_id
}
