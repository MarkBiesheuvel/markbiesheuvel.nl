variable "url" {
  type = "string"
}

variable "aliases" {
  type    = "list"
}

provider "aws" {
  region     = "us-east-1"
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

resource "aws_route53_zone" "main" {
  name = "${var.url}."

  tags {
    Type = "Website"
    Url  = "${var.url}"
  }
}

resource "aws_route53_record" "main_naked_domain" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "${var.url}."
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.main.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.main.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "main_wildcard_domain" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "*.${var.url}."
  type    = "A"

  alias {
    name                   = "${aws_route53_record.main_naked_domain.name}"
    zone_id                = "${aws_route53_record.main_naked_domain.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "main_ns" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "${var.url}."
  type    = "NS"
  ttl     = "172800"

  records = [
    "${aws_route53_zone.main.name_servers.0}",
    "${aws_route53_zone.main.name_servers.1}",
    "${aws_route53_zone.main.name_servers.2}",
    "${aws_route53_zone.main.name_servers.3}",
  ]
}
