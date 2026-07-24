# private scope which does not change in runtime(local/private variables)

locals {
  ec2_key_name = "ec2_key"
}
resource "aws_default_vpc" "my_vpc" {
  ### Configuration omitted for brevity ###
}

resource "aws_default_subnet" "my_subnet" {
  for_each          = toset(["us-west-1a", "us-west-1c"])
  availability_zone = each.value
}

resource "aws_default_route_table" "my_route_table" {
  default_route_table_id = aws_default_vpc.my_vpc.default_route_table_id
}

resource "aws_internet_gateway" "my_gw" {
  vpc_id = aws_default_vpc.my_vpc.id
}

resource "aws_key_pair" "my_key" {
  key_name   = local.ec2_key_name
  public_key = file("id_ed25519.pub")
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "aws_sg" {
  name        = "my_sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_default_vpc.my_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.aws_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.aws_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.aws_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.aws_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_instance" "my_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.my_key.key_name
  subnet_id     = (values(aws_default_subnet.my_subnet))[0].id
  vpc_security_group_ids = [aws_security_group.aws_sg.id]
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }
  tags = {
    Name = "my_ec2"
  }
}
