variable "url" {
  type = "string"
}

variable "name" {
  type = "string"
}

resource "aws_codecommit_repository" "main" {
  repository_name = "${var.url}"
  default_branch  = "master"
}

resource "aws_s3_bucket" "artifact_store" {
  bucket = "${var.name}-builds"
  acl    = "private"

  tags {
    Type = "Codepipeline"
  }
}

data "aws_iam_policy_document" "codebuild_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "${var.name}-codebuild-role"
  assume_role_policy = "${data.aws_iam_policy_document.codebuild_role_policy_document.json}"
}

data "aws_iam_policy_document" "codebuild_policy_document" {
  statement {
    resources = [
      "*",
    ]
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    resources = [
      "${aws_s3_bucket.artifact_store.arn}/*",
    ]
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
    ]
  }

  statement {
    resources = [
      "${aws_codecommit_repository.main.arn}",
    ]
    actions = [
      "codecommit:GitPull",
    ]
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "${var.name}-codebuild-policy"
  role   = "${aws_iam_role.codebuild_role.id}"
  policy = "${data.aws_iam_policy_document.codebuild_policy_document.json}"
}

resource "aws_codebuild_project" "main" {
  name          = "${var.name}-codebuild"
  description   = "Website ${var.url}"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  source {
    type      = "CODECOMMIT"
    location  = "${aws_codecommit_repository.main.clone_url_http}"
    buildspec = "${file("${path.module}/buildspec.yml")}"
  }

  artifacts {
    type = "S3"
    location = "${aws_s3_bucket.artifact_store.bucket}"
    name = "build"
    packaging = "NONE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:7.0.0"
    type         = "LINUX_CONTAINER"
  }

  tags {
    Type = "Codepipeline"
  }
}
