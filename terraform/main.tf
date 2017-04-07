provider "aws" {
  region = "us-east-1"
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
  type = "map"
  default = {}
}

/*
# Known issue: https://forums.aws.amazon.com/thread.jspa?threadID=249559
# Can not use data tag until old certificate is deleted

data "aws_acm_certificate" "main" {
  domain   = "${var.url}"
  statuses = ["ISSUED"]
}
*/
variable "certificate_arn" {
  default = "arn:aws:acm:us-east-1:312701731826:certificate/054196d8-6cfb-4442-96f5-9fdea2f1dd4a"
}

resource "aws_s3_bucket" "main" {
  bucket = "${var.url}"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }

  tags {
    Type = "Website"
    Url  = "${var.url}"
  }
}

resource "aws_cloudfront_distribution" "main" {

  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2"
  default_root_object = "index.html"
  aliases             = "${var.aliases}"

  origin {
    domain_name = "${aws_s3_bucket.main.bucket_domain_name}"
    origin_id   = "S3"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    /* acm_certificate_arn            = "${data.aws_acm_certificate.main.arn}" */
    acm_certificate_arn            = "${var.certificate_arn}"
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1"
    ssl_support_method             = "sni-only"
  }

  tags {
    Type = "Website"
    Url  = "${var.url}"
  }
}

resource "aws_route53_zone" "all" {
  count = "${length(var.domains)}"
  name = "${element(var.domains, count.index)}"

  tags {
    Type = "Website"
    Url  = "${var.url}"
  }
}

resource "aws_route53_record" "naked_domains" {
  count = "${aws_route53_zone.all.count}"
  zone_id = "${element(aws_route53_zone.all.*.zone_id, count.index)}"
  name    = "${element(aws_route53_zone.all.*.name, count.index)}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.main.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.main.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "wildcard_domains" {
  count = "${aws_route53_zone.all.count}"
  zone_id = "${element(aws_route53_zone.all.*.zone_id, count.index)}"
  name    = "*.${element(aws_route53_zone.all.*.name, count.index)}"
  type    = "A"

  alias {
    name                   = "${element(aws_route53_record.naked_domains.*.name, count.index)}"
    zone_id                = "${element(aws_route53_record.naked_domains.*.zone_id, count.index)}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "name_servers" {
  count = "${aws_route53_zone.all.count}"
  zone_id = "${element(aws_route53_zone.all.*.zone_id, count.index)}"
  name    = "${element(aws_route53_zone.all.*.name, count.index)}"
  type    = "NS"
  ttl     = "172800"

  records = [
    "${element(aws_route53_zone.all.*.name_servers.0, count.index)}",
    "${element(aws_route53_zone.all.*.name_servers.1, count.index)}",
    "${element(aws_route53_zone.all.*.name_servers.2, count.index)}",
    "${element(aws_route53_zone.all.*.name_servers.3, count.index)}",
  ]
}

resource "aws_route53_record" "mx" {
  count = "${aws_route53_zone.all.count}"
  zone_id = "${element(aws_route53_zone.all.*.zone_id, count.index)}"
  name    = "${element(aws_route53_zone.all.*.name, count.index)}"
  type    = "MX"
  ttl     = "86400"

  records = "${var.mx_records}"
}

resource "aws_route53_record" "keybase" {
  count = "${aws_route53_zone.all.count}"
  zone_id = "${element(aws_route53_zone.all.*.zone_id, count.index)}"
  name    = "${element(aws_route53_zone.all.*.name, count.index)}"
  type    = "TXT"
  ttl     = "86400"

  records = [
    "keybase-site-verification=${var.keybase_verification[element(aws_route53_zone.all.*.name, count.index)]}"
  ]
}
