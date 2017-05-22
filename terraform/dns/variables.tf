variable "url" {
  type = "string"
}

variable "website_cloudfront_domain_name" {
  type = "string"
}

variable "website_cloudfront_zone_id" {
  type = "string"
}

variable "domains" {
  type = "list"
}

variable "mx_records" {
  type    = "list"
  default = []
}

variable "keybase_verification" {
  type    = "map"
  default = {}
}
