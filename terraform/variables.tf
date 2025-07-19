variable "image_tag" {
  description = "Docker image tag (Git commit SHA)"
  type        = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ECS tasks"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs for ECS tasks"
}
