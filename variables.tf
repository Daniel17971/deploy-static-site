variable "domain_name" {
  type = string
  description = "the domain name of your hosted zone in aws"
}

variable "bucket_name" {
  type = string
  description = "the bucket name should match domain"
  default = var.domain_name
}