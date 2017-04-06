variable "website_url" {
  type = "string"
}

variable "extra_urls" {
  type    = "list"
}

provider "aws" {
  region     = "us-east-1"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.website_url}"
  acl    = "public-read"

  tags {
    Type = "Website"
    Url  = "${var.website_url}"
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
    Url  = "${var.website_url}"
  }

  viewer_certificate {
    /* TODO: create resource */
    acm_certificate_arn            = "arn:aws:acm:us-east-1:312701731826:certificate/054196d8-6cfb-4442-96f5-9fdea2f1dd4a"
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1"
    ssl_support_method             = "sni-only"
  }
}
