variable "main_url" {
  type = "string"
}

variable "extra_urls" {
  type    = "list"
}

provider "aws" {
  region     = "us-east-1"
}

data "aws_acm_certificate" "certificate" {
  domain   = "${var.main_url}"
  statuses = ["ISSUED"]
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.main_url}"
  acl    = "public-read"

  tags {
    Type = "Website"
    Url  = "${var.main_url}"
  }

  website {
    index_document = "index.html"
  }
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {

  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2"
  default_root_object = "index.html"
  aliases             = "${var.extra_urls}"

  origin {
    domain_name = "${aws_s3_bucket.s3_bucket.bucket_domain_name}"
    origin_id   = "S3"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags {
    Type = "Website"
    Url  = "${var.main_url}"
  }

  viewer_certificate {
    acm_certificate_arn            = "${data.aws_acm_certificate.certificate.arn}"
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1"
    ssl_support_method             = "sni-only"
  }
}
