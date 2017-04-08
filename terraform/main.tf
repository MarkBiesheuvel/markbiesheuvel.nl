provider "aws" {
  region = "us-east-1"
}

variable "repo" {
  type = "string"
}

variable "url" {
  type = "string"
}

variable "aliases" {
  type = "list"
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

module "website" {
  source  = "website"
  url     = "${var.url}"
  aliases = "${var.aliases}"
}

module "dns" {
  source                 = "dns"
  url                    = "${var.url}"
  domains                = "${var.domains}"
  mx_records             = "${var.mx_records}"
  keybase_verification   = "${var.keybase_verification}"
  cloudfront_domain_name = "${module.website.cloudfront_domain_name}"
  cloudfront_zone_id     = "${module.website.cloudfront_zone_id}"
}

module "codepipeline" {
  source = "codepipeline"
  url    = "${var.url}"
}
