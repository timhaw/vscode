terraform {
  backend "s3" {
    region = "eu-west-2"
    bucket = "terraform-state-intercress"
    key    = "terraform/docker"
  }
}
