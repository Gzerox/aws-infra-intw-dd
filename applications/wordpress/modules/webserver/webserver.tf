resource "aws_security_group" "allow_http_out" {
  name        = "allow_http_out"
  description = "Allow HTTP outbound connections"
  vpc_id = var.vpc_id

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow HTTP Outbound"
  }
}

resource "aws_security_group" "allow_from_lb" {
  name        = "allow_from_elb"
  description = "Allow HTTP ELB Inbound connections"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.lb_http.id]
  }

  tags = {
    Name = "Allow HTTP Security Group"
  }
}
resource "aws_key_pair" "web" {
  key_name   = "kp-${var.aws_resource_suffix}"
  public_key = var.aws_ec2_key_pair_public_key
}

resource "aws_launch_template" "web" {
  name = "lt-${var.aws_resource_suffix}"
  image_id = "ami-058e6df85cfc7760b"
  instance_type = "t2.micro"

  key_name = aws_key_pair.web.key_name
  vpc_security_group_ids = [aws_security_group.allow_from_lb.id,aws_security_group.allow_http_out.id]

  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type = "one-time"
    }
  }
/*iam_instance_profile {
    name = "test"
  } */

  placement {
    availability_zone = "eu-central-1a"
  }

  user_data = filebase64("${path.module}/userdata.sh")
}

resource "aws_autoscaling_group" "web" {
  name = "asg-${var.aws_resource_suffix}"

  min_size             = 1
  desired_capacity     = 1
  max_size             = 3
  
  health_check_type    = "ELB"

  target_group_arns = [ aws_lb_target_group.web.id ]

  launch_template { 
    id = aws_launch_template.web.id 
    version = "$Latest"
    }

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  vpc_zone_identifier  = var.private_subnets_ids

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }

}