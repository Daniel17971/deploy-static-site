variable "domain_name" {
  type        = string
  description = "the domain name of your hosted zone in aws"
}

variable "site_dist_path" {
  type        = string
  description = "Path to the built static site directory to upload to S3"
}
