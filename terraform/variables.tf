variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ECS will run"
  type        = string
}

variable "public_subnets" {
  description = "Public subnets for ALB"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnets for ECS Fargate"
  type        = list(string)
}

variable "ecr_registry" {
  description = "ECR registry URI"
  type        = string
}

variable "ecr_repository" {
  description = "ECR repo name"
  type        = string
}

variable "image_tag" {
  description = "Git commit SHA for image tag"
  type        = string
}
