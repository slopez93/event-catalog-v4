locals {
  project_name                 = "service-catalog-v4"
  s3_bucket_name               = local.project_name
  cloudfront_distribution_name = local.project_name
}
