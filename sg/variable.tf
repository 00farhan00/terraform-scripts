variable "vpc_id" {
  description = "ID of the VPC where the security group will be created"
  type        = string
  default = "vpc-022c769bfbd4d86f9" #vpc ID
}

variable "name" {
  description = "Name for the security group"
  default = "Grievance_Tracker_SG"
}

variable "description" {
  description = "Description for the security group"
  default = "Grievance_Tracker_SG"
}

variable "tags" {
  description = "Description for the security group"
  default = "Grievance_Tracker"
}

# inbound rule
variable "ingress_rules" {
  default     = {
    /*
    "my ingress rule" = {
      "description" = "For HTTP"
      "from_port"   = "80"
      "to_port"     = "80"
      "protocol"    = "tcp"
      "cidr_blocks" = ["0.0.0.0/0"] # allow from ipv4
      "ipv6_cidr_blocks" = ["::/0"] # allow from ipv6

    },*/
    "my other ingress rule 1" = {
      "description" = "For SSH"
      "from_port"   = "22"
      "to_port"     = "22"
      "protocol"    = "tcp"
      "cidr_blocks" = ["13.229.45.230/32"] # allow from ipv4
      #"ipv6_cidr_blocks" = ["13.229.45.230/32"] # allow from ipv6

    },
    "my other ingress rule" = {
      "description" = "For SSH nathan ip"
      "from_port"   = "22"
      "to_port"     = "22"
      "protocol"    = "tcp"
      "cidr_blocks" = ["24.125.145.63/32"] # allow from ipv4
      #"ipv6_cidr_blocks" = ["13.229.45.230/32"] # allow from ipv6

    }
  }
  type        = map(any)
  description = "Security group ingress rules"
}

# outbound rule
variable "egress_rules" {
  default     = {
    "my egress rule" = {
      "description" = "allow all"
      "from_port"   = "0"
      "to_port"     = "0"
      "protocol"    = "-1"
      "cidr_blocks" = ["0.0.0.0/0"] # allow from ipv4
      "ipv6_cidr_blocks" = ["::/0"] # allow from ipv6

    }/*,
    "my other egress rule" = {
      "description" = "For test"
      "from_port"   = "1234"
      "to_port"     = "1234"
      "protocol"    = "tcp"
      "cidr_blocks" = ["0.0.0.0/0"] # allow from ipv4
      "ipv6_cidr_blocks" = ["::/0"] # allow from ipv6

    }*/
  }

  type        = map(any)
  description = "Security group egress rules"
}