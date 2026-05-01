variable "region" {
  type        = string
  default     = "us-west-2"
}

variable "domain_name" {
  type        = string
  description = "Route53 hosted zone domain"
}
