provider "aws" {
  region = var.aws_region
}

data "aws_iam_role" "ecs_execution_role" {
  name = var.ecs_task_execution_role_name
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/usermgmt"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "main" {
  name = "usermgmt-cluster"
}

resource "aws_ecs_task_definition" "usermgmt" {
  family                   = "usermgmt-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = data.aws_iam_role.ecs_execution_role.arn
  task_role_arn            = data.aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "usermgmt"
    image     = "${var.ecr_registry}/${var.ecr_repository}:${var.image_tag}"
    essential = true

    portMappings = [{
      containerPort = 8095
      hostPort      = 8095
      protocol      = "tcp"
    }]

    environment = [
      { name = "AWS_RDS_HOSTNAME",  value = "sha-db.c6h44cmyuuaw.us-east-1.rds.amazonaws.com" },
      { name = "AWS_RDS_PORT",      value = "3306" },
      { name = "AWS_RDS_DB_NAME",   value = "usermanagement" },
      { name = "AWS_RDS_USERNAME",  value = "admin" },
      { name = "AWS_RDS_PASSWORD",  value = "XbqB4qo77SpmNVbFK6VF" }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "usermgmt"
      }
    }
  }])
}

resource "aws_ecs_service" "usermgmt" {
  name            = "usermgmt-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.usermgmt.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_tasks.id]
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-sg"
  description = "Allow HTTP traffic to ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8095
    to_port     = 8095
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
