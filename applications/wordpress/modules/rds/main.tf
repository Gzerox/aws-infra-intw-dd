resource "aws_rds_cluster" "main" {
  cluster_identifier      = "${var.aws_resource_suffix}-rds"
  engine                  = "aurora-mysql"
  engine_mode             = "serverless"
  engine_version          = "5.7.mysql_aurora.2.07.1"

  availability_zones      = var.aws_rds_az
  database_name           = "mydb"
  master_username         = "foo"
  master_password         = "Bar2013434dd"
  backup_retention_period = 7
  preferred_backup_window = "01:00-03:00"
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.allow_rds_inbound.id]
  skip_final_snapshot = true
  
  scaling_configuration {
    auto_pause               = true
    max_capacity             = 1
    min_capacity             = 1
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }

  lifecycle {
    ignore_changes = [
      availability_zones
    ]
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = var.rds_private_subnets_ids

  tags = {
    Name = "sub-group-${var.aws_resource_suffix}"
  }
}

resource "aws_security_group" "allow_rds_inbound" {
  name        = "allow_rds_mysql_inbound"
  description = "Allow MySQL Inbound"
  vpc_id      = var.vpc_id

  ingress {
      description      = "Allow MySQL Inbbound Connections"
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      security_groups      = var.security_group_id_allowed
    }
  tags = {
    Name = "Allow RDS Inbound"
  }
}