resource "aws_route53_delegation_set" "main" {
  reference_name = "Main"
}

resource "aws_route53_zone" "all" {
  count = "${length(var.domains)}"
  name  = "${element(var.domains, count.index)}"

  delegation_set_id = "${aws_route53_delegation_set.main.id}"

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
    name                   = "${var.website_cloudfront_domain_name}"
    zone_id                = "${var.website_cloudfront_zone_id}"
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

resource "aws_route53_record" "gcloud" {
  count   = "${aws_route53_zone.all.count}"
  zone_id = "${element(aws_route53_zone.all.*.zone_id, count.index)}"
  name    = "gcloud.${element(aws_route53_zone.all.*.name, count.index)}"
  type    = "CNAME"
  ttl     = 86400

  records = [
    "c.storage.googleapis.com.",
  ]
}

resource "aws_route53_record" "name_servers" {
  count   = "${aws_route53_zone.all.count}"
  zone_id = "${element(aws_route53_zone.all.*.zone_id, count.index)}"
  name    = "${element(aws_route53_zone.all.*.name, count.index)}"
  type    = "NS"
  ttl     = 172800

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
  ttl     = 86400

  records = "${var.mx_records}"
}

resource "aws_route53_record" "txt" {
  count   = "${aws_route53_zone.all.count}"
  zone_id = "${element(aws_route53_zone.all.*.zone_id, count.index)}"
  name    = "${element(aws_route53_zone.all.*.name, count.index)}"
  type    = "TXT"
  ttl     = 86400

  records = [
    "keybase-site-verification=${var.keybase_verification[element(aws_route53_zone.all.*.name, count.index)]}",
    "google-site-verification=${var.google_verification[element(aws_route53_zone.all.*.name, count.index)]}",
  ]
}
