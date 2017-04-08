variable "url" {
  type = "string"
}

variable "cloudfront_domain_name" {
  type = "string"
}

variable "cloudfront_zone_id" {
  type = "string"
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

resource "aws_route53_zone" "all" {
  count = "${length(var.domains)}"
  name  = "${element(var.domains, count.index)}"

  tags {
    Type = "Website"
    Url  = "${var.url}"
  }
}

resource "aws_route53_record" "naked_domains" {
  count   = "${aws_route53_zone.all.count}"
  zone_id = "${element(aws_route53_zone.all.*.zone_id, count.index)}"
  name    = "${element(aws_route53_zone.all.*.name, count.index)}"
  type    = "A"

  alias {
    name                   = "${var.cloudfront_domain_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "wildcard_domains" {
  count   = "${aws_route53_zone.all.count}"
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
  count   = "${aws_route53_zone.all.count}"
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
  count   = "${aws_route53_zone.all.count}"
  zone_id = "${element(aws_route53_zone.all.*.zone_id, count.index)}"
  name    = "${element(aws_route53_zone.all.*.name, count.index)}"
  type    = "MX"
  ttl     = "86400"

  records = "${var.mx_records}"
}

resource "aws_route53_record" "keybase" {
  count   = "${aws_route53_zone.all.count}"
  zone_id = "${element(aws_route53_zone.all.*.zone_id, count.index)}"
  name    = "${element(aws_route53_zone.all.*.name, count.index)}"
  type    = "TXT"
  ttl     = "86400"

  records = [
    "keybase-site-verification=${var.keybase_verification[element(aws_route53_zone.all.*.name, count.index)]}"
  ]
}
