#EC2 Instance

resource "aws_instance" "demo-server" {
  ami = var.ami_id_os
  key_name = var.key_pair_name
  instance_type  = var.instance_type
  associate_public_ip_address = true
  subnet_id = aws_subnet.public_subnet-1.id
  vpc_security_group_ids = [aws_security_group.demo-vpc-sg.id]
  
  root_block_device {
    volume_size = 20 # in GB !
    volume_type = "gp3"
    encrypted   = true
  }

  # user_data = file("install_apache.sh")
  # user_data = "${file("install_apache.sh")}"
   user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl enable httpd
    sudo systemctl start httpd
    echo "<h1>Deployed via terraform</h1>" > /var/www/html/index.html
    EOF  
  tags = {
    "Name" = "myec2vm"
  }    
}
/*
resource "aws_instance" "demo-server2" {
  ami = var.ami_id_os
  key_name = var.key_pair_name
  instance_type  = var.instance_type
  associate_public_ip_address = true
  subnet_id = aws_subnet.public_subnet-2.id
  vpc_security_group_ids = [aws_security_group.demo-vpc-sg.id]

  user_data = <<-EOF
   #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl enable httpd
    sudo systemctl start httpd
    echo "<h1>Deployed via terraform</h1>" > /var/www/html/index.html
    echo '<!DOCTYPE html> <html> <body style="background-color:rgb(250, 210, 210);"> <h1>terraform sucks</h1> <p>Terraform Demo</p> <p>Application Version: V1</p> </body></html>' > /var/www/html/index.html
    EOF
  tags = {
    "Name" = "myec2vm2"
  }
}
*/


# create addtional volume in same AZ
/*
resource "aws_ebs_volume" "vol1" {
    size = 10
    type = "gp3"
    availability_zone = "${aws_instance.demo-server.availability_zone}"
}

# attach add. vol to ec2

resource "aws_volume_attachment" "vol1" {
    instance_id = "${aws_instance.demo-server.id}"
    volume_id = "${aws_ebs_volume.vol1.id}"
    device_name = "/dev/xvdb"
}
*/



#-----------------------------------------------------------------------------------------------------------------

#VPC
resource "aws_vpc" "demo-vpc" {
  cidr_block = var.vpc-cidr
}

#subnet-1
resource "aws_subnet" "public_subnet-1" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = var.subnet1-cidr
  availability_zone = var.subnet1_az
  map_public_ip_on_launch = "true"
  tags = {
    name = "public_demo_subnet-1"
  }
}
#subnet-2
resource "aws_subnet" "public_subnet-2" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = var.subnet2-cidr
  availability_zone = var.subnet2_az
  map_public_ip_on_launch = "true"
  tags = {
    name = "public_demo_subnet-2"
  }
}

#Subnet-3
resource "aws_subnet" "private_subnet-2" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = var.subnet3-cidr
  availability_zone = var.subnet3_az
  tags = {
    Name = "private_demo_subnet-2"
  }
}
#Internet Get-Way
resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.demo-vpc.id
  tags = {
    Name = "demo-igw"
  }
}

#Routing_Table
resource "aws_route_table" "demo-rt" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id
        }
  tags = {
    Name = "demo-rt"
          }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "vpc-public1-route-table-associate" {
  route_table_id = aws_route_table.demo-rt.id
  subnet_id      = aws_subnet.public_subnet-1.id
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "vpc-public2-route-table-associate" {
  route_table_id = aws_route_table.demo-rt.id
  subnet_id      = aws_subnet.public_subnet-2.id
}



#Security_Group
resource "aws_security_group" "demo-vpc-sg" {
  name        = "demo-vpc-sg"
  vpc_id      = aws_vpc.demo-vpc.id

#inbond rule

   ingress {
    description = "Allow Port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    description = "Allow Port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

#outbond rule
  egress {
    description = "Allow all IP and Ports Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "allow_tls"
  }
}


#-------------------------------------------------------------------------------------------------------------------
/*
#load balancer

#create ALB

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test.id]
  subnets            = [ aws_subnet.public_subnet-1.id,aws_subnet.public_subnet-2.id]

  enable_deletion_protection = false


  tags = {
    name = "alb- tf"
  }
}
# create SG for ALB

resource "aws_security_group" "test" {
  name        = "elb_sg"
  description = "elb_sg"
  vpc_id      = aws_vpc.demo-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "alb_sg_tf"
  }
}

# Create ALB Listener 

resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

resource "aws_lb_listener" "test2" {
  load_balancer_arn = aws_lb.test.arn
  port              = "81"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_app_eg1.arn
  }
}

# target group

resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.demo-vpc.id
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc-cidr
}



resource "aws_lb_target_group" "my_app_eg1" {
  name       = "my-app-eg1"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = aws_vpc.demo-vpc.id
  slow_start = 0

  load_balancing_algorithm_type = "round_robin"

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  health_check {
    enabled             = true
    port                = 80
    interval            = 30
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}


# register target in target group

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.demo-server.id
  port             = 80
}


resource "aws_lb_target_group_attachment" "my_app_eg1" {
  target_group_arn = aws_lb_target_group.my_app_eg1.arn
  target_id        = aws_instance.demo-server2.id
  port             = 80
}
*/
#------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------


#EKS


#Security_Group_Workernode_EKS
resource "aws_security_group" "worker_node_sg" {
  name        = "eks-test"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.demo-vpc.id

  ingress {
    description      = "ssh access to public"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}

# creating role for EKS master

resource "aws_iam_role" "master" {
    name = "ed-eks-master"

    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}


# attaching policies for in master role

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.master.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.master.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.master.name
}

#creating role for worker node

resource "aws_iam_role" "worker" {
  name = "ed-eks-worker"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# creating role for 

resource "aws_iam_policy" "autoscaler" {
  name   = "ed-eks-autoscaler-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeTags",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}


# attaching policies in worker role

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "x-ray" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  role       = aws_iam_role.worker.name
}
resource "aws_iam_role_policy_attachment" "s3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "autoscaler" {
  policy_arn = aws_iam_policy.autoscaler.arn
  role       = aws_iam_role.worker.name
}

resource "aws_iam_instance_profile" "worker" {
  depends_on = [aws_iam_role.worker]
  name       = "ed-eks-worker-new-profile"
  role       = aws_iam_role.worker.name
}

# created eks cluster

resource "aws_eks_cluster" "eks" {
  name = "eks-via-terraform"
  role_arn = aws_iam_role.master.arn

  vpc_config {
    subnet_ids = [aws_subnet.public_subnet-1.id,aws_subnet.public_subnet-2.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    #aws_subnet.pub_sub1,
    #aws_subnet.pub_sub2,
  ]

}

# created node group

resource "aws_eks_node_group" "backend" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "dev"
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids =  [aws_subnet.public_subnet-1.id,aws_subnet.public_subnet-2.id]
  capacity_type = "ON_DEMAND"
  disk_size = "20"
  instance_types = ["t3.micro"]
  remote_access {
    #:key_name = var.key_pair_name
    ec2_ssh_key = var.key_pair_name
    source_security_group_ids = [aws_security_group.worker_node_sg.id]
  }

  labels =  tomap({env = "dev"})

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    #aws_subnet.pub_sub1,
    #aws_subnet.pub_sub2,
  ]
}

#---------------------------------------------------------------------------------------------------------------------------------