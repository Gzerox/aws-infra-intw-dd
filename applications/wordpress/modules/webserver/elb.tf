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
  subnets = var.lb_subnets_ids

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
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access Denied"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "custom_header" {
  listener_arn = aws_lb_listener.web.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  condition {
    http_header {
      http_header_name = "X-Custom-Header"
      values           = ["random-value-cFFDfmpU8eimk6CR@@3yU49@"]
    }
  }
}