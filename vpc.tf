

resource "aws_vpc" "main" {
  cidr_block = var.cidr-block
  tags = {
    "Name" = "${var.name}_VPC"
  }
}

# Create var.priv-count private subnets, each in a different AZ
resource "aws_subnet" "private" {
  count             = "${length(data.aws_availability_zones.available.names)/2}"
  cidr_block        = var.private_sub[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id

  tags = {
    "Name" = "${var.name}_PrivateSubnet_${count.index + 1}"
  }
}

# Create var.pub-count public subnets, each in a different AZ
resource "aws_subnet" "public" {
  count = "${length(data.aws_availability_zones.available.names)/2}"
  cidr_block                                  = var.pub_sub[count.index]
  availability_zone                           = data.aws_availability_zones.available.names[count.index]
  vpc_id                                      = aws_vpc.main.id
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    "Name" = "${var.name}_PublicSubnet_${count.index+1}"
  }
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.name}_gateway"
  }
}

#Create Nat Gateway
resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name = "${var.name}_EIP"
  }
}

resource "aws_nat_gateway" "Nat-GW" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "${var.name}_NatGW"
  }
  depends_on = [aws_eip.eip]
}


# Route the public subnet traffic through the IGW
resource "aws_route_table" "public" {
  count  = "${length(data.aws_availability_zones.available.names)/2}"
  vpc_id = aws_vpc.main.id
  #route_table_id    = aws_vpc.main.main_route_table_id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    "Name" = "${var.name}_RoutePublic_${count.index+1}"
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "public" {
  count          = "${length(data.aws_availability_zones.available.names)/2}"
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}


# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count  = "${length(data.aws_availability_zones.available.names)/2}"
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Nat-GW.id
  }

  tags = {
    "Name" = "${var.name}_RoutePrivate_${count.index + 1}"
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = "${length(data.aws_availability_zones.available.names)/2}"
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}


/*
resource "aws_security_group" "allow_ssh_pub" {
  name        = "${var.name}_PublicSG"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Http from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}_PublicSG"
  }
}
*/
