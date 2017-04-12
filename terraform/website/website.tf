variable "url" {
  type = "string"
}

variable "aliases" {
  type = "list"
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

resource "aws_s3_bucket" "website" {
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

/*
 TODO: restrict bucket access
 https://www.terraform.io/docs/providers/aws/r/cloudfront_origin_access_identity.html
*/
resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2"
  default_root_object = "index.html"
  price_class         = "PriceClass_All"
  aliases             = "${var.aliases}"

  origin {
    domain_name = "${aws_s3_bucket.website.bucket_domain_name}"
    origin_id   = "S3"
    origin_path = ""
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

output "s3_name" {
  value = "${aws_s3_bucket.website.bucket}"
}

output "s3_arn" {
  value = "${aws_s3_bucket.website.arn}"
}

output "cloudfront_domain_name" {
  value = "${aws_cloudfront_distribution.website.domain_name}"
}

output "cloudfront_zone_id" {
  value = "${aws_cloudfront_distribution.website.hosted_zone_id}"
}
