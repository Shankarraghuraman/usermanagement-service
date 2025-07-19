provider "aws" {
  region = var.aws_region
}

data "aws_iam_role" "ecs_execution_role" {
  name = var.ecs_task_execution_role_name
}

resource "aws_ecs_cluster" "main" {
  name = "usermgmt-cluster"
}

resource "aws_ecs_task_definition" "usermgmt" {
  family                   = "usermgmt-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "usermgmt"
      image     = "${var.ecr_registry}/${var.ecr_repository}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "usermgmt" {
  name            = "usermgmt-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.usermgmt.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnets
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_tasks.id]
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-sg"
  description = "Allow HTTP traffic to ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
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
