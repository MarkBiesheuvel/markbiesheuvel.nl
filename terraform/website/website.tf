data "aws_acm_certificate" "main" {
  domain   = "${var.url}"
  statuses = ["ISSUED"]
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    resources = [
      "arn:aws:s3:::${var.url}",
      "arn:aws:s3:::${var.url}/*",
    ]

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.identity.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket" "website" {
  bucket = "${var.url}"
  acl    = "private"
  policy = "${data.aws_iam_policy_document.s3_policy.json}"

  website {
    index_document = "index.html"
  }

  tags {
    Type = "Website"
    Url  = "${var.url}"
  }
}

resource "google_storage_bucket" "website" {
  name          = "gcloud.${var.url}"
  location      = "US"
  storage_class = "MULTI_REGIONAL"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "aws_cloudfront_origin_access_identity" "identity" {}

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

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.identity.cloudfront_access_identity_path}"
    }
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
    acm_certificate_arn            = "${data.aws_acm_certificate.main.arn}"
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1"
    ssl_support_method             = "sni-only"
  }

  tags {
    Type = "Website"
    Url  = "${var.url}"
  }
}
