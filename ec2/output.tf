#It_Will_Give_Public_IP
output "public_ip_of_demo_server" {
    description = "this is the public IP"
    value = aws_instance.demo-server.public_ip
}

#It_Will_Give_Private_IP
output "private_ip_of_demo_server" {
    description = "this is the private IP"
    value = aws_instance.demo-server.private_ip
}

# dns name of lb
output "elb_dns_name" {
    description = "DNS address of lb"
value = aws_lb.test.dns_name
}