
# region name

variable "region_name" {
    default = "eu-north-1"
}

# ami id of os
variable "ami_id_os" {
    default = "ami-0a79730daaf45078a"
}

# key pair
variable "key_pair_name" {
    default = "key1"
}

# instance type

variable "instance_type" {
    default = "t3.micro"
}

# vpc CIDR range

variable "vpc-cidr" {
    default = "192.168.0.0/16"
}

# subnet CIDR range

variable "subnet1-cidr" {
    default = "192.168.0.0/19"

}


variable "subnet2-cidr" {
    default = "192.168.32.0/19"

}


variable "subnet3-cidr" {
    default = "192.168.64.0/19"

}

# availablity zone

variable "subnet1_az" {
    default =  "eu-north-1a"
}

variable "subnet2_az" {
    default =  "eu-north-1b"
}

variable "subnet3_az"{
    default =  "eu-north-1c"
}


# access key and secret key of aws

variable "access_key" {
    default =  "AKIAXHKDEWVEG5AJA7YB"
}

variable "secret_key"{
    default =  "FfNbj0sTdE2eC8B2GfLeEAktsjax0E/NuZ7VMvXS"
}

