# variables.tf

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
}

variable "public_subnets" {
  description = "List of existing public subnet IDs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of existing private subnet IDs"
  type        = list(string)
}

variable "ecr_registry" {
  description = "ECR registry URI"
  type        = string
}

variable "ecr_repository" {
  description = "ECR repository name"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
}

variable "ecs_task_execution_role_name" {
  description = "Existing IAM role name for ECS task execution"
  type        = string
}
