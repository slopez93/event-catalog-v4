output "bucket_name" {
  description = "S3 bucket for the built EventCatalog files."
  value       = aws_s3_bucket.site.bucket
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID, used for cache invalidations."
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_domain_name" {
  description = "Public CloudFront hostname."
  value       = aws_cloudfront_distribution.site.domain_name
}

output "site_url" {
  description = "HTTPS URL for the deployed EventCatalog."
  value       = "https://${aws_cloudfront_distribution.site.domain_name}"
}
