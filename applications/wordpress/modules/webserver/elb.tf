resource "aws_security_group" "lb_http" {
  description = "Allow HTTP traffic to instances through Elastic Load Balancer"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow HTTP through ELB Security Group"
  }
}

resource "aws_lb" "web" {
  name = "lb-${var.aws_resource_suffix}"
  load_balancer_type = "application"
  internal = false
  subnets = var.subnets_ids
  #cross_zone_load_balancing   = true

  security_groups = [
    aws_security_group.lb_http.id
  ]

}

resource "aws_lb_target_group" "web" {
  name     = "tg-${var.aws_resource_suffix}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}