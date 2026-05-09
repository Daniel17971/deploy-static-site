output "website_url" {
  value = "http://${aws_s3_bucket_website_configuration.website_bucket_config.website_endpoint}"
}