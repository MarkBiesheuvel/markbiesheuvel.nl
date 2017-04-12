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

resource "aws_iam_role" "codebuild_role" {
  name = "${var.name}-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "${var.name}-codebuild-policy"
  role   = "${aws_iam_role.codebuild_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.artifact_store.arn}",
        "${aws_s3_bucket.artifact_store.arn}/*"
      ],
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:PutObject"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
        "arn:aws:codecommit:us-east-1:312701731826:markbiesheuvel.nl"
      ],
      "Action": [
        "codecommit:GitPull"
      ]
    }
  ]
}
EOF
}

resource "aws_codebuild_project" "main" {
  name          = "${var.name}-codebuild"
  description   = "Website ${var.url}"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  source {
    type      = "CODECOMMIT"
    location  = "${aws_codecommit_repository.main.clone_url_http}"
    buildspec = <<EOF
version: 0.1
phases:
  build:
    commands:
      - npm install -g yarn
      - yarn
      - yarn build
artifacts:
  files:
    - dist/*
  discard-paths: yes
EOF
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
