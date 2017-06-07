output "s3_name" {
  value = "${aws_s3_bucket.website.bucket}"
}

output "s3_arn" {
  value = "${aws_s3_bucket.website.arn}"
}

output "cloudfront_distribution_id" {
  value = "${aws_cloudfront_distribution.website.id}"
}

output "cloudfront_domain_name" {
  value = "${aws_cloudfront_distribution.website.domain_name}"
}

output "cloudfront_zone_id" {
  value = "${aws_cloudfront_distribution.website.hosted_zone_id}"
}
