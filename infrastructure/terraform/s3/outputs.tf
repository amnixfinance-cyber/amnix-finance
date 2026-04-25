output "loki_bucket" { value = module.loki_bucket.s3_bucket_id }
output "tempo_bucket" { value = module.tempo_bucket.s3_bucket_id }
output "mlflow_bucket" { value = module.mlflow_bucket.s3_bucket_id }
output "velero_bucket" { value = module.velero_bucket.s3_bucket_id }
