# Key Value pair

resource aws_key_pair my_key {
  key_name   = "${var.my_environment}-ec2-key" # dev-ec2-key
  public_key = file("${path.module}/../../../id_ed25519.pub")
} 

# VPC Default

resource aws_default_vpc default {
}

# Security Group 

resource aws_security_group my_security_group {
  name        = "${var.my_environment}-sg" # dev-sg
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_default_vpc.default.id
}

# Inbound & Outbount port rules

resource aws_vpc_security_group_ingress_rule allow_http {
  security_group_id = aws_security_group.my_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource aws_vpc_security_group_ingress_rule allow_ssh {
  security_group_id = aws_security_group.my_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource aws_vpc_security_group_egress_rule allow_all_traffic {
  security_group_id = aws_security_group.my_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# EC2 instance

resource aws_instance my_instance {
	count                  = var.ec2_count # Number of EC2 instances to create
	ami                    = data.aws_ami.ubuntu.id # OS AMI ID
	instance_type          = var.instance_type # Instance Type
	key_name               = aws_key_pair.my_key.key_name	# Key pair
	vpc_security_group_ids = [aws_security_group.my_security_group.id] # VPC & Security Group
	
	# root storage (EBS)
	root_block_device {
		volume_size = var.ec2_volume_size
		volume_type = var.ec2_volume_type
	}

	tags = {
    Name = "${var.my_environment}-${var.my_ec2}" # dev-terra-automate-server
    Environment = var.my_environment # dev
  }
}
