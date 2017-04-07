variable "main_url" {
  type = "string"
}

variable "extra_urls" {
  type    = "list"
}

provider "aws" {
  region     = "us-east-1"
}

/*
# Known issue: https://forums.aws.amazon.com/thread.jspa?threadID=249559
# Can not use data tag until old certificate is deleted

data "aws_acm_certificate" "certificate" {
  domain   = "${var.main_url}"
  statuses = ["ISSUED"]
}
*/
variable "certificate_arn" {
  default = "arn:aws:acm:us-east-1:312701731826:certificate/054196d8-6cfb-4442-96f5-9fdea2f1dd4a"
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
    /* acm_certificate_arn            = "${data.aws_acm_certificate.certificate.arn}" */
    acm_certificate_arn            = "${var.certificate_arn}"
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1"
    ssl_support_method             = "sni-only"
  }
}
