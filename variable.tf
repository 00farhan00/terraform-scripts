variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"
}
variable "bucket_name" {
  description = "Name of the S3 bucket. Must be Unique across AWS"
  type        = string
  default     = "dev020"
}
variable "env" {
  default = "dev"
}

variable "name" {
  default = "TimesProWeb"
}
variable "pub-count" {
  description = "Number of public subnet"
  default     = "3"
}
variable "priv-count" {
  description = "Number of private subnet"
  default     = "3"
}
variable "cidr-block" {
  default = "10.3.0.0/21"
}


variable "private_sub" {
  type = list(string)
  default = ["10.3.1.0/25", "10.3.2.0/25","10.3.3.0/25"]
}

variable "pub_sub" {
  type = list(string)
  default = ["10.3.4.0/25", "10.3.5.0/25", "10.3.6.0/25"]
}
/*
variable "ec2_instance_type" {
  description = "EC2 Instance Type"
  type        = string
  #default = "t3.medium"
}

variable "count1" {
  description = "EC2 Instance Count"
  type        = number
  default     = 1
}

variable "ec2-key" {

  type = string
}

variable "ec2_ami_id" {
  description = "AMI ID"
  type        = string
  default     = "ami-068257025f72f470d"
}


variable "dbcount" {
  description = "Number of rds"
  default     = "2"
}
variable "rdsname" {}
variable "engine" {}
variable "engine-version" {}
variable "instance-class" {}
variable "storage-type" {}
variable "storage" {}
variable "db_name" {}
variable "username" {}
variable "password" {}
variable "parameter-group-name" {}
variable "port" {
  type = list(any)
}
locals {
  ports = var.port
}

*/
