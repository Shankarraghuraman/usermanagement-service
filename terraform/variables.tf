variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
}

variable "vpc_id" {
  type        = string
  description = "ID of the existing VPC"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "ecr_registry" {
  type        = string
  description = "ECR registry URL"
}

variable "ecr_repository" {
  type        = string
  description = "ECR repository name"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag to deploy"
}

variable "ecs_task_execution_role_name" {
  type        = string
  description = "Name of the existing ECS task execution role"
}
