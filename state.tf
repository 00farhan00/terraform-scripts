terraform {
  backend "s3" {
    bucket = "timesteel-terraform-backend"
    key    = "LearnPro/Dev/terraform.tfstate"
    region = "ap-south-1"
    profile = "default"
  }
}
