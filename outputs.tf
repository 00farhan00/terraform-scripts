/*output "endpoint" {
  description = "Endpoint Information of the bucket"
  value       = aws_s3_bucket.s3_bucket.id
} */
output "vpc-cidr-range" {
  value = aws_vpc.main.cidr_block
}

output "public-subnet-range" {
  value = aws_subnet.public.*.cidr_block
}

output "private-subnet-range" {
  value = aws_subnet.private.*.cidr_block
}
/*
output "ec2_instance_publicip" {
  description = "EC2 Instance Public IP"
  value       = aws_instance.my-ec2-vm.*.public_ip
}
output "ec2_publicdns" {
  description = "Public DNS URL of an EC2 Instance"
  value       = aws_instance.my-ec2-vm.*.public_dns
}*/

