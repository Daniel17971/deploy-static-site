variable "domain_name" {
  description = "The apex domain name for the site (e.g. example.com). A Route53 hosted zone must already exist for this domain."
  type        = string
}
