output "cloudfront_domain" {
  value = aws_cloudfront_distribution.site.domain_name
}
