resource "aws_security_group" "allow_ssh_inbound" {
  name        = "allow_ssh_inbound"
  description = "Allow SSH Inbound connections"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow SSH inbound"
  }
}
resource "aws_security_group" "allow_ssh_outbound" {
  name        = "allow_ssh_outbound"
  description = "Allow SSH Outbound connections"
  vpc_id = var.vpc_id

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow SSH outbound"
  }
}

resource "aws_key_pair" "web" {
  key_name   = "kp-${var.aws_resource_suffix}-bastionhost"
  public_key = var.aws_ec2_key_pair_public_key
}

resource "aws_instance" "web" {
    ami           = "ami-058e6df85cfc7760b"
    instance_type = "t2.micro"
    vpc_security_group_ids = [var.security_group_id,aws_security_group.allow_ssh_inbound.id,aws_security_group.allow_ssh_outbound.id]
    key_name=aws_key_pair.web.key_name
    subnet_id = var.subnet_id
    tags = {
      Name = "BastionHost"
    }
}