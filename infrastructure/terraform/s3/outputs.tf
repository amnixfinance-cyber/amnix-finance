output "loki_chunks_bucket" { value = module.loki_chunks_bucket.s3_bucket_id }
output "loki_ruler_bucket"  { value = module.loki_ruler_bucket.s3_bucket_id }
output "tempo_bucket"       { value = module.tempo_bucket.s3_bucket_id }
output "mlflow_bucket"      { value = module.mlflow_bucket.s3_bucket_id }
output "velero_bucket"      { value = module.velero_bucket.s3_bucket_id }
output "cnpg_bucket"        { value = module.cnpg_bucket.s3_bucket_id }
output "risingwave_bucket"  { value = module.risingwave_bucket.s3_bucket_id }
