output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID — used to trigger cache invalidations after a deploy."
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name (useful for debugging before DNS propagates)."
  value       = aws_cloudfront_distribution.site.domain_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket that holds the static site files."
  value       = aws_s3_bucket.site.bucket
}

output "site_url" {
  description = "Public URL of the site."
  value       = "https://${var.domain_name}"
}
