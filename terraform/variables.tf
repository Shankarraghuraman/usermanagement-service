variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs"
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
  description = "Image tag to deploy"
}

variable "ecs_task_execution_role_name" {
  type        = string
  description = "Name of the ECS task execution IAM role"
}
