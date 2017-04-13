variable "url" {
  type = "string"
}

variable "name" {
  type = "string"
}

variable "website_s3_name" {
  type = "string"
}

variable "website_s3_arn" {
  type = "string"
}

variable "build_path" {
  type = "string"
  default = "build"
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
    name = "${var.build_path}"
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

data "aws_iam_policy_document" "lambda_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "deploy_role" {
  name               = "${var.name}-deploy-role"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_role_policy_document.json}"
}

data "aws_iam_policy_document" "deploy_policy_document" {
  statement {
    resources = [
      "${aws_s3_bucket.artifact_store.arn}",
    ]
    actions = [
      "s3:ListBucket",
    ]
  }

  statement {
    resources = [
      "${aws_s3_bucket.artifact_store.arn}/*",
    ]
    actions = [
      "s3:GetObject",
    ]
  }

  statement {
    resources = [
      "${var.website_s3_arn}/*",
    ]
    actions = [
      "s3:PutObject"
    ]
  }
}

resource "aws_iam_role_policy" "deploy_policy" {
  name   = "${var.name}-codebuild-policy"
  role   = "${aws_iam_role.deploy_role.id}"
  policy = "${data.aws_iam_policy_document.deploy_policy_document.json}"
}

resource "aws_lambda_function" "deploy" {
  function_name    = "${var.name}-post-build"
  role             = "${aws_iam_role.deploy_role.arn}"
  timeout          = 10
  runtime          = "nodejs6.10"
  handler          = "index.handler"
  filename         = "${path.module}/deploy.zip"
  source_code_hash = "${base64sha256(file("${path.module}/deploy.zip"))}"

  environment {
    variables = {
      destination_bucket = "${var.website_s3_name}"
      destination_path = "/"
      source_bucket = "${aws_s3_bucket.artifact_store.bucket}"
      source_path = "${var.build_path}/"
    }
  }
}
