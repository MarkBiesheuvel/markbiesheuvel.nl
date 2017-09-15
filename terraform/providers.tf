provider "aws" {
  region = "eu-central-1"
}

provider "aws" {
  alias  = "global"
  region = "us-east-1"
}

provider "google" {
  region = "us-central1"
}
