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
      "arn:aws:logs:*:*:*",
    ]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    resources = [
      "${aws_s3_bucket.artifact_store.arn}",
      "${aws_s3_bucket.artifact_store.arn}/*",
    ]

    actions = [
      "s3:ListBucket",
      "s3:ListObjects",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
    ]
  }

  statement {
    resources = [
      "${var.website_s3_arn}",
      "${var.website_s3_arn}/*",
    ]

    actions = [
      "s3:ListBucket",
      "s3:ListObjects",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
  }

  statement {
    resources = [
      "*",
    ]

    actions = [
      "cloudfront:CreateInvalidation",
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
    type      = "CODEPIPELINE"
    buildspec = "${file("${path.module}/buildspec.yml")}"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:7.0.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "S3_BUCKET"
      value = "${var.website_s3_name}"
    }

    environment_variable {
      name  = "CLOUDFRONT_DISTRIBUTION_ID"
      value = "${var.website_cloudfront_distribution_id}"
    }
  }

  tags {
    Type = "Codepipeline"
  }
}

data "aws_iam_policy_document" "codepipeline_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.name}-codepipeline-role"
  assume_role_policy = "${data.aws_iam_policy_document.codepipeline_role_policy_document.json}"
}

data "aws_iam_policy_document" "codepipeline_policy_document" {
  statement {
    resources = [
      "${aws_s3_bucket.artifact_store.arn}",
      "${aws_s3_bucket.artifact_store.arn}/*",
    ]

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject",
    ]
  }

  statement {
    resources = [
      "${aws_codecommit_repository.main.arn}",
    ]

    actions = [
      "codecommit:CancelUploadArchive",
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:UploadArchive",
    ]
  }

  statement {
    resources = [
      "${aws_codebuild_project.main.id}",
    ]

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.name}-codepipeline-policy"
  role = "${aws_iam_role.codepipeline_role.id}"

  policy = "${data.aws_iam_policy_document.codepipeline_policy_document.json}"
}

resource "aws_codepipeline" "main" {
  name     = "${var.name}-codepipeline"
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
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source"]
      version         = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.main.name}"
      }
    }
  }
}
