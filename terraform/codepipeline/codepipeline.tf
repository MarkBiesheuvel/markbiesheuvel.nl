variable "url" {
  type = "string"
}

resource "aws_s3_bucket" "artifact_store" {
  bucket = "codepipeline-${var.url}"
  acl    = "public-read"

  tags {
    Type = "Codepipeline"
  }
}

resource "aws_codecommit_repository" "main" {
  repository_name = "${var.url}"
  default_branch  = "master"
}

resource "aws_iam_role" "codebuild_role" {
  name = "${replace("${var.url}", ".", "-")}-codebuild-role"

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
  name   = "${replace("${var.url}", ".", "-")}-codebuild-policy"
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
    }
  ]
}
EOF
}

resource "aws_codebuild_project" "main" {
  name          = "${replace("${var.url}", ".", "-")}"
  description   = "Website ${var.url}"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  source {
    type      = "CODEPIPELINE"
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
    type = "CODEPIPELINE"
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

resource "aws_iam_role" "codepipeline_role" {
  name = "${replace("${var.url}", ".", "-")}-codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${replace("${var.url}", ".", "-")}-codepipeline-policy"
  role = "${aws_iam_role.codepipeline_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.artifact_store.arn}",
        "${aws_s3_bucket.artifact_store.arn}/*"
      ]
    },
    {
        "Action": [
            "codecommit:CancelUploadArchive",
            "codecommit:GetBranch",
            "codecommit:GetCommit",
            "codecommit:GetUploadArchiveStatus",
            "codecommit:UploadArchive"
        ],
        "Resource": "${aws_codecommit_repository.main.arn}",
        "Effect": "Allow"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "${aws_codebuild_project.main.id}"
    }
  ]
}
EOF
}

resource "aws_codepipeline" "main" {
  name = "${replace("${var.url}", ".", "-")}-codepipeline"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.artifact_store.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source"]

      configuration {
        RepositoryName = "${var.url}"
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      output_artifacts = ["build"]
      version          = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.main.name}"
      }
    }
  }
}
