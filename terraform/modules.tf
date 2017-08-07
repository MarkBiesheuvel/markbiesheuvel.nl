module "website" {
  source  = "website"
  url     = "${var.url}"
  aliases = "${var.aliases}"
}

module "dns" {
  source                         = "dns"
  url                            = "${var.url}"
  domains                        = "${var.domains}"
  mx_records                     = "${var.mx_records}"
  keybase_verification           = "${var.keybase_verification}"
  google_verification            = "${var.google_verification}"
  website_cloudfront_domain_name = "${module.website.cloudfront_domain_name}"
  website_cloudfront_zone_id     = "${module.website.cloudfront_zone_id}"
}

module "codepipeline" {
  source                             = "codepipeline"
  url                                = "${var.url}"
  name                               = "${replace("${var.url}", ".", "-")}"
  website_s3_name                    = "${module.website.s3_name}"
  website_s3_arn                     = "${module.website.s3_arn}"
  website_cloudfront_distribution_id = "${module.website.cloudfront_distribution_id}"
}
