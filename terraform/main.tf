provider "aws" {
  region = "us-east-1"
}

# Use existing IAM role instead of creating a new one
data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_ecs_cluster" "this" {
  name = "sha_CI_CD-Demo"
}

resource "aws_ecs_task_definition" "usermgmt_task" {
  family                   = "usermgmt-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "usermgmt-container"
      image     = "434748569008.dkr.ecr.us-east-1.amazonaws.com/shankar/usermgmt:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "usermgmt_service" {
  name            = "usermgmt-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.usermgmt_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = var.security_group_ids
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.usermgmt_task]
}
